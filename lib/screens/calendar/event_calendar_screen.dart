import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sessions_provider.dart';
import '../../services/calendar_data_service.dart';
import '../admin/admin_detail_sheets.dart';

enum CalendarRole {
  admin,
  speaker,
  delegate,
}

enum CalendarViewFilter {
  mySchedule,
  fullAgenda,
}

enum AdminCalendarCategory {
  all,
  sessions,
  workshops,
  freeSlots,
}

class EventCalendarScreen extends StatefulWidget {
  final CalendarRole role;
  final int initialDayIndex;

  const EventCalendarScreen({
    super.key,
    required this.role,
    this.initialDayIndex = 0,
  });

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  int _selectedDayIndex = 0;
  CalendarViewFilter _viewFilter = CalendarViewFilter.fullAgenda;
  AdminCalendarCategory _adminCategory = AdminCalendarCategory.all;
  String _selectedSessionCategory = 'All Categories';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _loadingBookmarks = {};
  bool _isLoading = true;

  List<CalendarEventItem> _allEvents = [];
  List<DateTime> _uniqueDates = [];

  CalendarRole get _effectiveRole {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isAdmin || auth.roleCode == 'AD' || widget.role == CalendarRole.admin) {
      return CalendarRole.admin;
    }
    if (auth.isSpeaker || auth.roleCode == 'SK' || widget.role == CalendarRole.speaker) {
      return CalendarRole.speaker;
    }
    return CalendarRole.delegate;
  }

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = widget.initialDayIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = _effectiveRole;
      // Admin always shows Full Agenda; Speaker/Delegate default to My Schedule
      if (role == CalendarRole.admin) {
        _viewFilter = CalendarViewFilter.fullAgenda;
      } else {
        _viewFilter = CalendarViewFilter.mySchedule;
      }
      _loadEvents();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEvents({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final role = _effectiveRole;
      final events = await CalendarDataService.fetchCalendarEvents(
        context: context,
        role: role,
        forceRefresh: forceRefresh,
      );

      if (mounted) {
        setState(() {
          _allEvents = events;
          _uniqueDates = _extractUniqueDates(events);
          if (_selectedDayIndex >= _uniqueDates.length && _uniqueDates.isNotEmpty) {
            _selectedDayIndex = 0;
          }
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ==========================================
  // Helper Date Parsing & Extraction
  // ==========================================
  List<DateTime> _extractUniqueDates(List<CalendarEventItem> items) {
    final Set<String> dateStrings = {};
    final List<DateTime> result = [];

    for (final item in items) {
      final dateStr = item.scheduleDate;
      if (dateStr.trim().isNotEmpty) {
        final parsed = _tryParseDate(dateStr);
        if (parsed != null) {
          final normalized = '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
          if (!dateStrings.contains(normalized)) {
            dateStrings.add(normalized);
            result.add(DateTime(parsed.year, parsed.month, parsed.day));
          }
        }
      }
    }

    result.sort((a, b) => a.compareTo(b));

    // Fallback: default 4 DFSICON 2026 conference days
    if (result.isEmpty) {
      return [
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 2),
        DateTime(2026, 10, 3),
        DateTime(2026, 10, 4),
      ];
    }

    return result;
  }

  String _getDayHeaderTitle(DateTime date, int index, List<DateTime> uniqueDates) {
    if (date.month == 10 && date.day == 1) return 'WORKSHOPS';
    if (date.month == 10 && date.day == 2) return 'DAY 1';
    if (date.month == 10 && date.day == 3) return 'DAY 2';
    if (date.month == 10 && date.day == 4) return 'DAY 3';

    if (uniqueDates.isNotEmpty && uniqueDates.first.month == 10 && uniqueDates.first.day == 1) {
      if (index == 0) return 'WORKSHOPS';
      return 'DAY $index';
    }

    return 'DAY ${index + 1}';
  }

  String _getDaySubtitle(DateTime date) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayStr = dayNames[date.weekday - 1];

    if (date.month == 10 && date.day == 1) return '$dayStr • Workshops';
    if (date.month == 10 && date.day == 2) return '$dayStr • Day 1';
    if (date.month == 10 && date.day == 3) return '$dayStr • Day 2';
    if (date.month == 10 && date.day == 4) return '$dayStr • Day 3';
    return dayStr;
  }

  DateTime? _tryParseDate(String dateStr) {
    if (dateStr.trim().isEmpty) return null;
    final clean = dateStr.trim();
    try {
      final d = DateTime.tryParse(clean);
      if (d != null) return DateTime(d.year, d.month, d.day);
    } catch (_) {}

    try {
      final isoMatch = RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})').firstMatch(clean);
      if (isoMatch != null) {
        return DateTime(int.parse(isoMatch.group(1)!), int.parse(isoMatch.group(2)!), int.parse(isoMatch.group(3)!));
      }

      final dmyMatch = RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})').firstMatch(clean);
      if (dmyMatch != null) {
        return DateTime(int.parse(dmyMatch.group(3)!), int.parse(dmyMatch.group(2)!), int.parse(dmyMatch.group(1)!));
      }

      final textMatch = RegExp(r'^(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})').firstMatch(clean);
      if (textMatch != null) {
        const months = {
          'jan': 1, 'january': 1, 'feb': 2, 'february': 2,
          'mar': 3, 'march': 3, 'apr': 4, 'april': 4, 'may': 5,
          'jun': 6, 'june': 6, 'jul': 7, 'july': 7,
          'aug': 8, 'august': 8, 'sep': 9, 'september': 9,
          'oct': 10, 'october': 10, 'nov': 11, 'november': 11,
          'dec': 12, 'december': 12,
        };
        final m = months[textMatch.group(2)!.toLowerCase()] ?? 10;
        return DateTime(int.parse(textMatch.group(3)!), m, int.parse(textMatch.group(1)!));
      }
    } catch (_) {}
    return null;
  }

  bool _matchesDate(CalendarEventItem item, DateTime targetDate) {
    final parsed = _tryParseDate(item.scheduleDate);
    if (parsed != null) {
      return parsed.year == targetDate.year &&
          parsed.month == targetDate.month &&
          parsed.day == targetDate.day;
    }
    return false;
  }

  int? _parseTimeToMinutes(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return null;
    try {
      String clean = timeStr.trim().toUpperCase();
      final hasAm = clean.contains('AM');
      final hasPm = clean.contains('PM');
      clean = clean.replaceAll(RegExp(r'[^\d:]'), '');
      final parts = clean.split(':');
      if (parts.isNotEmpty) {
        int hour = int.tryParse(parts[0]) ?? 0;
        int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
        if (hasPm && hour < 12) hour += 12;
        if (hasAm && hour == 12) hour = 0;
        return hour * 60 + minute;
      }
    } catch (_) {}
    return null;
  }

  String _formatMinutesToTime(int minutes) {
    final int h = minutes ~/ 60;
    final int m = minutes % 60;
    final String period = h >= 12 ? 'PM' : 'AM';
    final int displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${displayH.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }

  String _extractInitials(String? name) {
    if (name == null || name.trim().isEmpty || name.trim().toUpperCase() == 'NA') return 'S';
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  // ==========================================
  // Bookmark Handler
  // ==========================================
  Future<void> _handleToggleBookmark(CalendarEventItem event) async {
    setState(() => _loadingBookmarks.add(event.id));

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final sessionsProv = Provider.of<SessionsProvider>(context, listen: false);

      // Find matching session from sessionsProv
      SessionItem? matched;
      for (final s in sessionsProv.sessions) {
        if ((event.assignmentId != null && s.assignmentId == event.assignmentId) ||
            (event.topicId != null && s.topicId == event.topicId) ||
            s.title.trim().toLowerCase() == event.title.trim().toLowerCase()) {
          matched = s;
          break;
        }
      }
      if (matched == null) {
        for (final s in sessionsProv.mySessions) {
          if ((event.assignmentId != null && s.assignmentId == event.assignmentId) ||
              (event.topicId != null && s.topicId == event.topicId) ||
              s.title.trim().toLowerCase() == event.title.trim().toLowerCase()) {
            matched = s;
            break;
          }
        }
      }

      final String effectiveAssignmentId = (event.assignmentId != null && event.assignmentId!.isNotEmpty)
          ? event.assignmentId!
          : (matched?.assignmentId ?? event.id.replaceAll(RegExp(r'^[^\d]+'), ''));

      final int sessionId = matched?.id ?? int.tryParse(effectiveAssignmentId) ?? int.tryParse(event.id) ?? 0;

      final error = await sessionsProv.toggleBookmark(
        sessionId,
        auth.accessToken,
        assignmentIdOverride: effectiveAssignmentId.isNotEmpty ? effectiveAssignmentId : null,
        topicIdOverride: event.topicId,
        titleOverride: event.title,
      );

      if (mounted) {
        setState(() {
          _loadingBookmarks.remove(event.id);
          if (error == null) {
            event.isBookmarked = !event.isBookmarked;
            if (!event.isBookmarked && _viewFilter == CalendarViewFilter.mySchedule) {
              _allEvents.removeWhere((e) =>
                  e.id == event.id ||
                  (effectiveAssignmentId.isNotEmpty && e.assignmentId == effectiveAssignmentId) ||
                  (event.topicId != null && e.topicId == event.topicId));
            }
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error ?? (event.isBookmarked ? 'Slot added to your schedule' : 'Slot removed from your schedule'),
            ),
            backgroundColor: error != null
                ? const Color(0xFFDC2626)
                : (event.isBookmarked ? const Color(0xFF059669) : const Color(0xFF475569)),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _loadingBookmarks.remove(event.id));
    }
  }

  String? _getSpeakerProfileImageUrl(String? path) {
    if (path == null || path.isEmpty || path == 'null' || path == 'NA') return null;
    String cleanPath = path.trim().replaceAll('/./', '/');
    if (cleanPath.startsWith('http')) return cleanPath;
    if (cleanPath.startsWith('./')) cleanPath = cleanPath.substring(2);
    else if (cleanPath.startsWith('/')) cleanPath = cleanPath.substring(1);
    return 'https://services.heterohcl.com/dfs-icon/$cleanPath';
  }

  // ==========================================
  // Build Screen
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final currentRole = _effectiveRole;

    // Synchronously pull events from currently loaded providers to avoid blank frame
    final providerEvents = CalendarDataService.buildEventsFromProviders(context, role: currentRole);
    final effectiveEvents = _allEvents.isNotEmpty ? _allEvents : providerEvents;

    final dates = _extractUniqueDates(effectiveEvents);
    if (_selectedDayIndex >= dates.length && dates.isNotEmpty) {
      _selectedDayIndex = 0;
    }
    final activeDate = dates.isNotEmpty
        ? dates[_selectedDayIndex]
        : DateTime(2026, 10, 1);

    final isWorkshopsDay = (activeDate.month == 10 && activeDate.day == 1);
    final List<String> sessionCategories = [];
    if (!isWorkshopsDay) {
      final Set<String> catSet = {};
      for (final ev in effectiveEvents) {
        if (_matchesDate(ev, activeDate) &&
            (ev.type == CalendarItemType.session || ev.type == CalendarItemType.myPresentation)) {
          final cat = ev.category?.trim();
          if (cat != null &&
              cat.isNotEmpty &&
              cat.toLowerCase() != 'scientific session' &&
              cat.toLowerCase() != 'my presentation' &&
              cat.toLowerCase() != 'available slot' &&
              cat.toLowerCase() != 'cancelled slot' &&
              cat.toLowerCase() != 'all' &&
              cat.toLowerCase() != 'all categories') {
            catSet.add(cat);
          }
        }
      }
      sessionCategories.addAll(catSet.toList()..sort());
    }

    final timelineItems = _buildTimelineItems(activeDate, effectiveEvents);

    String titleText;
    String subtitleText;

    if (currentRole == CalendarRole.admin) {
      titleText = 'Master Schedule & Slots';
      subtitleText = 'All Conference Slots, Tracks & Workshops';
    } else if (currentRole == CalendarRole.speaker) {
      titleText = 'My Schedule';
      subtitleText = 'Presentations, Bookmarks & Workshops';
    } else {
      titleText = 'Slots & Event Agenda';
      subtitleText = 'Day-Wise Slots, Sessions & Workshops';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0A1E3D),
        foregroundColor: Colors.white,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titleText,
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitleText,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _loadEvents(forceRefresh: true),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
            tooltip: 'Refresh Schedule',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadEvents(forceRefresh: true),
        color: AppColors.primary,
        child: Column(
          children: [
            // ── Top Controls ──────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                children: [
                  // Search Bar
                  _buildSearchBar(currentRole),

                  // View Tabs — Admin: category pills only | Speaker/Delegate: My Schedule / Full Agenda
                  if (currentRole == CalendarRole.admin) ...[
                    const SizedBox(height: 10),
                    _buildCategoryPills(),
                  ] else ...[
                    const SizedBox(height: 10),
                    _buildViewToggle(),
                    if (_viewFilter == CalendarViewFilter.fullAgenda) ...[
                      const SizedBox(height: 10),
                      _buildCategoryPills(),
                    ],
                  ],

                  // Session Category Filter Dropdown (Only on session days if categories exist)
                  if (!isWorkshopsDay && sessionCategories.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildSessionCategoryDropdown(sessionCategories),
                  ],
                ],
              ),
            ),

            // ── Day Selector Strip ─────────────────────────────
            _buildDaySelectorStrip(dates),

            // ── Header Bar ────────────────────────────────────
            _buildScheduleHeaderBar(activeDate, timelineItems, currentRole),

            // ── Timeline Content ──────────────────────────────
            Expanded(
              child: _isLoading && timelineItems.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : timelineItems.isEmpty
                      ? _buildEmptyState(activeDate, currentRole)
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: EdgeInsets.fromLTRB(12, 10, 16, MediaQuery.of(context).padding.bottom + 40),
                          itemCount: timelineItems.length,
                          itemBuilder: (context, index) {
                            final item = timelineItems[index];
                            return _buildTimelineRow(
                              item: item,
                              isFirst: index == 0,
                              isLast: index == timelineItems.length - 1,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Timeline Items Builder
  // ==========================================
  List<dynamic> _buildTimelineItems(DateTime activeDate, [List<CalendarEventItem>? sourceEvents]) {
    final List<dynamic> rawItems = [];
    final q = _searchQuery.toLowerCase();
    final currentRole = _effectiveRole;
    final eventsList = sourceEvents ?? _allEvents;

    for (final event in eventsList) {
      if (!_matchesDate(event, activeDate)) continue;

      // Session Category filter dropdown (active on sessions day if user selected a category)
      if (_selectedSessionCategory != 'All Categories') {
        if (event.category?.trim().toLowerCase() != _selectedSessionCategory.toLowerCase()) {
          continue;
        }
      }

      // Search filter
      if (q.isNotEmpty) {
        final matches = event.title.toLowerCase().contains(q) ||
            (event.speakerName?.toLowerCase().contains(q) ?? false) ||
            (event.category?.toLowerCase().contains(q) ?? false) ||
            (event.hallName?.toLowerCase().contains(q) ?? false) ||
            (event.workshopCode?.toLowerCase().contains(q) ?? false);
        if (!matches) continue;
      }

      // ── ADMIN: always show everything, filtered by category pill ──
      if (currentRole == CalendarRole.admin) {
        if (_adminCategory == AdminCalendarCategory.all) {
          rawItems.add(event);
        } else if (_adminCategory == AdminCalendarCategory.sessions) {
          if (event.type == CalendarItemType.session ||
              event.type == CalendarItemType.myPresentation) {
            rawItems.add(event);
          }
        } else if (_adminCategory == AdminCalendarCategory.workshops) {
          if (event.type == CalendarItemType.workshop ||
              event.type == CalendarItemType.myWorkshop) {
            rawItems.add(event);
          }
        } else if (_adminCategory == AdminCalendarCategory.freeSlots) {
          if (event.type == CalendarItemType.freeSlot) rawItems.add(event);
        }
        continue;
      }

      // ── SPEAKER ──────────────────────────────────────────────────
      if (currentRole == CalendarRole.speaker) {
        if (_viewFilter == CalendarViewFilter.mySchedule) {
          // My Schedule = own presentations + bookmarked sessions + registered workshops
          final isMyPresentation = event.type == CalendarItemType.myPresentation;
          final isMyWorkshop = event.type == CalendarItemType.myWorkshop ||
              (event.type == CalendarItemType.workshop && event.isRegistered);
          final isBookmarkedSession = event.isBookmarked &&
              (event.type == CalendarItemType.session ||
               event.type == CalendarItemType.myPresentation);

          if (isMyPresentation || isMyWorkshop || isBookmarkedSession) {
            rawItems.add(event);
          }
        } else {
          // Full Agenda = everything (same as admin), filtered by category
          if (_adminCategory == AdminCalendarCategory.all) {
            rawItems.add(event);
          } else if (_adminCategory == AdminCalendarCategory.sessions) {
            if (event.type == CalendarItemType.session ||
                event.type == CalendarItemType.myPresentation) {
              rawItems.add(event);
            }
          } else if (_adminCategory == AdminCalendarCategory.workshops) {
            if (event.type == CalendarItemType.workshop ||
                event.type == CalendarItemType.myWorkshop) {
              rawItems.add(event);
            }
          } else if (_adminCategory == AdminCalendarCategory.freeSlots) {
            if (event.type == CalendarItemType.freeSlot) rawItems.add(event);
          }
        }
        continue;
      }

      // ── DELEGATE ─────────────────────────────────────────────────
      if (currentRole == CalendarRole.delegate) {
        if (_viewFilter == CalendarViewFilter.mySchedule) {
          // My Schedule = bookmarked sessions + registered workshops
          final isBookmarked = event.isBookmarked &&
              (event.type == CalendarItemType.session ||
               event.type == CalendarItemType.myPresentation);
          final isMyWorkshop = event.type == CalendarItemType.myWorkshop ||
              (event.type == CalendarItemType.workshop && event.isRegistered);

          if (isBookmarked || isMyWorkshop) {
            rawItems.add(event);
          }
        } else {
          // Full Agenda = everything, filtered by category
          if (_adminCategory == AdminCalendarCategory.all) {
            rawItems.add(event);
          } else if (_adminCategory == AdminCalendarCategory.sessions) {
            if (event.type == CalendarItemType.session ||
                event.type == CalendarItemType.myPresentation) {
              rawItems.add(event);
            }
          } else if (_adminCategory == AdminCalendarCategory.workshops) {
            if (event.type == CalendarItemType.workshop ||
                event.type == CalendarItemType.myWorkshop) {
              rawItems.add(event);
            }
          } else if (_adminCategory == AdminCalendarCategory.freeSlots) {
            if (event.type == CalendarItemType.freeSlot) rawItems.add(event);
          }
        }
        continue;
      }
    }

    // Sort chronologically by start time
    rawItems.sort((a, b) {
      final aStart = a is CalendarEventItem ? (_parseTimeToMinutes(a.startTime) ?? 0) : 0;
      final bStart = b is CalendarEventItem ? (_parseTimeToMinutes(b.startTime) ?? 0) : 0;
      return aStart.compareTo(bStart);
    });

    // Free Time Gap injection (only for My Schedule in non-admin roles)
    if (_viewFilter == CalendarViewFilter.mySchedule &&
        rawItems.isNotEmpty &&
        currentRole != CalendarRole.admin) {
      final List<dynamic> enrichedList = [];
      for (int i = 0; i < rawItems.length; i++) {
        final current = rawItems[i];
        enrichedList.add(current);
        if (i < rawItems.length - 1) {
          final next = rawItems[i + 1];
          if (current is CalendarEventItem && next is CalendarEventItem) {
            final currentEnd = _parseTimeToMinutes(current.endTime);
            final nextStart = _parseTimeToMinutes(next.startTime);
            if (currentEnd != null && nextStart != null && (nextStart - currentEnd) >= 30) {
              enrichedList.add(_FreeTimeGap(startMinutes: currentEnd, endMinutes: nextStart));
            }
          }
        }
      }
      return enrichedList;
    }

    return rawItems;
  }

  // ==========================================
  // UI Widgets
  // ==========================================

  Widget _buildSearchBar(CalendarRole currentRole) {
    String hint;
    if (currentRole == CalendarRole.admin) {
      hint = 'Search slots, sessions, workshops, halls...';
    } else if (currentRole == CalendarRole.speaker) {
      hint = 'Search my presentations, workshops, sessions...';
    } else {
      hint = 'Search sessions, topics, speakers, workshops...';
    }

    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (val) => setState(() => _searchQuery = val.trim()),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 16, color: Color(0xFF64748B)),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Row(
      children: [
        Expanded(
          child: _buildSegmentButton(
            label: 'My Schedule',
            icon: Icons.schedule_rounded,
            isSelected: _viewFilter == CalendarViewFilter.mySchedule,
            onTap: () => setState(() {
              _viewFilter = CalendarViewFilter.mySchedule;
              _adminCategory = AdminCalendarCategory.all;
            }),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSegmentButton(
            label: 'Full Agenda',
            icon: Icons.view_timeline_outlined,
            isSelected: _viewFilter == CalendarViewFilter.fullAgenda,
            onTap: () => setState(() {
              _viewFilter = CalendarViewFilter.fullAgenda;
              _adminCategory = AdminCalendarCategory.all;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterPill('All', AdminCalendarCategory.all),
          _buildFilterPill('Sessions', AdminCalendarCategory.sessions),
          _buildFilterPill('Workshops', AdminCalendarCategory.workshops),
          _buildFilterPill('Available Slots', AdminCalendarCategory.freeSlots),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: isSelected ? Colors.white : const Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, AdminCalendarCategory category) {
    final isSelected = _adminCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => _adminCategory = category),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0A1E3D) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF0A1E3D) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCategoryDropdown(List<String> categories) {
    final allOptions = ['All Categories', ...categories];
    final selectedValue = allOptions.contains(_selectedSessionCategory) ? _selectedSessionCategory : 'All Categories';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text(
            'Category:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                items: allOptions.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: cat == selectedValue ? FontWeight.bold : FontWeight.w500,
                        color: cat == selectedValue ? AppColors.primary : const Color(0xFF1E293B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedSessionCategory = val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelectorStrip(List<DateTime> uniqueDates) {
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: uniqueDates.length,
        itemBuilder: (context, index) {
          final date = uniqueDates[index];
          final isSelected = index == _selectedDayIndex;
          final monthName = monthNames[date.month - 1];
          final headerTitle = _getDayHeaderTitle(date, index, uniqueDates);
          final daySubtitle = _getDaySubtitle(date);
          final isWorkshopsDay = (date.month == 10 && date.day == 1);

          return GestureDetector(
            onTap: () => setState(() {
              _selectedDayIndex = index;
              _adminCategory = AdminCalendarCategory.all;
              _selectedSessionCategory = 'All Categories';
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 94,
              margin: const EdgeInsets.symmetric(horizontal: 3.5),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF0A1E3D), Color(0xFF1E3A8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                  width: isSelected ? 1.8 : 1.2,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primary.withAlpha(40), blurRadius: 8, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withAlpha(3), blurRadius: 3, offset: const Offset(0, 1))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        headerTitle,
                        style: TextStyle(
                          fontSize: isWorkshopsDay ? 9 : 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: isSelected
                              ? (isWorkshopsDay ? const Color(0xFFD8B4FE) : Colors.white70)
                              : (isWorkshopsDay ? const Color(0xFF9333EA) : AppColors.textLight),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${date.day} $monthName',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isWorkshopsDay ? const Color(0xFF9333EA) : const Color(0xFF38BDF8))
                          : (isWorkshopsDay ? const Color(0xFFFAF5FF) : const Color(0xFFEEF2FF)),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      daySubtitle,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isWorkshopsDay ? const Color(0xFF7E22CE) : const Color(0xFF4338CA)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleHeaderBar(DateTime activeDate, List<dynamic> items, CalendarRole currentRole) {
    final viewLabel = currentRole == CalendarRole.admin
        ? 'MASTER AGENDA'
        : (_viewFilter == CalendarViewFilter.mySchedule ? 'MY SCHEDULE' : 'FULL AGENDA');

    final calendarEvents = items.whereType<CalendarEventItem>().toList();
    final totalCount = calendarEvents.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                viewLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              '$totalCount ${totalCount == 1 ? 'slot' : 'slots'}',
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Timeline Row & Cards
  // ==========================================
  Widget _buildTimelineRow({
    required dynamic item,
    required bool isFirst,
    required bool isLast,
  }) {
    if (item is _FreeTimeGap) {
      return _buildFreeTimeGapCard(item);
    }

    final event = item as CalendarEventItem;
    final timeStr = event.startTime;

    Color trackColor;
    if (event.type == CalendarItemType.cancelledSlot || event.slotStatus?.toUpperCase() == 'CANCELLED') {
      trackColor = const Color(0xFFEF4444);
    } else if (event.type == CalendarItemType.myPresentation) {
      trackColor = const Color(0xFF10B981);
    } else if (event.type == CalendarItemType.myWorkshop) {
      trackColor = const Color(0xFF7C3AED);
    } else if (event.type == CalendarItemType.workshop) {
      trackColor = const Color(0xFF9333EA);
    } else if (event.type == CalendarItemType.freeSlot) {
      trackColor = const Color(0xFF16A34A); // Green for free slots
    } else if (event.slotStatus?.toUpperCase() == 'ALLOCATED' || event.slotStatus?.toUpperCase() == 'BOOKED') {
      trackColor = const Color(0xFFD97706); // Amber for allocated / booked slots
    } else {
      trackColor = const Color(0xFF3B82F6);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time Column
          SizedBox(
            width: 64,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeStr,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                  ),
                  if (event.endTime.isNotEmpty)
                    Text(
                      event.endTime,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Timeline Axis
          Column(
            children: [
              Expanded(
                child: isFirst
                    ? const SizedBox()
                    : Container(width: 2, decoration: BoxDecoration(color: trackColor.withAlpha(60), borderRadius: BorderRadius.circular(1))),
              ),
              Container(
                width: 11,
                height: 11,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: trackColor, width: 2.5),
                ),
              ),
              Expanded(
                child: isLast
                    ? const SizedBox()
                    : Container(width: 2, decoration: BoxDecoration(color: trackColor.withAlpha(60), borderRadius: BorderRadius.circular(1))),
              ),
            ],
          ),
          const SizedBox(width: 10),

          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildEventCard(event),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(CalendarEventItem event) {
    final currentRole = _effectiveRole;
    final isSpeakerRole = currentRole == CalendarRole.speaker;
    final isAdminRole = currentRole == CalendarRole.admin;
    final slotSt = event.slotStatus?.toUpperCase().trim() ?? '';
    final isCancelled = event.type == CalendarItemType.cancelledSlot ||
        (slotSt == 'CANCELLED');
    final isExplicitlyFree = slotSt == 'FREE' ||
        slotSt == 'AVAILABLE' ||
        slotSt == 'UNASSIGNED' ||
        event.type == CalendarItemType.freeSlot ||
        event.title.trim().toUpperCase() == 'FREE SLOT' ||
        event.title.trim().toUpperCase() == 'FREE';

    final isFreeSlot = !isCancelled && isExplicitlyFree;
    final isMyPresentation = !isFreeSlot && event.type == CalendarItemType.myPresentation;
    final isMyWorkshop = !isFreeSlot && event.type == CalendarItemType.myWorkshop;
    final isWorkshop = !isFreeSlot && (event.type == CalendarItemType.workshop || isMyWorkshop);
    final isAllocatedSlot = !isCancelled &&
        !isFreeSlot &&
        !isMyPresentation &&
        !isWorkshop &&
        (slotSt == 'ALLOCATED' ||
            slotSt == 'BOOKED' ||
            slotSt == 'ASSIGNED' ||
            slotSt == 'CONFIRMED');

    final isAllocated = !isCancelled &&
        !isFreeSlot &&
        (isAllocatedSlot ||
            event.type == CalendarItemType.session ||
            event.type == CalendarItemType.myPresentation ||
            event.type == CalendarItemType.workshop ||
            event.type == CalendarItemType.myWorkshop);

    // Theme colors
    Color borderColor;
    Color badgeColor;
    Color badgeBg;
    IconData badgeIcon;
    String badgeText;

    if (isCancelled) {
      borderColor = const Color(0xFFFECACA);
      badgeColor = const Color(0xFFDC2626);
      badgeBg = const Color(0xFFFEF2F2);
      badgeIcon = Icons.cancel_outlined;
      badgeText = 'CANCELLED';
    } else if (isFreeSlot) {
      borderColor = const Color(0xFF86EFAC);
      badgeColor = const Color(0xFF16A34A);
      badgeBg = const Color(0xFFF0FDF4);
      badgeIcon = Icons.check_circle_outline_rounded;
      badgeText = 'FREE';
    } else if (isMyPresentation) {
      borderColor = const Color(0xFF10B981);
      badgeColor = const Color(0xFF059669);
      badgeBg = const Color(0xFFECFDF5);
      badgeIcon = Icons.mic_rounded;
      badgeText = 'MY PRESENTATION';
    } else if (isMyWorkshop) {
      borderColor = const Color(0xFF7C3AED);
      badgeColor = const Color(0xFF7C3AED);
      badgeBg = const Color(0xFFF5F3FF);
      badgeIcon = Icons.assignment_turned_in_rounded;
      badgeText = 'MY WORKSHOP';
    } else if (isWorkshop) {
      borderColor = const Color(0xFFD8B4FE);
      badgeColor = const Color(0xFF9333EA);
      badgeBg = const Color(0xFFFAF5FF);
      badgeIcon = Icons.science_rounded;
      badgeText = 'WORKSHOP';
    } else if (isAllocatedSlot &&
        (event.topicId == null || event.topicId!.isEmpty) &&
        (event.speakerName == null || event.speakerName!.isEmpty || event.speakerName == 'NA')) {
      borderColor = const Color(0xFFFDE68A);
      badgeColor = const Color(0xFFD97706);
      badgeBg = const Color(0xFFFFFBEB);
      badgeIcon = Icons.event_available_rounded;
      badgeText = 'ALLOCATED';
    } else {
      borderColor = event.isBookmarked ? const Color(0xFF818CF8) : const Color(0xFFE2E8F0);
      badgeColor = const Color(0xFF4338CA);
      badgeBg = const Color(0xFFEEF2FF);
      badgeIcon = Icons.menu_book_rounded;
      badgeText = 'SCIENTIFIC SESSION';
    }

    final displayTitle = event.title.replaceAll('#', '·').replaceAll(RegExp(r'\s+·\s+'), ' · ').trim();

    final bool canTap = isAdminRole;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canTap ? () => _onEventTap(event, isAdminRole, isSpeakerRole, isMyPresentation, isWorkshop) : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(13.0),
          decoration: BoxDecoration(
            color: isCancelled ? const Color(0xFFFFFDFD) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: isMyPresentation || isMyWorkshop || isCancelled ? 1.6 : 1.1),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(4), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Badges
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Type Badge
                        _buildBadgeChip(badgeBg, badgeColor, badgeIcon, badgeText),

                        // Slot Status Indicator Badge (ALLOCATED)
                        if (isAllocated && badgeText != 'ALLOCATED')
                          _buildBadgeChip(
                            const Color(0xFFFFFBEB),
                            const Color(0xFFD97706),
                            Icons.event_available_rounded,
                            'ALLOCATED',
                          ),

                        // Time Pill
                        _buildTimePill('${event.startTime} - ${event.endTime}'),

                        // Hall Badge
                        if (event.hallName != null && event.hallName!.isNotEmpty)
                          _buildHallBadge(event.hallName!),

                        // Workshop Code
                        if (event.workshopCode != null && event.workshopCode!.isNotEmpty)
                          _buildWorkshopCodeBadge(event.workshopCode!),
                      ],
                    ),
                  ),

                  // Bookmark button — ONLY in My Schedule for sessions (so they can unbookmark/remove from My Schedule)
                  // In Full Agenda, do NOT show the bookmark button
                  if (!isAdminRole &&
                      _viewFilter == CalendarViewFilter.mySchedule &&
                      !isMyPresentation &&
                      !isWorkshop &&
                      !isFreeSlot &&
                      !isCancelled)
                    _buildBookmarkButton(event),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                displayTitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isCancelled ? const Color(0xFF991B1B) : AppColors.textPrimary,
                  height: 1.3,
                  decoration: isCancelled ? TextDecoration.lineThrough : null,
                  decorationColor: const Color(0xFFEF4444),
                ),
              ),

              // Workshop Fee
              if (isWorkshop && event.fee != null && event.fee != '0.00' && event.fee != '0') ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '₹${event.fee}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                  ),
                ),
              ],

              // Speaker Row
              if (event.speakerName != null && event.speakerName!.isNotEmpty && event.speakerName != 'NA') ...[
                const SizedBox(height: 10),
                _buildSpeakerRow(event),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onEventTap(CalendarEventItem event, bool isAdminRole, bool isSpeakerRole,
      bool isMyPresentation, bool isWorkshop) {
    if (isAdminRole) {
      if (isWorkshop) {
        showAdminWorkshopDetailsModal(context, workshopId: event.id);
      } else if (event.topicId != null && event.topicId!.isNotEmpty) {
        showAdminTopicDetailsModal(context, topicId: event.topicId!);
      } else {
        showAdminSlotDetailsModal(context, slotId: event.id);
      }
    }
  }

  Widget _buildBadgeChip(Color bg, Color color, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(text, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.3)),
        ],
      ),
    );
  }

  Widget _buildTimePill(String timeRange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_filled_rounded, size: 10.5, color: Color(0xFFD97706)),
          const SizedBox(width: 3.5),
          Text(
            timeRange,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildHallBadge(String rawHall) {
    String cleanHall = rawHall
        .replaceAll(RegExp(r'\b(hilton\s*(chennai|hotel|garden\s*inn)?|hotel\s*hilton|hotel|venue)\b', caseSensitive: false), '')
        .trim();
    cleanHall = cleanHall.replaceAll(RegExp(r'^[,–—\-\s:|]+|[,–—\-\s:|]+$'), '').trim();
    if (cleanHall.isEmpty) cleanHall = rawHall.trim();

    Color bg, text, border;
    final lower = cleanHall.toLowerCase();
    if (lower.contains('hall a') || lower.contains('track 1')) {
      bg = const Color(0xFFEFF6FF); text = const Color(0xFF1D4ED8); border = const Color(0xFFBFDBFE);
    } else if (lower.contains('hall b') || lower.contains('track 2')) {
      bg = const Color(0xFFFAF5FF); text = const Color(0xFF7E22CE); border = const Color(0xFFE9D5FF);
    } else if (lower.contains('hall c') || lower.contains('common')) {
      bg = const Color(0xFFFFF1F2); text = const Color(0xFFBE123C); border = const Color(0xFFFECDD3);
    } else if (lower.contains('plenary')) {
      bg = const Color(0xFFFFFBEB); text = const Color(0xFFB45309); border = const Color(0xFFFDE68A);
    } else {
      bg = const Color(0xFFF0FDFA); text = const Color(0xFF0F766E); border = const Color(0xFF99F6E4);
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6), border: Border.all(color: border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.meeting_room_rounded, size: 10, color: text),
          const SizedBox(width: 3),
          Flexible(
            child: Text(cleanHall, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: text),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopCodeBadge(String code) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Text(code, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE))),
    );
  }

  Widget _buildBookmarkButton(CalendarEventItem event) {
    return GestureDetector(
      onTap: () => _handleToggleBookmark(event),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: event.isBookmarked ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: event.isBookmarked ? const Color(0xFF818CF8) : const Color(0xFFE2E8F0)),
        ),
        child: _loadingBookmarks.contains(event.id)
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              )
            : Icon(
                event.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                color: event.isBookmarked ? AppColors.primary : const Color(0xFF94A3B8),
                size: 17,
              ),
      ),
    );
  }

  Widget _buildSpeakerRow(CalendarEventItem event) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: event.speakerBg ?? const Color(0xFF1E3A8A), shape: BoxShape.circle),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: _getSpeakerProfileImageUrl(event.speakerProfileImage) != null
              ? Image.network(
                  _getSpeakerProfileImageUrl(event.speakerProfileImage)!,
                  fit: BoxFit.cover,
                  width: 28,
                  height: 28,
                  errorBuilder: (c, o, s) => Text(
                    _extractInitials(event.speakerName),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                )
              : Text(
                  _extractInitials(event.speakerName),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.speakerName!,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (event.speakerDesignation != null && event.speakerDesignation!.isNotEmpty)
                Text(
                  event.speakerDesignation!,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else if (event.category != null && event.category!.isNotEmpty)
                Text(
                  event.category!,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFreeTimeGapCard(_FreeTimeGap gap) {
    final startTimeStr = _formatMinutesToTime(gap.startMinutes);
    final endTimeStr = _formatMinutesToTime(gap.endMinutes);
    final durationMins = gap.endMinutes - gap.startMinutes;

    return Padding(
      padding: const EdgeInsets.only(left: 64, bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.coffee_rounded, size: 15, color: Color(0xFFD97706)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Free Time • $durationMins mins',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '$startTimeStr – $endTimeStr • Coffee / Networking Break',
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Empty State
  // ==========================================
  Widget _buildEmptyState(DateTime activeDate, CalendarRole currentRole) {
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateFormatted = '${activeDate.day} ${monthNames[activeDate.month - 1]}';

    String title;
    String subtitle;

    if (_isLoading) {
      title = 'Loading schedule...';
      subtitle = 'Fetching slots and sessions from the server';
    } else if (_viewFilter == CalendarViewFilter.mySchedule && currentRole != CalendarRole.admin) {
      if (currentRole == CalendarRole.speaker) {
        title = 'No assigned slots for $dateFormatted';
        subtitle = 'You have no presentations or registered workshops on this day.\nSwitch to Full Agenda to browse all conference sessions.';
      } else {
        title = 'Nothing in your schedule for $dateFormatted';
        subtitle = 'Bookmark sessions or register for workshops to see them here.\nSwitch to Full Agenda to browse all events.';
      }
    } else {
      title = 'No slots scheduled for $dateFormatted';
      subtitle = _adminCategory != AdminCalendarCategory.all
          ? 'No events in this category. Try "All" to see everything.'
          : 'No conference events found. Try refreshing or check another day.';
    }

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
              child: const Icon(Icons.event_busy_rounded, color: Color(0xFF3B82F6), size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            if (_adminCategory != AdminCalendarCategory.all)
              ElevatedButton.icon(
                onPressed: () => setState(() => _adminCategory = AdminCalendarCategory.all),
                icon: const Icon(Icons.apps_rounded, size: 16, color: Colors.white),
                label: const Text('View All Slots & Events', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A1E3D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
              )
            else if (_viewFilter == CalendarViewFilter.mySchedule && currentRole != CalendarRole.admin)
              ElevatedButton.icon(
                onPressed: () => setState(() {
                  _viewFilter = CalendarViewFilter.fullAgenda;
                  _adminCategory = AdminCalendarCategory.all;
                }),
                icon: const Icon(Icons.explore_rounded, size: 16, color: Colors.white),
                label: const Text('Explore Full Agenda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => _loadEvents(forceRefresh: true),
                icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                label: const Text('Refresh Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// Helper Data Classes for Timeline
// ==========================================
class _FreeTimeGap {
  final int startMinutes;
  final int endMinutes;

  const _FreeTimeGap({
    required this.startMinutes,
    required this.endMinutes,
  });
}
