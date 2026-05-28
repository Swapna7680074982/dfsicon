import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dfsicon/domain/api_service.dart';
import 'package:dfsicon/utils/custom_logger.dart';
import '../main.dart';

class SessionItem {
  final int id;
  final String title;
  final String speakerName;
  final String speakerTitle;
  final String speakerInitials;
  final Color speakerBg;
  final String date;
  final String time;
  final String location;
  bool isBookmarked;
  bool isAdded;

  // Real API fields
  final String? description;
  final String? thumbnail;
  final String? keywords;
  final String? acceptedFilePath;
  final String? venueAddress;
  final String? summitTitle;

  SessionItem({
    required this.id,
    required this.title,
    required this.speakerName,
    required this.speakerTitle,
    required this.speakerInitials,
    required this.speakerBg,
    required this.date,
    required this.time,
    required this.location,
    this.isBookmarked = false,
    this.isAdded = false,
    this.description,
    this.thumbnail,
    this.keywords,
    this.acceptedFilePath,
    this.venueAddress,
    this.summitTitle,
  });
}

class VenueInfo {
  final String venueId;
  final String venueName;
  final String address;
  final String totalHalls;
  final String sessionsPerDay;
  final String stateName;
  final String cityName;

  VenueInfo({
    required this.venueId,
    required this.venueName,
    required this.address,
    required this.totalHalls,
    required this.sessionsPerDay,
    required this.stateName,
    required this.cityName,
  });
}

class HallItem {
  final String hallId;
  final String hallName;
  final String hallCapacity;

  HallItem({
    required this.hallId,
    required this.hallName,
    required this.hallCapacity,
  });
}

class SessionsProvider extends ChangeNotifier {
  VenueInfo? _venueInfo;
  List<HallItem> _halls = [];

  VenueInfo? get venueInfo => _venueInfo;
  List<HallItem> get halls => _halls;

  String _searchQuery = '';
  bool _showOnlyBookmarked = false;
  bool _isLoading = false;
  String? _errorMessage;

  List<SessionItem> _sessions = [];
  List<SessionItem> _mySessions = []; // Speaker-specific confirmed sessions

  Future<bool>? _activeVenueFuture;
  Future<bool>? _activeSessionsFuture;
  Future<bool>? _activeMySessionsFuture;

  String get searchQuery => _searchQuery;
  bool get showOnlyBookmarked => _showOnlyBookmarked;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<SessionItem> get sessions => _sessions;
  List<SessionItem> get mySessions => _mySessions;

  List<SessionItem> get filteredSessions {
    final query = _searchQuery.toLowerCase().trim();
    List<SessionItem> list = _sessions;
    if (_showOnlyBookmarked) {
      list = list.where((session) => session.isBookmarked).toList();
    }
    if (query.isEmpty) return list;
    return list.where((session) {
      return session.title.toLowerCase().contains(query) ||
          session.speakerName.toLowerCase().contains(query) ||
          session.speakerTitle.toLowerCase().contains(query);
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setShowOnlyBookmarked(bool val) {
    _showOnlyBookmarked = val;
    notifyListeners();
  }

  void toggleBookmark(int sessionId) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _sessions[index].isBookmarked = !_sessions[index].isBookmarked;
      notifyListeners();
    }
  }

  void toggleAdded(int sessionId) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _sessions[index].isAdded = !_sessions[index].isAdded;
      notifyListeners();
    }
  }

  // ==========================================
  // Fetch Confirmed Sessions (Delegate & Speaker)
  // ==========================================
  static dynamic _safeJsonDecode(String body) {
    final trimmed = body.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      return json.decode(trimmed);
    }
    
    final int braceIndex = trimmed.indexOf('{');
    final int bracketIndex = trimmed.indexOf('[');
    
    int startIndex = -1;
    if (braceIndex != -1 && bracketIndex != -1) {
      startIndex = braceIndex < bracketIndex ? braceIndex : bracketIndex;
    } else if (braceIndex != -1) {
      startIndex = braceIndex;
    } else if (bracketIndex != -1) {
      startIndex = bracketIndex;
    }
    
    if (startIndex != -1) {
      final jsonPart = trimmed.substring(startIndex);
      try {
        return json.decode(jsonPart);
      } catch (e) {
        CustomLogger.logError('Failed to parse fallback JSON from HTML prepended response', e, null);
      }
    }
    
    return json.decode(trimmed);
  }

  Future<bool> fetchVenueAndHalls(String summitId, String accessToken) {
    if (accessToken.isEmpty || summitId.isEmpty) return Future.value(false);
    if (_activeVenueFuture != null) {
      return _activeVenueFuture!;
    }
    _activeVenueFuture = _fetchVenueAndHallsInternal(summitId, accessToken);
    return _activeVenueFuture!;
  }

  Future<bool> _fetchVenueAndHallsInternal(String summitId, String accessToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchVenueAndHalls(
        summitId: summitId,
        accessToken: accessToken,
      );
      _isLoading = false;
      _activeVenueFuture = null;

      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }

      if (response.statusCode == 200) {
        final data = _safeJsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final dynamic venueJson = data['data']['venue'];
          if (venueJson != null) {
            _venueInfo = VenueInfo(
              venueId: venueJson['venue_id']?.toString() ?? '',
              venueName: venueJson['venue_name']?.toString() ?? '',
              address: venueJson['address']?.toString() ?? '',
              totalHalls: venueJson['total_halls']?.toString() ?? '',
              sessionsPerDay: venueJson['sessions_per_day']?.toString() ?? '',
              stateName: venueJson['state_name']?.toString() ?? '',
              cityName: venueJson['city_name']?.toString() ?? '',
            );
          }

          final List hallsJson = data['data']['halls'] ?? [];
          _halls = hallsJson.map((h) {
            return HallItem(
              hallId: h['hall_id']?.toString() ?? '',
              hallName: h['hall_name']?.toString() ?? '',
              hallCapacity: h['hall_capacity']?.toString() ?? '',
            );
          }).toList();

          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Failed to load venue and halls';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch venue and halls failed', e, stack);
      _isLoading = false;
      _activeVenueFuture = null;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchConfirmedSessions(String accessToken) {
    if (accessToken.isEmpty) return Future.value(false);
    if (_activeSessionsFuture != null) {
      return _activeSessionsFuture!;
    }
    _activeSessionsFuture = _fetchConfirmedSessionsInternal(accessToken);
    return _activeSessionsFuture!;
  }

  Future<bool> _fetchConfirmedSessionsInternal(String accessToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchConfirmedSessions(accessToken: accessToken);
      _isLoading = false;
      _activeSessionsFuture = null;
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }
      if (response.statusCode == 200) {
        final data = _safeJsonDecode(response.body);
        if (data['status'] == true) {
          final List sessionsJson = data['data'] ?? data['sessions'] ?? [];
          _sessions = sessionsJson.asMap().entries.map((entry) {
            return _mapJsonToSession(entry.value, entry.key);
          }).toList();
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Failed to load sessions';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch confirmed sessions failed', e, stack);
      _isLoading = false;
      _activeSessionsFuture = null;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==========================================
  // Fetch Speaker Confirmed Sessions
  // ==========================================
  Future<bool> fetchMyConfirmedSessions(String accessToken) {
    if (accessToken.isEmpty) return Future.value(false);
    if (_activeMySessionsFuture != null) {
      return _activeMySessionsFuture!;
    }
    _activeMySessionsFuture = _fetchMyConfirmedSessionsInternal(accessToken);
    return _activeMySessionsFuture!;
  }

  Future<bool> _fetchMyConfirmedSessionsInternal(String accessToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchMyConfirmedSessions(accessToken: accessToken);
      _isLoading = false;
      _activeMySessionsFuture = null;
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }
      if (response.statusCode == 200) {
        final data = _safeJsonDecode(response.body);
        if (data['status'] == true) {
          final List sessionsJson = data['data'] ?? data['sessions'] ?? [];
          _mySessions = sessionsJson.asMap().entries.map((entry) {
            return _mapJsonToSession(entry.value, entry.key);
          }).toList();
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Failed to load speaker sessions';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch speaker confirmed sessions failed', e, stack);
      _isLoading = false;
      _activeMySessionsFuture = null;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==========================================
  // Helper Mappers
  // ==========================================
  static String _getInitials(String name) {
    if (name.isEmpty) return 'SS';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  static Color _getColorForIndex(int index) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Purple
    ];
    return colors[index % colors.length];
  }

  SessionItem _mapJsonToSession(Map<String, dynamic> json, int index) {
    final abstractId = json['abstract_id']?.toString() ?? '';
    final id = int.tryParse(abstractId) ?? index;
    final title = json['abstract_title']?.toString() ?? 'Session';
    final speakerName = json['speaker_name']?.toString() ?? 'TBA';
    final designation = json['designation']?.toString() ?? '';
    final clinicName = json['hospital_clinic_name']?.toString() ?? '';
    final speakerTitle = designation.isNotEmpty && clinicName.isNotEmpty
        ? '$designation, $clinicName'
        : (designation.isNotEmpty ? designation : (clinicName.isNotEmpty ? clinicName : 'Speaker'));

    String displayDate = '';
    final scheduleDateStr = json['schedule_date']?.toString() ?? '';
    if (scheduleDateStr.isNotEmpty) {
      try {
        final dt = DateTime.tryParse(scheduleDateStr);
        if (dt != null) {
          final months = [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
          ];
          displayDate = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
        } else {
          displayDate = scheduleDateStr;
        }
      } catch (_) {
        displayDate = scheduleDateStr;
      }
    }

    final slotName = json['slot_name']?.toString() ?? '';
    final timeStr = slotName.isNotEmpty ? slotName : 'TBA';
    final hallName = json['hall_name']?.toString() ?? 'TBA';
    final venueName = json['venue_name']?.toString() ?? '';
    final locationStr = venueName.isNotEmpty
        ? '$hallName, $venueName'
        : hallName;

    return SessionItem(
      id: id,
      title: title,
      speakerName: speakerName,
      speakerTitle: speakerTitle,
      speakerInitials: _getInitials(speakerName),
      speakerBg: _getColorForIndex(index),
      date: displayDate.isNotEmpty ? displayDate : 'TBA',
      time: timeStr,
      location: locationStr,
      isBookmarked: false,
      isAdded: false,
      description: json['abstract_description']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      keywords: json['keywords']?.toString(),
      acceptedFilePath: json['accepted_file_path']?.toString(),
      venueAddress: json['venue_address']?.toString(),
      summitTitle: json['summit_title']?.toString(),
    );
  }
}
