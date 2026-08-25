class TimeFormatter {
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const List<String> _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// Formats a [DateTime] into "22 January 2002 12:24 PM" format.
  static String formatDateTime(DateTime dt) {
    final day = dt.day.toString();
    final monthName = _months[dt.month - 1];
    final year = dt.year.toString();
    
    int hour = dt.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }
    
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    
    return '$day $monthName $year $hourStr:$minuteStr $period';
  }

  /// Parses any date string and formats it neat. If a time range is provided, it handles it gracefully.
  /// Standard neat format: "22 January 2002 12:24 PM"
  static String formatString(String dateStr, {String? timeStr}) {
    if (dateStr.isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) {
        if (timeStr != null && timeStr.isNotEmpty) {
          final timeParsed = _parseTimeOfDay(timeStr);
          if (timeParsed != null) {
            final dt = DateTime(
              parsed.year,
              parsed.month,
              parsed.day,
              timeParsed.hour,
              timeParsed.minute,
            );
            return formatDateTime(dt);
          }
        }
        return formatDateTime(parsed);
      }

      // Handle custom structures e.g. "March 16, 2026"
      String cleaned = dateStr.replaceAll(',', '').trim();
      List<String> parts = cleaned.split(RegExp(r'\s+'));
      
      int? day;
      int? month;
      int? year;
      int hour = 12;
      int minute = 0;

      // Look for Month
      for (int i = 0; i < parts.length; i++) {
        final part = parts[i].toLowerCase();
        for (int m = 0; m < 12; m++) {
          if (_months[m].toLowerCase() == part || _shortMonths[m].toLowerCase() == part) {
            month = m + 1;
            break;
          }
        }
      }

      // If month still null, try startsWith search
      if (month == null) {
        for (int i = 0; i < parts.length; i++) {
          final part = parts[i].toLowerCase();
          for (int m = 0; m < 12; m++) {
            if (_months[m].toLowerCase().startsWith(part) || _shortMonths[m].toLowerCase().startsWith(part)) {
              if (part.length >= 3) {
                month = m + 1;
                break;
              }
            }
          }
        }
      }

      // Extract numbers
      List<int> numbers = [];
      for (var part in parts) {
        final cleanedPart = part.replaceAll(RegExp(r'[^0-9]'), '');
        final num = int.tryParse(cleanedPart);
        if (num != null) {
          numbers.add(num);
        }
      }

      if (month != null) {
        if (numbers.length >= 2) {
          // E.g. March 16 2026 -> [16, 2026]
          day = numbers.firstWhere((n) => n <= 31, orElse: () => 1);
          year = numbers.firstWhere((n) => n > 2000, orElse: () => DateTime.now().year);
        } else if (numbers.length == 1) {
          day = numbers[0];
          year = DateTime.now().year;
        }
      } else {
        // Try parsing parts as numbers: e.g. "16-03-2026" or "16/03/2026"
        final cleanParts = dateStr.split(RegExp(r'[-/ ]'));
        if (cleanParts.length >= 3) {
          if (cleanParts[0].length <= 2 && cleanParts[2].length >= 4) {
            day = int.tryParse(cleanParts[0]);
            month = int.tryParse(cleanParts[1]);
            year = int.tryParse(cleanParts[2].substring(0, 4));
          } else if (cleanParts[0].length == 4 && cleanParts[2].length <= 2) {
            year = int.tryParse(cleanParts[0]);
            month = int.tryParse(cleanParts[1]);
            day = int.tryParse(cleanParts[2].substring(0, 2));
          }
        }
      }

      // Check if time is explicitly passed in timeStr, or embedded in dateStr
      final targetTimeStr = timeStr ?? dateStr;
      if (targetTimeStr.isNotEmpty) {
        final parsedTime = _parseTimeOfDay(targetTimeStr);
        if (parsedTime != null) {
          hour = parsedTime.hour;
          minute = parsedTime.minute;
        }
      }

      if (day != null && month != null && year != null) {
        final dt = DateTime(year, month, day, hour, minute);
        return formatDateTime(dt);
      }
    } catch (_) {}

    // Fallback: If parsing fails, cleanly construct a format or return original
    return dateStr;
  }

  // Internal helper to extract hour and minute from strings like "02:00 PM" or "02:00 - 03:30 PM"
  static _TimeOfDay? _parseTimeOfDay(String timeStr) {
    try {
      String cleanTime = timeStr.toUpperCase();
      // If it is a range "02:00 - 03:30 PM", split and use start time
      if (cleanTime.contains('–') || cleanTime.contains('-')) {
        cleanTime = cleanTime.split(RegExp(r'[–-]')).first.trim();
        // If the start time does not have AM/PM but the end time does, carry it over
        if (!cleanTime.contains('AM') && !cleanTime.contains('PM')) {
          if (timeStr.toUpperCase().contains('AM')) {
            cleanTime += ' AM';
          } else if (timeStr.toUpperCase().contains('PM')) {
            cleanTime += ' PM';
          }
        }
      }

      final timeReg = RegExp(r'(\d{1,2}):(\d{2})');
      final match = timeReg.firstMatch(cleanTime);
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        final int minute = int.parse(match.group(2)!);
        
        if (cleanTime.contains('PM') && hour < 12) {
          hour += 12;
        } else if (cleanTime.contains('AM') && hour == 12) {
          hour = 0;
        }
        return _TimeOfDay(hour, minute);
      }
    } catch (_) {}
    return null;
  }

  /// Formats a single time string (e.g. "09:00:00", "13:30:00", "09:00") into "09:00 AM" or "01:30 PM".
  static String formatTime(String timeStr) {
    if (timeStr.isEmpty) return '';
    final upper = timeStr.trim().toUpperCase();
    if (upper.contains('AM') || upper.contains('PM')) {
      return timeStr;
    }
    try {
      final parts = upper.split(':');
      if (parts.isNotEmpty) {
        int? hour = int.tryParse(parts[0]);
        int minute = 0;
        if (parts.length > 1) {
          minute = int.tryParse(parts[1]) ?? 0;
        }
        if (hour != null) {
          final period = hour >= 12 ? 'PM' : 'AM';
          final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
          final hourStr = displayHour.toString().padLeft(2, '0');
          final minuteStr = minute.toString().padLeft(2, '0');
          return '$hourStr:$minuteStr $period';
        }
      }
    } catch (_) {}
    return timeStr;
  }

  /// Formats a time range string (e.g. "09:00:00 - 10:00:00") into "09:00 AM - 10:00 AM".
  static String formatTimeRange(String timeRange) {
    if (timeRange.isEmpty) return '';
    if (timeRange.contains('–') || timeRange.contains('-')) {
      final parts = timeRange.split(RegExp(r'[–-]'));
      if (parts.length == 2) {
        final start = formatTime(parts[0]);
        final end = formatTime(parts[1]);
        if (start.isNotEmpty && end.isNotEmpty) {
          return '$start - $end';
        }
      }
    }
    return formatTime(timeRange);
  }

  /// Formats a date string into a human-readable relative time (e.g. "5m ago", "2h ago", "1d ago").
  static String formatRelativeTime(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '';
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return dateStr;
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inSeconds < 60) {
        return 'Just now';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        return formatDateTime(dt);
      }
    } catch (_) {
      return dateStr;
    }
  }
}



class _TimeOfDay {
  final int hour;
  final int minute;
  _TimeOfDay(this.hour, this.minute);
}
