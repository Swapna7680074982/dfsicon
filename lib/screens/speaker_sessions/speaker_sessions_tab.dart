import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sessions_provider.dart';
import 'speaker_session_detail_screen.dart';
import '../session_details/session_details_screen.dart';
import '../../widgets/water_droplets_background.dart';
import '../../utils/time_formatter.dart';

enum SpeakerSessionFilter { mySessions, all, bookmarked }
enum SpeakerSessionViewMode { list, calendar }
enum TimeOfDayFilter { all, morning, afternoon, evening, custom }

class SpeakerSessionsTab extends StatefulWidget {
  const SpeakerSessionsTab({super.key});

  @override
  State<SpeakerSessionsTab> createState() => _SpeakerSessionsTabState();
}

class _SpeakerSessionsTabState extends State<SpeakerSessionsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedDate;
  SpeakerSessionFilter _selectedFilter = SpeakerSessionFilter.mySessions;
  SpeakerSessionViewMode _viewMode = SpeakerSessionViewMode.list;
  TimeOfDayFilter _selectedTimeFilter = TimeOfDayFilter.all;
  TimeOfDay? _customStartTime;
  TimeOfDay? _customEndTime;
  final Set<int> _loadingBookmarks = {};
  int _selectedCalendarDayIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSessions(forceRefresh: false);
    });
  }

  Future<void> _fetchSessions({bool forceRefresh = false}) async {
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final sessions = Provider.of<SessionsProvider>(context, listen: false);
    await Future.wait([
      sessions.fetchMyConfirmedSessions(auth.accessToken, forceRefresh: forceRefresh),
      sessions.fetchConfirmedSessions(auth.accessToken, forceRefresh: forceRefresh),
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DateTime? _parseDateTime(String str) {
    str = str.trim();
    if (str.isEmpty) return null;
    
    final parsed = DateTime.tryParse(str);
    if (parsed != null) return parsed;
    
    try {
      final parts = str.split(RegExp(r'[-/ ]'));
      if (parts.length >= 3) {
        if (parts[0].length <= 2 && parts[2].length >= 4) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2].substring(0, 4));
          if (day != null && month != null && year != null) {
            return DateTime(year, month, day);
          }
        }
        if (parts[0].length == 4 && parts[2].length <= 2) {
          final year = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final day = int.tryParse(parts[2].substring(0, 2));
          if (year != null && month != null && day != null) {
            return DateTime(year, month, day);
          }
        }
      }
    } catch (_) {}

    try {
      const months = [
        'january', 'february', 'march', 'april', 'may', 'june',
        'july', 'august', 'september', 'october', 'november', 'december'
      ];
      final lower = str.toLowerCase();
      for (int m = 0; m < months.length; m++) {
        if (lower.contains(months[m])) {
          final numbers = RegExp(r'\d+').allMatches(str).map((match) => int.parse(match.group(0)!)).toList();
          if (numbers.length >= 2) {
            int day = numbers[0];
            int year = numbers[1] > 1000 ? numbers[1] : (numbers.length > 2 ? numbers[2] : DateTime.now().year);
            if (day > 31 && numbers.length > 1) {
              year = day;
              day = numbers[1];
            }
            return DateTime(year, m + 1, day);
          }
        }
      }
    } catch (_) {}

    return null;
  }

  int? _parseTimeToMinutes(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      String clean = timeStr.trim().toUpperCase();
      final hasAmPm = clean.contains('AM') || clean.contains('PM');
      
      final parts = clean.split(':');
      if (parts.isNotEmpty) {
        int? hour = int.tryParse(parts[0]);
        int minute = 0;
        if (parts.length > 1) {
          final minStr = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
          minute = int.tryParse(minStr) ?? 0;
        }
        if (hour != null) {
          if (hasAmPm) {
            if (clean.contains('PM') && hour < 12) {
              hour += 12;
            } else if (clean.contains('AM') && hour == 12) {
              hour = 0;
            }
          }
          return hour * 60 + minute;
        }
      }
    } catch (_) {}
    return null;
  }

  int? _extractSessionStartMinutes(SessionItem s) {
    if (s.startTime != null && s.startTime!.isNotEmpty) {
      final m = _parseTimeToMinutes(s.startTime);
      if (m != null) return m;
    }
    if (s.time.isNotEmpty) {
      final startPart = s.time.split(RegExp(r'[–-]')).first.trim();
      final m = _parseTimeToMinutes(startPart);
      if (m != null) return m;
    }
    return null;
  }

  int? _extractSessionEndMinutes(SessionItem s) {
    if (s.endTime != null && s.endTime!.isNotEmpty) {
      final m = _parseTimeToMinutes(s.endTime);
      if (m != null) return m;
    }
    if (s.time.isNotEmpty) {
      final parts = s.time.split(RegExp(r'[–-]'));
      if (parts.length > 1) {
        final endPart = parts[1].trim();
        final m = _parseTimeToMinutes(endPart);
        if (m != null) return m;
      }
    }
    final start = _extractSessionStartMinutes(s);
    if (start != null) {
      return start + 45; // Default assumption 45 mins
    }
    return null;
  }

  bool _matchesTime(SessionItem s, TimeOfDayFilter timeFilter) {
    if (timeFilter == TimeOfDayFilter.all) return true;
    
    final startMin = _extractSessionStartMinutes(s);
    final endMin = _extractSessionEndMinutes(s) ?? (startMin != null ? startMin + 30 : null);
    if (startMin == null) return true;

    switch (timeFilter) {
      case TimeOfDayFilter.morning:
        // Morning: < 12:00 PM
        return startMin < 12 * 60;
      case TimeOfDayFilter.afternoon:
        // Afternoon: 12:00 PM to 05:00 PM (12:00 to 16:59)
        return startMin >= 12 * 60 && startMin < 17 * 60;
      case TimeOfDayFilter.evening:
        // Evening: 05:00 PM onwards
        return startMin >= 17 * 60;
      case TimeOfDayFilter.custom:
        if (_customStartTime == null && _customEndTime == null) return true;
        final filterStartMin = _customStartTime != null ? _customStartTime!.hour * 60 + _customStartTime!.minute : 0;
        final filterEndMin = _customEndTime != null ? _customEndTime!.hour * 60 + _customEndTime!.minute : 24 * 60;
        return startMin < filterEndMin && (endMin == null || endMin > filterStartMin);
      case TimeOfDayFilter.all:
        return true;
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final minute = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  String _getSessionDisplayTime(SessionItem session) {
    if (session.startTime != null && session.startTime!.isNotEmpty &&
        session.endTime != null && session.endTime!.isNotEmpty) {
      return '${TimeFormatter.formatTime(session.startTime!)} - ${TimeFormatter.formatTime(session.endTime!)}';
    }
    if (session.time.isNotEmpty) {
      return TimeFormatter.formatTimeRange(session.time);
    }
    if (session.startTime != null && session.startTime!.isNotEmpty) {
      return TimeFormatter.formatTime(session.startTime!);
    }
    return '';
  }

  String _getTimeFilterDisplayLabel() {
    switch (_selectedTimeFilter) {
      case TimeOfDayFilter.all:
        return 'ALL TIMES';
      case TimeOfDayFilter.morning:
        return 'MORNING (6 AM - 12 PM)';
      case TimeOfDayFilter.afternoon:
        return 'AFTERNOON (12 PM - 5 PM)';
      case TimeOfDayFilter.evening:
        return 'EVENING (5 PM - 10 PM)';
      case TimeOfDayFilter.custom:
        if (_customStartTime != null && _customEndTime != null) {
          return '${_formatTimeOfDay(_customStartTime!)} - ${_formatTimeOfDay(_customEndTime!)}';
        }
        return 'CUSTOM RANGE';
    }
  }

  Future<void> _showTimeRangePickerSheet() async {
    TimeOfDay tempStart = _customStartTime ?? const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay tempEnd = _customEndTime ?? const TimeOfDay(hour: 17, minute: 0);

    final presets = [
      {'label': 'Morning Slot', 'range': '08:00 AM - 11:00 AM', 'start': const TimeOfDay(hour: 8, minute: 0), 'end': const TimeOfDay(hour: 11, minute: 0)},
      {'label': 'Mid-day Slot', 'range': '11:00 AM - 02:00 PM', 'start': const TimeOfDay(hour: 11, minute: 0), 'end': const TimeOfDay(hour: 14, minute: 0)},
      {'label': 'Afternoon Slot', 'range': '02:00 PM - 05:00 PM', 'start': const TimeOfDay(hour: 14, minute: 0), 'end': const TimeOfDay(hour: 17, minute: 0)},
      {'label': 'Evening Slot', 'range': '05:00 PM - 08:00 PM', 'start': const TimeOfDay(hour: 17, minute: 0), 'end': const TimeOfDay(hour: 20, minute: 0)},
      {'label': 'Night Slot', 'range': '08:00 PM - 11:00 PM', 'start': const TimeOfDay(hour: 20, minute: 0), 'end': const TimeOfDay(hour: 23, minute: 0)},
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.access_time_filled, color: AppColors.primary, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Filter by Time Range',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textLight, size: 22),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Preset Ranges
                    const Text(
                      'PRESET TIME RANGES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: presets.map((p) {
                        final pStart = p['start'] as TimeOfDay;
                        final pEnd = p['end'] as TimeOfDay;
                        final isPresetSelected = tempStart.hour == pStart.hour &&
                            tempStart.minute == pStart.minute &&
                            tempEnd.hour == pEnd.hour &&
                            tempEnd.minute == pEnd.minute;

                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              tempStart = pStart;
                              tempEnd = pEnd;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isPresetSelected ? const Color(0xFFEFF6FF) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isPresetSelected ? AppColors.primary : AppColors.tileBorder,
                                width: isPresetSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p['label'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isPresetSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isPresetSelected ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p['range'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: isPresetSelected ? AppColors.primary : AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Custom Start & End Selection
                    const Text(
                      'CUSTOM TIME RANGE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Start Time Card
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: sheetContext,
                                initialTime: tempStart,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColors.primary,
                                        onPrimary: Colors.white,
                                        onSurface: AppColors.textPrimary,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  tempStart = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.primary.withAlpha(80), width: 1.2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'START TIME',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatTimeOfDay(tempStart),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // End Time Card
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: sheetContext,
                                initialTime: tempEnd,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColors.primary,
                                        onPrimary: Colors.white,
                                        onSurface: AppColors.textPrimary,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  tempEnd = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.primary.withAlpha(80), width: 1.2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'END TIME',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatTimeOfDay(tempEnd),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedTimeFilter = TimeOfDayFilter.all;
                                _customStartTime = null;
                                _customEndTime = null;
                              });
                              Navigator.pop(sheetContext);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.tileBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text(
                              'RESET',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedTimeFilter = TimeOfDayFilter.custom;
                                _customStartTime = tempStart;
                                _customEndTime = tempEnd;
                              });
                              Navigator.pop(sheetContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text(
                              'APPLY TIME RANGE',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _matchesDate(SessionItem session, DateTime targetDate) {
    final dateStr = (session.scheduleDate ?? session.date).trim();
    if (dateStr.isEmpty) return false;

    final parsed = _parseDateTime(dateStr);
    if (parsed != null) {
      return parsed.year == targetDate.year &&
          parsed.month == targetDate.month &&
          parsed.day == targetDate.day;
    }

    final yyyymmdd = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
    final ddmmyyyy = "${targetDate.day.toString().padLeft(2, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.year}";
    final slashFormat = "${targetDate.day.toString().padLeft(2, '0')}/${targetDate.month.toString().padLeft(2, '0')}/${targetDate.year}";
    return dateStr.contains(yyyymmdd) || dateStr.contains(ddmmyyyy) || dateStr.contains(slashFormat);
  }

  String? _getSpeakerProfileImageUrl(String? path) {
    if (path == null || path.isEmpty || path == 'null' || path == 'NA') {
      return null;
    }
    String cleanPath = path.trim();
    if (cleanPath.contains('/./')) {
      cleanPath = cleanPath.replaceAll('/./', '/');
    }
    if (cleanPath.startsWith('http')) {
      return cleanPath;
    }
    if (cleanPath.startsWith('./')) {
      cleanPath = cleanPath.substring(2);
    } else if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return 'https://services.heterohcl.com/dfs-icon/$cleanPath';
  }

  Future<void> _handleToggleBookmark(SessionItem session) async {
    if (_loadingBookmarks.contains(session.id)) return;
    setState(() {
      _loadingBookmarks.add(session.id);
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final sessionsProvider = Provider.of<SessionsProvider>(context, listen: false);
    final errorMessage = await sessionsProvider.toggleBookmark(session.id, auth.accessToken);

    if (mounted) {
      setState(() {
        _loadingBookmarks.remove(session.id);
      });
    }

    if (errorMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  List<DateTime> _extractUniqueDates(List<SessionItem> allList) {
    final Map<String, DateTime> uniqueMap = {};
    for (final s in allList) {
      final dateStr = (s.scheduleDate ?? s.date).trim();
      if (dateStr.isNotEmpty) {
        final parsed = _parseDateTime(dateStr);
        if (parsed != null) {
          final key = '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
          if (!uniqueMap.containsKey(key)) {
            uniqueMap[key] = DateTime(parsed.year, parsed.month, parsed.day);
          }
        }
      }
    }
    final dates = uniqueMap.values.toList();
    dates.sort((a, b) => a.compareTo(b));
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    final sessionsProvider = Provider.of<SessionsProvider>(context);
    final allSessions = sessionsProvider.sessions;
    final mySessions = sessionsProvider.mySessions;
    final bookmarkedSessions = allSessions.where((s) => s.isBookmarked).toList();

    // Determine current base list according to selected filter chip
    List<SessionItem> currentList;
    switch (_selectedFilter) {
      case SpeakerSessionFilter.mySessions:
        currentList = mySessions;
        break;
      case SpeakerSessionFilter.all:
        currentList = allSessions;
        break;
      case SpeakerSessionFilter.bookmarked:
        currentList = bookmarkedSessions;
        break;
    }

    // Extract calendar unique dates from available sessions
    final combinedForDates = [...mySessions, ...allSessions];
    final uniqueDates = _extractUniqueDates(combinedForDates);

    // Apply Search, Date, and Time Filter
    final query = _searchQuery.toLowerCase().trim();
    List<SessionItem> filteredList = currentList.where((s) {
      final matchesSearch = query.isEmpty ||
          s.title.toLowerCase().contains(query) ||
          s.speakerName.toLowerCase().contains(query) ||
          s.speakerTitle.toLowerCase().contains(query) ||
          s.location.toLowerCase().contains(query) ||
          (s.keywords ?? '').toLowerCase().contains(query) ||
          (s.coordinatorName ?? '').toLowerCase().contains(query);

      bool matchesDateFilter = true;
      if (_viewMode == SpeakerSessionViewMode.list && _selectedDate != null) {
        matchesDateFilter = _matchesDate(s, _selectedDate!);
      }

      final matchesTimeFilter = _matchesTime(s, _selectedTimeFilter);

      return matchesSearch && matchesDateFilter && matchesTimeFilter;
    }).toList();

    final bool isOverallLoading = _selectedFilter == SpeakerSessionFilter.mySessions
        ? sessionsProvider.isLoadingMySessions && mySessions.isEmpty
        : sessionsProvider.isLoadingConfirmedSessions && allSessions.isEmpty;

    final hasActiveTimeFilter = _selectedTimeFilter != TimeOfDayFilter.all;

    return WaterDropletsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A1E3D), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 2,
          automaticallyImplyLeading: false,
          title: const Text(
            'Sessions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Search (Date Picker only in List View)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.tileBorder,
                              width: 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: AppColors.textLight, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) {
                                    setState(() {
                                      _searchQuery = val;
                                    });
                                  },
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'SEARCH SESSIONS OR SPEAKERS...',
                                    hintStyle: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Only show Calendar date picker icon button in LIST VIEW mode
                      if (_viewMode == SpeakerSessionViewMode.list) ...[
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? (uniqueDates.isNotEmpty ? uniqueDates.first : DateTime.now()),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: AppColors.primary,
                                      onPrimary: Colors.white,
                                      onSurface: AppColors.textPrimary,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDate = picked;
                                if (uniqueDates.isNotEmpty) {
                                  final matchedIndex = uniqueDates.indexWhere((d) =>
                                      d.year == picked.year && d.month == picked.month && d.day == picked.day);
                                  if (matchedIndex != -1) {
                                    _selectedCalendarDayIndex = matchedIndex;
                                  }
                                }
                              });
                            }
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedDate != null ? AppColors.primary : AppColors.tileBorder,
                                width: _selectedDate != null ? 1.5 : 1,
                              ),
                              color: _selectedDate != null ? const Color(0xFFEFF6FF) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.calendar_today_outlined,
                              color: _selectedDate != null ? AppColors.primary : AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Active Filter Badges (Date / Time Range)
                  if ((_viewMode == SpeakerSessionViewMode.list && _selectedDate != null) || hasActiveTimeFilter) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (_viewMode == SpeakerSessionViewMode.list && _selectedDate != null)
                          Chip(
                            label: Text(
                              'DATE: ${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            backgroundColor: const Color(0xFFEFF6FF),
                            deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
                            onDeleted: () {
                              setState(() {
                                _selectedDate = null;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Color(0xFFBFDBFE)),
                            ),
                          ),
                        if (hasActiveTimeFilter)
                          Chip(
                            avatar: const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
                            label: Text(
                              'TIME: ${_getTimeFilterDisplayLabel()}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            backgroundColor: const Color(0xFFEFF6FF),
                            deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
                            onDeleted: () {
                              setState(() {
                                _selectedTimeFilter = TimeOfDayFilter.all;
                                _customStartTime = null;
                                _customEndTime = null;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Color(0xFFBFDBFE)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // View Mode & Filter Chips Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // View Switcher (List View vs Calendar Flow)
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.tileBorder),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _viewMode = SpeakerSessionViewMode.list;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: _viewMode == SpeakerSessionViewMode.list
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: _viewMode == SpeakerSessionViewMode.list
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(5),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.format_list_bulleted_rounded,
                                    size: 15,
                                    color: _viewMode == SpeakerSessionViewMode.list
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'LIST VIEW',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: _viewMode == SpeakerSessionViewMode.list
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: _viewMode == SpeakerSessionViewMode.list
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _viewMode = SpeakerSessionViewMode.calendar;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: _viewMode == SpeakerSessionViewMode.calendar
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: _viewMode == SpeakerSessionViewMode.calendar
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(5),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.view_timeline_outlined,
                                    size: 16,
                                    color: _viewMode == SpeakerSessionViewMode.calendar
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'CALENDAR FLOW',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: _viewMode == SpeakerSessionViewMode.calendar
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: _viewMode == SpeakerSessionViewMode.calendar
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Three Options: MY SESSIONS, ALL SESSIONS, BOOKMARKED
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'MY SESSIONS',
                          isSelected: _selectedFilter == SpeakerSessionFilter.mySessions,
                          count: mySessions.length,
                          icon: Icons.person_pin_outlined,
                          onTap: () {
                            setState(() {
                              _selectedFilter = SpeakerSessionFilter.mySessions;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'ALL SESSIONS',
                          isSelected: _selectedFilter == SpeakerSessionFilter.all,
                          count: allSessions.length,
                          onTap: () {
                            setState(() {
                              _selectedFilter = SpeakerSessionFilter.all;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'BOOKMARKED',
                          isSelected: _selectedFilter == SpeakerSessionFilter.bookmarked,
                          count: bookmarkedSessions.length,
                          icon: Icons.bookmark,
                          onTap: () {
                            setState(() {
                              _selectedFilter = SpeakerSessionFilter.bookmarked;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Time Range Filter Chips Row (ALL TIMES, MORNING, AFTERNOON, EVENING, CUSTOM RANGE)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildTimeFilterChip(
                          label: 'ALL TIMES',
                          isSelected: _selectedTimeFilter == TimeOfDayFilter.all,
                          icon: Icons.access_time_filled,
                          onTap: () {
                            setState(() {
                              _selectedTimeFilter = TimeOfDayFilter.all;
                              _customStartTime = null;
                              _customEndTime = null;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildTimeFilterChip(
                          label: 'MORNING (6 AM - 12 PM)',
                          isSelected: _selectedTimeFilter == TimeOfDayFilter.morning,
                          icon: Icons.wb_sunny_outlined,
                          onTap: () {
                            setState(() {
                              _selectedTimeFilter = TimeOfDayFilter.morning;
                              _customStartTime = null;
                              _customEndTime = null;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildTimeFilterChip(
                          label: 'AFTERNOON (12 PM - 5 PM)',
                          isSelected: _selectedTimeFilter == TimeOfDayFilter.afternoon,
                          icon: Icons.wb_twilight_outlined,
                          onTap: () {
                            setState(() {
                              _selectedTimeFilter = TimeOfDayFilter.afternoon;
                              _customStartTime = null;
                              _customEndTime = null;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildTimeFilterChip(
                          label: 'EVENING (5 PM - 10 PM)',
                          isSelected: _selectedTimeFilter == TimeOfDayFilter.evening,
                          icon: Icons.nightlight_outlined,
                          onTap: () {
                            setState(() {
                              _selectedTimeFilter = TimeOfDayFilter.evening;
                              _customStartTime = null;
                              _customEndTime = null;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildTimeFilterChip(
                          label: _selectedTimeFilter == TimeOfDayFilter.custom && _customStartTime != null && _customEndTime != null
                              ? 'RANGE: ${_formatTimeOfDay(_customStartTime!)} - ${_formatTimeOfDay(_customEndTime!)}'
                              : 'TIME RANGE...',
                          isSelected: _selectedTimeFilter == TimeOfDayFilter.custom,
                          icon: Icons.tune_rounded,
                          onTap: () => _showTimeRangePickerSheet(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Content Area (List View or Calendar View)
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchSessions(forceRefresh: true),
                color: AppColors.primary,
                backgroundColor: Colors.white,
                child: isOverallLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    : _viewMode == SpeakerSessionViewMode.list
                        ? _buildListView(filteredList)
                        : _buildCalendarView(filteredList, uniqueDates),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required int count,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(20) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.tileBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.primary : AppColors.textLight,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(30)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilterChip({
    required String label,
    required bool isSelected,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 12,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // List View Mode
  // ==========================================
  Widget _buildListView(List<SessionItem> list) {
    String sectionTitle;
    switch (_selectedFilter) {
      case SpeakerSessionFilter.mySessions:
        sectionTitle = 'Scheduled Sessions';
        break;
      case SpeakerSessionFilter.all:
        sectionTitle = 'Summit Sessions';
        break;
      case SpeakerSessionFilter.bookmarked:
        sectionTitle = 'Bookmarked Sessions';
        break;
    }

    if (list.isEmpty) {
      String emptyMessage = 'No sessions found';
      String? emptySubtitle;

      if (_selectedFilter == SpeakerSessionFilter.bookmarked) {
        emptyMessage = 'No bookmarked sessions yet';
        emptySubtitle = 'Tap the bookmark icon on any session to save it here.';
      } else if (_selectedFilter == SpeakerSessionFilter.mySessions) {
        emptyMessage = 'No speaker sessions confirmed yet';
        emptySubtitle = 'Your confirmed speaker sessions will appear here once assigned.';
      } else if (_selectedTimeFilter != TimeOfDayFilter.all) {
        emptyMessage = 'No sessions found in this time range';
        emptySubtitle = 'Try selecting another time range or tap "ALL TIMES".';
      } else if (_searchQuery.isNotEmpty) {
        emptyMessage = 'No sessions matching "$_searchQuery"';
      }

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              sectionTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedFilter == SpeakerSessionFilter.bookmarked
                          ? Icons.bookmark_border_rounded
                          : Icons.event_busy_rounded,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      emptyMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (emptySubtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        emptySubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      itemCount: list.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 14),
            child: Text(
              sectionTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          );
        }
        final session = list[index - 1];
        if (_selectedFilter == SpeakerSessionFilter.mySessions) {
          return _buildMySessionCard(session);
        } else {
          return _buildSummitSessionCard(session);
        }
      },
    );
  }

  // ==========================================
  // Calendar Flow View Mode
  // ==========================================
  Widget _buildCalendarView(List<SessionItem> filteredList, List<DateTime> uniqueDates) {
    if (uniqueDates.isEmpty) {
      return _buildListView(filteredList);
    }

    if (_selectedCalendarDayIndex >= uniqueDates.length) {
      _selectedCalendarDayIndex = 0;
    }

    final activeDate = uniqueDates[_selectedCalendarDayIndex];
    final daySessions = filteredList.where((s) => _matchesDate(s, activeDate)).toList();

    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        // Horizontal Date / Day Strip
        Container(
          height: 86,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: uniqueDates.length,
            itemBuilder: (context, index) {
              final date = uniqueDates[index];
              final isSelected = index == _selectedCalendarDayIndex;
              final dayName = dayNames[date.weekday - 1];
              final monthName = monthNames[date.month - 1];
              final sessionsOnThisDay = filteredList.where((s) => _matchesDate(s, date)).length;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCalendarDayIndex = index;
                    _selectedDate = null;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.tileBorder,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(30),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'DAY ${index + 1}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: isSelected ? Colors.white70 : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${date.day} $monthName',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white70 : AppColors.textSecondary,
                            ),
                          ),
                          if (sessionsOnThisDay > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF60A5FA) : AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Timeline Schedule Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SCHEDULE FOR ${activeDate.day} ${monthNames[activeDate.month - 1].toUpperCase()}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${daySessions.length} SESSIONS',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Timeline Sessions List
        Expanded(
          child: daySessions.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_available_outlined,
                              size: 44,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No sessions on ${activeDate.day} ${monthNames[activeDate.month - 1]}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
                  itemCount: daySessions.length,
                  itemBuilder: (context, index) {
                    final session = daySessions[index];
                    return _buildTimelineItem(session, index == daySessions.length - 1);
                  },
                ),
        ),
      ],
    );
  }

  // Timeline Item with Time Badge & Card
  Widget _buildTimelineItem(SessionItem session, bool isLast) {
    final bool isMyOwn = session.speakerName == 'You' || _selectedFilter == SpeakerSessionFilter.mySessions;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time Slot Column
        SizedBox(
          width: 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.startTime != null && session.startTime!.isNotEmpty
                    ? TimeFormatter.formatTime(session.startTime!)
                    : (session.time.contains('-') ? session.time.split('-').first.trim() : session.time),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                session.endTime != null && session.endTime!.isNotEmpty
                    ? TimeFormatter.formatTime(session.endTime!)
                    : (session.time.contains('-') ? session.time.split('-').last.trim() : ''),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
        // Timeline Dot & Line
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: session.isBookmarked ? AppColors.primary : const Color(0xFF60A5FA),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(20),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 120,
                color: Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Session Card
        Expanded(
          child: isMyOwn
              ? _buildMySessionCard(session)
              : _buildSummitSessionCard(session),
        ),
      ],
    );
  }

  // ==========================================
  // Summit Session Card (with Bookmark option)
  // ==========================================
  Widget _buildSummitSessionCard(SessionItem session) {
    final String tag = (session.keywords != null && session.keywords!.isNotEmpty)
        ? session.keywords!.split(',').first.trim()
        : 'Health Tech';
    final displayTime = _getSessionDisplayTime(session);
    final displayDate = (session.scheduleDate != null && session.scheduleDate!.isNotEmpty)
        ? session.scheduleDate!
        : session.date;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionDetailsScreen(session: session),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: session.isBookmarked ? AppColors.primary.withAlpha(40) : AppColors.tileBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Bookmark Icon Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    session.title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _handleToggleBookmark(session),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: session.isBookmarked ? const Color(0xFFEFF6FF) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _loadingBookmarks.contains(session.id)
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            session.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: session.isBookmarked ? AppColors.primary : AppColors.textLight,
                            size: 22,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Speaker Info Row
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: session.speakerBg,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: _getSpeakerProfileImageUrl(session.speakerProfileImage) != null
                      ? Image.network(
                          _getSpeakerProfileImageUrl(session.speakerProfileImage)!,
                          fit: BoxFit.cover,
                          width: 38,
                          height: 38,
                          errorBuilder: (c, o, s) => Text(
                            session.speakerInitials.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          session.speakerInitials.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.speakerName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (session.speakerTitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          session.speakerTitle.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Date & Time Range
            if (displayTime.isNotEmpty || displayDate.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textLight),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displayTime.isNotEmpty && displayDate.isNotEmpty
                          ? '$displayTime  •  $displayDate'.toUpperCase()
                          : '$displayTime$displayDate'.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Location
            if (session.location.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textLight),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      session.location.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.tileBorder),
            const SizedBox(height: 10),

            // Bottom Tag & Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (tag.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                Row(
                  children: const [
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 10,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Speaker's Own Session Card
  // ==========================================
  Widget _buildMySessionCard(SessionItem s) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final String tag = (s.keywords ?? 'Health Tech').split(',').first.trim();
    final String displaySpeaker = s.speakerName == 'You' ? auth.userName : s.speakerName;
    final myDisplayTime = _getSessionDisplayTime(s);
    final myDisplayDate = (s.scheduleDate != null && s.scheduleDate!.isNotEmpty)
        ? s.scheduleDate!
        : s.date;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: s.isBookmarked ? AppColors.primary.withAlpha(40) : AppColors.tileBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (tag.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.local_offer_outlined, size: 13, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      tag.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                )
              else
                const SizedBox(),
              GestureDetector(
                onTap: () => _handleToggleBookmark(s),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: s.isBookmarked ? const Color(0xFFEFF6FF) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _loadingBookmarks.contains(s.id)
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          s.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: s.isBookmarked ? AppColors.primary : AppColors.textLight,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            s.title.toUpperCase(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
          // Date & Time Range
          if (myDisplayTime.isNotEmpty || myDisplayDate.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    myDisplayTime.isNotEmpty && myDisplayDate.isNotEmpty
                        ? '$myDisplayTime  •  $myDisplayDate'.toUpperCase()
                        : '$myDisplayTime$myDisplayDate'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (s.location.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.location.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.tileBorder),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: AppColors.textLight),
                  const SizedBox(width: 6),
                  Text(
                    s.coordinatorName != null && s.coordinatorName!.isNotEmpty
                        ? 'Coord: ${s.coordinatorName}'
                        : 'Speaker: $displaySpeaker',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpeakerSessionDetailScreen(
                        title: s.title,
                        date: s.date,
                        time: s.time,
                        location: s.location,
                        tag: tag,
                        coordinatorName: s.coordinatorName ?? '',
                        coordinatorPhone: s.coordinatorPhone ?? '',
                        coordinatorEmail: s.coordinatorEmail ?? '',
                        description: s.description,
                        topicId: s.topicId,
                        assignmentId: s.assignmentId,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: const [
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 10,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
