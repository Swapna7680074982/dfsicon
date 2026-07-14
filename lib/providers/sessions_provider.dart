import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dfsicon/domain/api_service.dart';
import 'package:dfsicon/utils/custom_logger.dart';
import '../main.dart';
import '../utils/time_formatter.dart';

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
  final String? assignmentId;
  final String? topicId;
  final int? bookmarkId;
  final int participantsCount;
  final String? description;
  final String? thumbnail;
  final String? keywords;
  final String? acceptedFilePath;
  final String? venueAddress;
  final String? summitTitle;
  final String? coordinatorName;
  final String? coordinatorPhone;
  final String? coordinatorEmail;
  final String? speakerProfileImage;

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
    this.assignmentId,
    this.topicId,
    this.bookmarkId,
    this.participantsCount = 0,
    this.description,
    this.thumbnail,
    this.keywords,
    this.acceptedFilePath,
    this.venueAddress,
    this.summitTitle,
    this.coordinatorName,
    this.coordinatorPhone,
    this.coordinatorEmail,
    this.speakerProfileImage,
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

  String? _lastAccessToken;
  String? _lastMySessionsAccessToken;

  String get searchQuery => _searchQuery;
  bool get showOnlyBookmarked => _showOnlyBookmarked;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<SessionItem> get sessions => _sessions;
  List<SessionItem> get mySessions => _mySessions;

  void clear() {
    _venueInfo = null;
    _halls = [];
    _searchQuery = '';
    _showOnlyBookmarked = false;
    _isLoading = false;
    _errorMessage = null;
    _sessions = [];
    _mySessions = [];
    _lastAccessToken = null;
    _lastMySessionsAccessToken = null;
    notifyListeners();
  }

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

  Future<bool> toggleBookmark(int sessionId, String accessToken) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final isCurrentlyBookmarked = _sessions[index].isBookmarked;
      if (!isCurrentlyBookmarked) {
        final hasBookmarked = _sessions.any((s) => s.isBookmarked);
        if (hasBookmarked) {
          return false;
        }
      }

      try {
        final assignmentId = _sessions[index].assignmentId ?? _sessions[index].id.toString();
        final response = isCurrentlyBookmarked
            ? await ApiService.unbookmarkSession(assignmentId: assignmentId, accessToken: accessToken)
            : await ApiService.bookmarkSession(assignmentId: assignmentId, accessToken: accessToken);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == true) {
            _sessions[index].isBookmarked = !isCurrentlyBookmarked;
            notifyListeners();
            return true;
          }
        }
      } catch (e, stack) {
        CustomLogger.logError('Bookmark API failure', e, stack);
      }
    }
    return false;
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

  Future<bool> fetchVenueAndHalls(String summitId, String accessToken) async {
    if (accessToken.isEmpty || summitId.isEmpty) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchVenueAndHalls(
        summitId: summitId,
        accessToken: accessToken,
      );
      _isLoading = false;

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
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchConfirmedSessions(String accessToken, {bool forceRefresh = false}) async {
    if (accessToken.isEmpty) return false;
    if (accessToken != _lastAccessToken) {
      forceRefresh = true;
      _lastAccessToken = accessToken;
    }
    if (!forceRefresh && _sessions.isNotEmpty) return true;
    if (_isLoading) return false; // Prevent concurrent loading
    _isLoading = true;
    _errorMessage = null;
    _sessions = []; // Clear previous data
    notifyListeners();

    try {
      final response = await ApiService.fetchConfirmedSessions(accessToken: accessToken);
      _isLoading = false;
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
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==========================================
  // Fetch Speaker Confirmed Sessions
  // ==========================================
  SessionItem _mapTopicToSession(Map<String, dynamic> json, int index) {
    final topicId = json['topic_id']?.toString() ?? '';
    final id = int.tryParse(topicId) ?? index;
    final title = json['title']?.toString() ?? 'Session';
    final format = json['presentation_format']?.toString() ?? 'Oral/Poster';
    
    final speakerProfileImage = json['speaker_profile_image']?.toString() ?? json['speaker_image']?.toString() ?? json['profile_image']?.toString();
    String? cleanSpeakerProfileImage = speakerProfileImage;
    if (cleanSpeakerProfileImage != null) {
      cleanSpeakerProfileImage = cleanSpeakerProfileImage.trim();
      if (cleanSpeakerProfileImage.isEmpty || cleanSpeakerProfileImage == 'null' || cleanSpeakerProfileImage == 'NA') {
        cleanSpeakerProfileImage = null;
      }
    }

    return SessionItem(
      id: id,
      title: title,
      speakerName: 'You', // Speaker's own session
      speakerTitle: format,
      speakerInitials: 'YS',
      speakerBg: _getColorForIndex(index),
      date: '',
      time: '',
      location: '',
      isBookmarked: false,
      isAdded: false,
      topicId: topicId,
      participantsCount: 0,
      description: '', // Loaded dynamically in detail screen
      keywords: '',
      venueAddress: '',
      summitTitle: '',
      coordinatorName: json['coordinator_name']?.toString() ?? json['coordinator']?.toString(),
      coordinatorPhone: (json['coordinator_phone'] ?? json['coordinator_mobile'] ?? json['coordinator_contact'])?.toString(),
      coordinatorEmail: json['coordinator_email']?.toString(),
      speakerProfileImage: cleanSpeakerProfileImage,
    );
  }

  Future<bool> fetchMyConfirmedSessions(String accessToken, {bool forceRefresh = false}) async {
    if (accessToken.isEmpty) return false;
    if (accessToken != _lastMySessionsAccessToken) {
      forceRefresh = true;
      _lastMySessionsAccessToken = accessToken;
    }
    if (!forceRefresh && _mySessions.isNotEmpty) return true;
    if (_isLoading) return false; // Prevent concurrent loading
    _isLoading = true;
    _errorMessage = null;
    _mySessions = []; // Clear previous data
    notifyListeners();

    try {
      final response = await ApiService.fetchSpeakerMyTopics(accessToken: accessToken);
      _isLoading = false;
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }
      if (response.statusCode == 200) {
        final data = _safeJsonDecode(response.body);
        if (data['status'] == true) {
          final List topicsJson = data['data'] ?? [];
          final confirmedTopics = topicsJson.where((t) => t['status'] == 'Confirmed').toList();
          _mySessions = confirmedTopics.asMap().entries.map((entry) {
            return _mapTopicToSession(entry.value, entry.key);
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
    final abstractId = json['abstract_id']?.toString() ?? json['topic_id']?.toString() ?? json['assignment_id']?.toString() ?? '';
    final id = int.tryParse(abstractId) ?? index;
    final title = json['abstract_title']?.toString() ?? json['title']?.toString() ?? 'Session';
    final speakerName = json['speaker_name']?.toString() ?? '';
    final designation = json['designation']?.toString() ?? '';
    final clinicName = json['organisation']?.toString() ?? json['hospital_clinic_name']?.toString() ?? '';
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

    final startTime = json['start_time']?.toString() ?? '';
    final endTime = json['end_time']?.toString() ?? '';
    String timeStr = '';
    if (startTime.isNotEmpty && endTime.isNotEmpty && startTime.toLowerCase() != 'null' && endTime.toLowerCase() != 'null') {
      timeStr = '${TimeFormatter.formatTime(startTime)} - ${TimeFormatter.formatTime(endTime)}';
    } else {
      final slotName = json['slot_name']?.toString() ?? '';
      timeStr = slotName.isNotEmpty ? slotName : '';
    }
    final hallName = json['hall_name']?.toString() ?? '';
    final venueName = json['venue_name']?.toString() ?? '';
    final locationStr = venueName.isNotEmpty
        ? (hallName.isNotEmpty ? '$hallName, $venueName' : venueName)
        : hallName;

    final isBookmarked = json['is_bookmarked'] == true || json['is_bookmarked'] == 'true' || json['is_bookmarked'] == 1 || json['is_bookmarked'] == '1';
    final bookmarkId = int.tryParse(json['bookmark_id']?.toString() ?? '');
    final participantsCount = int.tryParse(json['participants_count']?.toString() ?? '0') ?? 0;

    final speakerProfileImage = json['speaker_profile_image']?.toString() ?? json['speaker_image']?.toString() ?? json['profile_image']?.toString();
    String? cleanSpeakerProfileImage = speakerProfileImage;
    if (cleanSpeakerProfileImage != null) {
      cleanSpeakerProfileImage = cleanSpeakerProfileImage.trim();
      if (cleanSpeakerProfileImage.isEmpty || cleanSpeakerProfileImage == 'null' || cleanSpeakerProfileImage == 'NA') {
        cleanSpeakerProfileImage = null;
      }
    }

    return SessionItem(
      id: id,
      title: title,
      speakerName: speakerName,
      speakerTitle: speakerTitle,
      speakerInitials: _getInitials(speakerName),
      speakerBg: _getColorForIndex(index),
      date: displayDate,
      time: timeStr,
      location: locationStr,
      isBookmarked: isBookmarked,
      isAdded: false,
      assignmentId: json['assignment_id']?.toString(),
      topicId: json['topic_id']?.toString(),
      bookmarkId: bookmarkId,
      participantsCount: participantsCount,
      description: json['abstract_description']?.toString() ?? json['background_introduction']?.toString() ?? json['description']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString(),
      keywords: json['keywords']?.toString(),
      acceptedFilePath: json['accepted_file_path']?.toString(),
      venueAddress: json['venue_address']?.toString(),
      summitTitle: json['summit_title']?.toString(),
      coordinatorName: json['coordinator_name']?.toString() ?? json['coordinator']?.toString(),
      coordinatorPhone: (json['coordinator_phone'] ?? json['coordinator_mobile'] ?? json['coordinator_contact'])?.toString(),
      coordinatorEmail: json['coordinator_email']?.toString(),
      speakerProfileImage: cleanSpeakerProfileImage,
    );
  }
}
