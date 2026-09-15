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

class SpeakerSessionsTab extends StatefulWidget {
  const SpeakerSessionsTab({super.key});

  @override
  State<SpeakerSessionsTab> createState() => _SpeakerSessionsTabState();
}

class _SpeakerSessionsTabState extends State<SpeakerSessionsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SpeakerSessionFilter _selectedFilter = SpeakerSessionFilter.mySessions;
  bool _isCalendarView = false;
  DateTime? _selectedDate;
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

  DateTime? _parseDateTime(String? raw) {
    if (raw == null) return null;
    String str = raw.trim();
    if (str.isEmpty || str == 'null' || str == 'NA') return null;

    final parsed = DateTime.tryParse(str);
    if (parsed != null) return DateTime(parsed.year, parsed.month, parsed.day);

    str = str.replaceAll(RegExp(r'(\d+)(st|nd|rd|th)', caseSensitive: false), r'$1');
    str = str.replaceAll(',', ' ').trim();

    const fullMonths = [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december'
    ];
    const shortMonths = [
      'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
    ];

    final lower = str.toLowerCase();
    int? detectedMonth;
    for (int m = 0; m < 12; m++) {
      if (lower.contains(fullMonths[m]) || lower.contains(shortMonths[m])) {
        detectedMonth = m + 1;
        break;
      }
    }

    final numbers = RegExp(r'\d+')
        .allMatches(str)
        .map((m) => int.parse(m.group(0)!))
        .toList();

    if (detectedMonth != null) {
      if (numbers.length >= 2) {
        int day = numbers[0];
        int year = numbers[1];
        if (day > 1000) {
          final temp = day;
          day = year;
          year = temp;
        } else if (year < 100) {
          year += 2000;
        }
        return DateTime(year, detectedMonth, day);
      } else if (numbers.length == 1) {
        int day = numbers[0];
        int year = DateTime.now().year;
        return DateTime(year, detectedMonth, day);
      }
    }

    final parts = str.split(RegExp(r'[-/ ]')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 3) {
      final p0 = int.tryParse(parts[0]);
      final p1 = int.tryParse(parts[1]);
      final p2 = int.tryParse(parts[2].length > 4 ? parts[2].substring(0, 4) : parts[2]);

      if (p0 != null && p1 != null && p2 != null) {
        if (parts[0].length <= 2 && parts[2].length >= 4) {
          return DateTime(p2, p1, p0);
        }
        if (parts[0].length >= 4 && parts[2].length <= 2) {
          return DateTime(p0, p1, p2);
        }
        if (p1 <= 12 && p0 <= 31 && p2 > 2000) {
          return DateTime(p2, p1, p0);
        }
      }
    }

    return null;
  }

  int? _parseTimeToMinutes(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return null;
    try {
      String clean = timeStr.trim().toUpperCase();
      if (clean.contains('–') || clean.contains('-')) {
        final fullRange = clean;
        final startPart = clean.split(RegExp(r'[–-]')).first.trim();
        clean = startPart;
        if (!clean.contains('AM') && !clean.contains('PM')) {
          if (fullRange.contains('AM')) clean += ' AM';
          if (fullRange.contains('PM')) clean += ' PM';
        }
      }

      final hasAmPm = clean.contains('AM') || clean.contains('PM');
      final isPm = clean.contains('PM');
      final isAm = clean.contains('AM');

      final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(clean);
      if (timeMatch != null) {
        int hour = int.parse(timeMatch.group(1)!);
        int minute = int.parse(timeMatch.group(2)!);
        if (hasAmPm) {
          if (isPm && hour < 12) {
            hour += 12;
          } else if (isAm && hour == 12) {
            hour = 0;
          }
        }
        return hour * 60 + minute;
      }

      final singleHourMatch = RegExp(r'(\d{1,2})\s*(AM|PM)').firstMatch(clean);
      if (singleHourMatch != null) {
        int hour = int.parse(singleHourMatch.group(1)!);
        final ampm = singleHourMatch.group(2)!;
        if (ampm == 'PM' && hour < 12) hour += 12;
        if (ampm == 'AM' && hour == 12) hour = 0;
        return hour * 60;
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
      final m = _parseTimeToMinutes(s.time) ?? _parseTimeToMinutes(startPart);
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
      return start + 45;
    }
    return null;
  }

  bool _matchesCustomTime(SessionItem s) {
    if (_customStartTime == null && _customEndTime == null) return true;
    
    final startMin = _extractSessionStartMinutes(s);
    final endMin = _extractSessionEndMinutes(s) ?? (startMin != null ? startMin + 30 : null);
    
    if (startMin == null) return false;

    final filterStartMin = _customStartTime != null ? _customStartTime!.hour * 60 + _customStartTime!.minute : 0;
    final filterEndMin = _customEndTime != null ? _customEndTime!.hour * 60 + _customEndTime!.minute : 24 * 60;
    return startMin < filterEndMin && (endMin == null || endMin > filterStartMin);
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final minute = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  String _formatDateForDisplay(SessionItem s) {
    if (s.date.isNotEmpty) {
      return s.date;
    }
    if (s.scheduleDate != null && s.scheduleDate!.isNotEmpty) {
      final parsed = _parseDateTime(s.scheduleDate!);
      if (parsed != null) {
        const months = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
      }
      return s.scheduleDate!;
    }
    return '';
  }

  String _getSessionDisplayTime(SessionItem session) {
    if (session.startTime != null && session.startTime!.isNotEmpty &&
        session.endTime != null && session.endTime!.isNotEmpty) {
      final formattedStart = TimeFormatter.formatTime(session.startTime!);
      final formattedEnd = TimeFormatter.formatTime(session.endTime!);
      if (formattedStart.isNotEmpty && formattedEnd.isNotEmpty) {
        return '$formattedStart - $formattedEnd';
      }
    }
    if (session.time.isNotEmpty) {
      return TimeFormatter.formatTimeRange(session.time);
    }
    if (session.startTime != null && session.startTime!.isNotEmpty) {
      return TimeFormatter.formatTime(session.startTime!);
    }
    return '';
  }

  Future<void> _showDateAndTimeFilterSheet(List<DateTime> uniqueDates) async {
    DateTime? tempDate = _selectedDate;
    TimeOfDay? tempStart = _customStartTime;
    TimeOfDay? tempEnd = _customEndTime;

    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final presets = [
      {'label': 'Morning', 'range': '06:00 AM - 12:00 PM', 'start': const TimeOfDay(hour: 6, minute: 0), 'end': const TimeOfDay(hour: 12, minute: 0)},
      {'label': 'Afternoon', 'range': '12:00 PM - 05:00 PM', 'start': const TimeOfDay(hour: 12, minute: 0), 'end': const TimeOfDay(hour: 17, minute: 0)},
      {'label': 'Evening', 'range': '05:00 PM - 10:00 PM', 'start': const TimeOfDay(hour: 17, minute: 0), 'end': const TimeOfDay(hour: 22, minute: 0)},
      {'label': 'Full Day', 'range': '08:00 AM - 08:00 PM', 'start': const TimeOfDay(hour: 8, minute: 0), 'end': const TimeOfDay(hour: 20, minute: 0)},
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
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(sheetContext).viewInsets.bottom +
                    MediaQuery.of(sheetContext).padding.bottom +
                    28,
              ),
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
                            Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Filter by Date & Timings',
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

                    // 1. DATE FILTER SECTION
                    const Text(
                      'FILTER BY DATE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          // All Dates chip
                          GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                tempDate = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: tempDate == null ? const Color(0xFFEFF6FF) : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: tempDate == null ? AppColors.primary : AppColors.tileBorder,
                                  width: tempDate == null ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                'ALL DATES',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: tempDate == null ? FontWeight.bold : FontWeight.w600,
                                  color: tempDate == null ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Specific Conference Dates
                          ...uniqueDates.map((date) {
                            final isDateSelected = tempDate != null &&
                                tempDate!.year == date.year &&
                                tempDate!.month == date.month &&
                                tempDate!.day == date.day;
                            final dayName = dayNames[date.weekday - 1];
                            final monthName = monthNames[date.month - 1];

                            return GestureDetector(
                              onTap: () {
                                setSheetState(() {
                                  tempDate = date;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: isDateSelected ? const Color(0xFFEFF6FF) : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDateSelected ? AppColors.primary : AppColors.tileBorder,
                                    width: isDateSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  '${date.day} $monthName ($dayName)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isDateSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isDateSelected ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          }),
                          // Custom Pick Date Button
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: sheetContext,
                                initialDate: tempDate ?? (uniqueDates.isNotEmpty ? uniqueDates.first : DateTime.now()),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  tempDate = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.tileBorder,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.primary),
                                  SizedBox(width: 6),
                                  Text(
                                    'Custom Date...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2. TIMING SLOTS SECTION
                    const Text(
                      'FILTER BY TIMING SLOTS',
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
                        final isPresetSelected = tempStart != null &&
                            tempEnd != null &&
                            tempStart!.hour == pStart.hour &&
                            tempStart!.minute == pStart.minute &&
                            tempEnd!.hour == pEnd.hour &&
                            tempEnd!.minute == pEnd.minute;

                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              if (isPresetSelected) {
                                tempStart = null;
                                tempEnd = null;
                              } else {
                                tempStart = pStart;
                                tempEnd = pEnd;
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
                                    fontSize: 12,
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

                    // 3. CUSTOM TIME RANGE
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
                                initialTime: tempStart ?? const TimeOfDay(hour: 9, minute: 0),
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
                                border: Border.all(
                                  color: tempStart != null ? AppColors.primary : AppColors.tileBorder,
                                  width: 1.2,
                                ),
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
                                        tempStart != null ? _formatTimeOfDay(tempStart!) : 'Set Start',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: tempStart != null ? AppColors.primary : AppColors.textLight,
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
                                initialTime: tempEnd ?? const TimeOfDay(hour: 17, minute: 0),
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
                                border: Border.all(
                                  color: tempEnd != null ? AppColors.primary : AppColors.tileBorder,
                                  width: 1.2,
                                ),
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
                                        tempEnd != null ? _formatTimeOfDay(tempEnd!) : 'Set End',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: tempEnd != null ? AppColors.primary : AppColors.textLight,
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
                                _selectedDate = null;
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
                                _selectedDate = tempDate;
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
                              'APPLY FILTERS',
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
    DateTime? sessionDt;
    if (session.scheduleDate != null && session.scheduleDate!.trim().isNotEmpty) {
      sessionDt = _parseDateTime(session.scheduleDate!);
    }
    if (sessionDt == null && session.date.trim().isNotEmpty) {
      sessionDt = _parseDateTime(session.date);
    }

    if (sessionDt != null) {
      return sessionDt.year == targetDate.year &&
          sessionDt.month == targetDate.month &&
          sessionDt.day == targetDate.day;
    }

    final yyyymmdd = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
    final ddmmyyyy = "${targetDate.day.toString().padLeft(2, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.year}";
    final slashFormat = "${targetDate.day.toString().padLeft(2, '0')}/${targetDate.month.toString().padLeft(2, '0')}/${targetDate.year}";

    final sDate = session.scheduleDate?.trim() ?? '';
    final dDate = session.date.trim();

    return (sDate.isNotEmpty && (sDate.contains(yyyymmdd) || sDate.contains(ddmmyyyy) || sDate.contains(slashFormat))) ||
        (dDate.isNotEmpty && (dDate.contains(yyyymmdd) || dDate.contains(ddmmyyyy) || dDate.contains(slashFormat)));
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
      DateTime? parsed;
      if (s.scheduleDate != null && s.scheduleDate!.trim().isNotEmpty) {
        parsed = _parseDateTime(s.scheduleDate!);
      }
      if (parsed == null && s.date.trim().isNotEmpty) {
        parsed = _parseDateTime(s.date);
      }
      if (parsed != null) {
        final key = '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
        if (!uniqueMap.containsKey(key)) {
          uniqueMap[key] = DateTime(parsed.year, parsed.month, parsed.day);
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

    // Extract calendar unique dates from available sessions (first try current list, fallback to combined)
    final currentDates = _extractUniqueDates(currentList);
    final combinedDates = _extractUniqueDates([...mySessions, ...allSessions]);
    final uniqueDates = currentDates.isNotEmpty ? currentDates : combinedDates;

    // Apply Search, Date, and Time Filter in List View
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
      if (!_isCalendarView && _selectedDate != null) {
        matchesDateFilter = _matchesDate(s, _selectedDate!);
      }

      bool matchesTimeFilter = true;
      if (!_isCalendarView && (_customStartTime != null || _customEndTime != null)) {
        matchesTimeFilter = _matchesCustomTime(s);
      }

      return matchesSearch && matchesDateFilter && matchesTimeFilter;
    }).toList();

    final bool isOverallLoading = _selectedFilter == SpeakerSessionFilter.mySessions
        ? sessionsProvider.isLoadingMySessions && mySessions.isEmpty
        : sessionsProvider.isLoadingConfirmedSessions && allSessions.isEmpty;

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
          actions: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isCalendarView = !_isCalendarView;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _isCalendarView ? Colors.white : Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isCalendarView ? Colors.white : Colors.white.withAlpha(60),
                    width: 1,
                  ),
                  boxShadow: _isCalendarView
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCalendarView ? Icons.calendar_month : Icons.calendar_month_outlined,
                      color: _isCalendarView ? AppColors.primary : Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isCalendarView ? 'List View' : 'Calendar View',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isCalendarView ? AppColors.primary : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Search and Date/Timing Filter (in List View)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Search Bar
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
                                      fontSize: 12,
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  child: const Icon(Icons.clear, color: AppColors.textLight, size: 18),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (!_isCalendarView) ...[
                        const SizedBox(width: 10),
                        // Calendar & Timings Filter Icon Button beside search
                        GestureDetector(
                          onTap: () => _showDateAndTimeFilterSheet(uniqueDates),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: (_selectedDate != null || _customStartTime != null || _customEndTime != null)
                                  ? AppColors.primary
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: (_selectedDate != null || _customStartTime != null || _customEndTime != null)
                                    ? AppColors.primary
                                    : AppColors.tileBorder,
                                width: 1.2,
                              ),
                              boxShadow: (_selectedDate != null || _customStartTime != null || _customEndTime != null)
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withAlpha(50),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.tune_rounded,
                                  color: (_selectedDate != null || _customStartTime != null || _customEndTime != null)
                                      ? Colors.white
                                      : AppColors.primary,
                                  size: 22,
                                ),
                                if (_selectedDate != null || _customStartTime != null || _customEndTime != null)
                                  Positioned(
                                    top: 9,
                                    right: 9,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Filter Chips: MY SESSIONS, ALL SESSIONS, BOOKMARKED
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
                          icon: Icons.groups_outlined,
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

                  // Active Filter Indicator Pill (Clear with 1 tap)
                  if (!_isCalendarView && (_selectedDate != null || _customStartTime != null || _customEndTime != null)) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_alt_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              [
                                if (_selectedDate != null)
                                  '📅 ${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                                if (_customStartTime != null && _customEndTime != null)
                                  '🕒 ${_formatTimeOfDay(_customStartTime!)} - ${_formatTimeOfDay(_customEndTime!)}'
                                else if (_customStartTime != null)
                                  '🕒 From ${_formatTimeOfDay(_customStartTime!)}'
                                else if (_customEndTime != null)
                                  '🕒 Until ${_formatTimeOfDay(_customEndTime!)}',
                              ].join('  •  '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = null;
                                _customStartTime = null;
                                _customEndTime = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.close, size: 12, color: AppColors.primary),
                                  SizedBox(width: 2),
                                  Text(
                                    'Clear',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                    : !_isCalendarView
                        ? _buildListView(filteredList)
                        : _buildCalendarView(currentList, uniqueDates),
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

  // ==========================================
  // List View Mode
  // ==========================================
  Widget _buildListView(List<SessionItem> list) {
    String sectionTitle;
    switch (_selectedFilter) {
      case SpeakerSessionFilter.mySessions:
        sectionTitle = 'My Sessions';
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
      } else if (_selectedDate != null || _customStartTime != null || _customEndTime != null) {
        emptyMessage = 'No sessions match the selected date & timings filter';
        emptySubtitle = 'Try resetting or adjusting the date or timings filter above.';
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
      padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).padding.bottom + 36),
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
  // Calendar Flow View Mode (Neat Flow with Prominent Time)
  // ==========================================
  Widget _buildCalendarView(List<SessionItem> baseList, List<DateTime> uniqueDates) {
    if (uniqueDates.isEmpty) {
      return _buildListView(baseList);
    }

    if (_selectedCalendarDayIndex >= uniqueDates.length) {
      _selectedCalendarDayIndex = 0;
    }

    final query = _searchQuery.toLowerCase().trim();
    final activeDate = uniqueDates[_selectedCalendarDayIndex];
    final daySessions = baseList.where((s) {
      final matchesSearch = query.isEmpty ||
          s.title.toLowerCase().contains(query) ||
          s.speakerName.toLowerCase().contains(query) ||
          s.speakerTitle.toLowerCase().contains(query) ||
          s.location.toLowerCase().contains(query) ||
          (s.keywords ?? '').toLowerCase().contains(query);

      return matchesSearch && _matchesDate(s, activeDate);
    }).toList();

    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal Date / Day Strip
        Container(
          height: 84,
          padding: const EdgeInsets.symmetric(vertical: 6),
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
              final sessionsOnThisDay = baseList.where((s) => _matchesDate(s, date)).length;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCalendarDayIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 74,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
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
                      color: isSelected ? AppColors.primary : AppColors.tileBorder,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(40),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withAlpha(3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
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

        // Schedule Header (Date & Count)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Text(
                  '${daySessions.length} ${daySessions.length == 1 ? 'SESSION' : 'SESSIONS'}',
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

        // Sessions List with Neat Flow (Full Width, Prominent Time)
        Expanded(
          child: daySessions.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy_rounded,
                                size: 48,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'No sessions on ${activeDate.day} ${monthNames[activeDate.month - 1]}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: EdgeInsets.fromLTRB(10, 6, 14, MediaQuery.of(context).padding.bottom + 36),
                  itemCount: daySessions.length,
                  itemBuilder: (context, index) {
                    final session = daySessions[index];
                    return _buildCalendarTimelineItem(
                      session,
                      isFirst: index == 0,
                      isLast: index == daySessions.length - 1,
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // Calendar Timeline Item (Time in Middle Beside Card)
  // ==========================================
  Map<String, String> _extractTimelineTimeParts(SessionItem session) {
    String displayTime = _getSessionDisplayTime(session);
    if (displayTime.isEmpty) {
      return {'start': '--:--', 'period': '', 'end': ''};
    }

    final parts = displayTime.split(RegExp(r'[–-]'));
    final startFull = parts[0].trim();
    final endFull = parts.length > 1 ? parts[1].trim() : '';

    final match = RegExp(r'(\d{1,2}:\d{2})\s*(AM|PM)?', caseSensitive: false).firstMatch(startFull);
    if (match != null) {
      final t = match.group(1) ?? '';
      final p = (match.group(2) ?? '').toUpperCase();
      return {
        'start': t,
        'period': p,
        'end': endFull,
      };
    }

    return {
      'start': startFull,
      'period': '',
      'end': endFull,
    };
  }

  Widget _buildCalendarTimelineItem(SessionItem session, {required bool isFirst, required bool isLast}) {
    final timeParts = _extractTimelineTimeParts(session);
    final isMySession = _selectedFilter == SpeakerSessionFilter.mySessions;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Time Column on Left (Vertically Centered in Middle)
          SizedBox(
            width: 52,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeParts['start'] ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0A1E3D),
                    letterSpacing: -0.2,
                  ),
                ),
                if ((timeParts['period'] ?? '').isNotEmpty)
                  Text(
                    timeParts['period'] ?? '',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                if ((timeParts['end'] ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'to ${timeParts['end']!}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLight,
                      height: 1.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 2. Timeline Rail (Top Line + Center Dot + Bottom Line)
          Column(
            children: [
              // Top Connecting Line
              Expanded(
                child: isFirst
                    ? const SizedBox()
                    : Container(
                        width: 2,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(90),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
              ),
              // Center Node / Circle
              Container(
                width: 11,
                height: 11,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.primary, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(50),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              // Bottom Connecting Line
              Expanded(
                child: isLast
                    ? const SizedBox()
                    : Container(
                        width: 2,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(90),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // 3. Right Card (Sharp Edges, Wider / Increased Size)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: isMySession
                  ? _buildCalendarMySessionCard(session)
                  : _buildCalendarSessionCard(session),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSessionCard(SessionItem session) {
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
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: session.isBookmarked ? AppColors.primary.withAlpha(50) : AppColors.tileBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title on Left, Bookmark on Right
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    session.title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _handleToggleBookmark(session),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: session.isBookmarked ? const Color(0xFFEFF6FF) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: _loadingBookmarks.contains(session.id)
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            session.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: session.isBookmarked ? AppColors.primary : AppColors.textLight,
                            size: 18,
                          ),
                  ),
                ),
              ],
            ),

            // Speaker Row (if exists)
            if (session.speakerName.isNotEmpty && session.speakerName != 'NA') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
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
                            width: 28,
                            height: 28,
                            errorBuilder: (c, o, s) => Text(
                              session.speakerInitials.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            session.speakerInitials.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.speakerName.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (session.speakerTitle.isNotEmpty) ...[
                          Text(
                            session.speakerTitle.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],

            // Location
            if (session.location.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      session.location.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.tileBorder),
            const SizedBox(height: 6),

            // Bottom Action
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 8,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarMySessionCard(SessionItem s) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final String displaySpeaker = s.speakerName == 'You' ? auth.userName : s.speakerName;
    final myDisplayTime = _getSessionDisplayTime(s);
    final myDisplayDate = _formatDateForDisplay(s);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpeakerSessionDetailScreen(
              title: s.title,
              date: myDisplayDate.isNotEmpty ? myDisplayDate : (s.date.isNotEmpty ? s.date : (s.scheduleDate ?? '')),
              time: myDisplayTime.isNotEmpty ? myDisplayTime : (s.time.isNotEmpty ? s.time : (s.startTime != null && s.endTime != null ? '${s.startTime} - ${s.endTime}' : '')),
              location: s.location,
              tag: '',
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
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.tileBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              s.title.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),

            // Speaker Row
            if (displaySpeaker.isNotEmpty && displaySpeaker != 'NA') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: s.speakerBg,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.center,
                    child: _getSpeakerProfileImageUrl(s.speakerProfileImage) != null
                        ? Image.network(
                            _getSpeakerProfileImageUrl(s.speakerProfileImage)!,
                            fit: BoxFit.cover,
                            width: 28,
                            height: 28,
                            errorBuilder: (ctx, err, stack) => Text(
                              s.speakerInitials.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            s.speakerInitials.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displaySpeaker.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Location
            if (s.location.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      s.location.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.tileBorder),
            const SizedBox(height: 6),

            // Bottom Action
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 8,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Summit Session Card (with Date & Time in Last Row)
  // ==========================================
  Widget _buildSummitSessionCard(SessionItem session) {
    final displayTime = _getSessionDisplayTime(session);
    final displayDate = _formatDateForDisplay(session);

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
            // Top Row: Title on Left & Bookmark Action on Right
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
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            session.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: session.isBookmarked ? AppColors.primary : AppColors.textLight,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),

            // Speaker Info Row
            if (session.speakerName.isNotEmpty && session.speakerName != 'NA') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
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
                            width: 36,
                            height: 36,
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
                            fontSize: 13,
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
            ],

            // Location
            if (session.location.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textLight),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      session.location.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
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

            // Last Row: Clean Highlighted Date & Time (Stacked) on Left, Details on Right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (displayDate.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              displayDate.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      if (displayDate.isNotEmpty && displayTime.isNotEmpty)
                        const SizedBox(height: 4),
                      if (displayTime.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_filled_rounded, size: 13, color: Color(0xFFD97706)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                displayTime.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 3),
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
  // Speaker's Own Session Card (with Date & Time in Last Row)
  // ==========================================
  Widget _buildMySessionCard(SessionItem s) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final String displaySpeaker = s.speakerName == 'You' ? auth.userName : s.speakerName;
    final myDisplayTime = _getSessionDisplayTime(s);
    final myDisplayDate = _formatDateForDisplay(s);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.tileBorder,
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
          // Title
          Text(
            s.title.toUpperCase(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),

          // Speaker / Coordinator Info
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.textLight),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  s.coordinatorName != null && s.coordinatorName!.isNotEmpty
                      ? 'Coord: ${s.coordinatorName}'
                      : 'Speaker: $displaySpeaker',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          // Location
          if (s.location.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textLight),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    s.location.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
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

          // Last Row: Clean Highlighted Date & Time (Stacked) on Left, Details on Right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (myDisplayDate.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            myDisplayDate.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    if (myDisplayDate.isNotEmpty && myDisplayTime.isNotEmpty)
                      const SizedBox(height: 4),
                    if (myDisplayTime.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_filled_rounded, size: 13, color: Color(0xFFD97706)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              myDisplayTime.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpeakerSessionDetailScreen(
                        title: s.title,
                        date: myDisplayDate.isNotEmpty ? myDisplayDate : (s.date.isNotEmpty ? s.date : (s.scheduleDate ?? '')),
                        time: myDisplayTime.isNotEmpty ? myDisplayTime : (s.time.isNotEmpty ? s.time : (s.startTime != null && s.endTime != null ? '${s.startTime} - ${s.endTime}' : '')),
                        location: s.location,
                        tag: '',
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
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 3),
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
