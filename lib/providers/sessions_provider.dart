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
  final String? startTime;
  final String? endTime;
  final String? scheduleDate;

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
    this.startTime,
    this.endTime,
    this.scheduleDate,
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

  factory VenueInfo.fromJson(Map<String, dynamic> json) {
    return VenueInfo(
      venueId: json['venue_id']?.toString() ?? '',
      venueName: json['venue_name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      totalHalls: json['total_halls']?.toString() ?? '',
      sessionsPerDay: json['sessions_per_day']?.toString() ?? '',
      stateName: json['state_name']?.toString() ?? '',
      cityName: json['city_name']?.toString() ?? '',
    );
  }
}

class HallItem {
  final String hallId;
  final String hallName;
  final String hallLabel;
  final String hallCapacity;

  HallItem({
    required this.hallId,
    required this.hallName,
    this.hallLabel = '',
    required this.hallCapacity,
  });

  factory HallItem.fromJson(Map<String, dynamic> json) {
    final name = json['hall_name']?.toString() ?? '';
    final label = json['hall_label']?.toString() ?? '';
    return HallItem(
      hallId: json['hall_id']?.toString() ?? '',
      hallName: name,
      hallLabel: label.isNotEmpty ? label : name,
      hallCapacity: json['hall_capacity']?.toString() ?? '0',
    );
  }
}

class VenueMediaItem {
  final String mediaId;
  final String mediaUrl;
  final String mimeType;

  VenueMediaItem({
    required this.mediaId,
    required this.mediaUrl,
    required this.mimeType,
  });

  factory VenueMediaItem.fromJson(Map<String, dynamic> json) {
    String rawUrl = json['media_url']?.toString() ?? json['url']?.toString() ?? '';
    if (rawUrl.contains('/./')) {
      rawUrl = rawUrl.replaceAll('/./', '/');
    }
    String cleanedUrl = rawUrl;
    if (rawUrl.isNotEmpty && !rawUrl.startsWith('http')) {
      if (rawUrl.startsWith('./')) {
        cleanedUrl = 'https://services.heterohcl.com/dfs-icon/${rawUrl.substring(2)}';
      } else if (rawUrl.startsWith('/')) {
        cleanedUrl = 'https://services.heterohcl.com/dfs-icon/${rawUrl.substring(1)}';
      } else {
        cleanedUrl = 'https://services.heterohcl.com/dfs-icon/$rawUrl';
      }
    }

    return VenueMediaItem(
      mediaId: json['media_id']?.toString() ?? '',
      mediaUrl: cleanedUrl,
      mimeType: json['mime_type']?.toString() ?? 'image/jpeg',
    );
  }
}

class SessionsProvider extends ChangeNotifier {
  VenueInfo? _venueInfo;
  List<HallItem> _halls = [];
  List<VenueMediaItem> _venueMedia = [];

  VenueInfo? get venueInfo => _venueInfo;
  List<HallItem> get halls => _halls;
  List<VenueMediaItem> get venueMedia => _venueMedia;

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
    _venueMedia = [];
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

  bool _isTimeOverlap(SessionItem a, SessionItem b) {
    final dateA = a.scheduleDate ?? a.date;
    final dateB = b.scheduleDate ?? b.date;
    if (dateA.isNotEmpty && dateB.isNotEmpty && dateA != dateB) {
      return false; // Different days
    }

    final timePartsA = a.time.split('-');
    final rawStartA = timePartsA.isNotEmpty ? timePartsA[0] : null;
    final rawEndA = timePartsA.length > 1 ? timePartsA[1] : null;

    final timePartsB = b.time.split('-');
    final rawStartB = timePartsB.isNotEmpty ? timePartsB[0] : null;
    final rawEndB = timePartsB.length > 1 ? timePartsB[1] : null;

    final startA = _parseTimeToMinutes(a.startTime ?? rawStartA);
    final endA = _parseTimeToMinutes(a.endTime ?? rawEndA);
    final startB = _parseTimeToMinutes(b.startTime ?? rawStartB);
    final endB = _parseTimeToMinutes(b.endTime ?? rawEndB);

    if (startA != null && endA != null && startB != null && endB != null) {
      return startA < endB && startB < endA;
    }

    if (a.time.isNotEmpty && b.time.isNotEmpty) {
      return a.time == b.time;
    }

    return false;
  }

  Future<String?> toggleBookmark(int sessionId, String accessToken) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return 'Session not found';

    final session = _sessions[index];
    final isCurrentlyBookmarked = session.isBookmarked;

    if (!isCurrentlyBookmarked) {
      for (final other in _sessions) {
        if (other.isBookmarked && _isTimeOverlap(session, other)) {
          return 'This session conflicts with another bookmarked session ("${other.title}") scheduled at the same time!';
        }
      }
    }

    try {
      final assignmentId = session.assignmentId ?? session.id.toString();
      final response = isCurrentlyBookmarked
          ? await ApiService.unbookmarkSession(assignmentId: assignmentId, accessToken: accessToken)
          : await ApiService.bookmarkSession(assignmentId: assignmentId, accessToken: accessToken);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          session.isBookmarked = !isCurrentlyBookmarked;
          notifyListeners();
          return null; // Success
        } else {
          return data['message'] ?? 'Failed to update bookmark status';
        }
      } else {
        return 'Server error: ${response.statusCode}';
      }
    } catch (e, stack) {
      CustomLogger.logError('Bookmark API failure', e, stack);
      return 'Failed to toggle bookmark. Please check your internet connection.';
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
          if (venueJson != null && venueJson is Map<String, dynamic>) {
            _venueInfo = VenueInfo.fromJson(venueJson);
          }

          final List hallsJson = data['data']['halls'] ?? [];
          _halls = hallsJson
              .whereType<Map<String, dynamic>>()
              .map((h) => HallItem.fromJson(h))
              .toList();

          final List mediaJson = data['data']['media'] ?? (venueJson is Map ? venueJson['media'] : null) ?? [];
          _venueMedia = mediaJson
              .whereType<Map<String, dynamic>>()
              .map((m) => VenueMediaItem.fromJson(m))
              .where((m) => m.mediaUrl.isNotEmpty)
              .toList();

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

    final sessDetails = (json['session_details'] is Map)
        ? json['session_details'] as Map<String, dynamic>
        : (json['session'] is Map)
            ? json['session'] as Map<String, dynamic>
            : null;

    final hallLabel = sessDetails?['hall_label']?.toString() ??
        json['hall_label']?.toString() ??
        (json['hall'] is Map ? json['hall']['hall_label']?.toString() : null) ??
        '';
    final hallName = sessDetails?['hall_name']?.toString() ??
        json['hall_name']?.toString() ??
        (json['hall'] is Map ? json['hall']['hall_name']?.toString() : null) ??
        (json['hall'] is String ? json['hall'].toString() : null) ??
        '';
    final displayHall = hallLabel.trim().isNotEmpty ? hallLabel.trim() : hallName.trim();

    final slotLabel = sessDetails?['slot_label']?.toString() ?? json['slot_label']?.toString() ?? '';
    final slotName = sessDetails?['slot_name']?.toString() ?? json['slot_name']?.toString() ?? '';

    final startTime = sessDetails?['start_time']?.toString() ?? json['start_time']?.toString() ?? '';
    final endTime = sessDetails?['end_time']?.toString() ?? json['end_time']?.toString() ?? '';
    String timeStr = '';
    if (startTime.isNotEmpty && endTime.isNotEmpty && startTime.toLowerCase() != 'null' && endTime.toLowerCase() != 'null') {
      timeStr = '${TimeFormatter.formatTime(startTime)} - ${TimeFormatter.formatTime(endTime)}';
    } else if (slotLabel.isNotEmpty) {
      timeStr = slotLabel;
    } else if (slotName.isNotEmpty) {
      timeStr = slotName;
    }

    final venueName = sessDetails?['venue_name']?.toString() ?? json['venue_name']?.toString() ?? '';
    final locationStr = venueName.isNotEmpty
        ? (displayHall.isNotEmpty ? '$displayHall, $venueName' : venueName)
        : displayHall;

    String displayDate = '';
    final scheduleDateStr = sessDetails?['schedule_date']?.toString() ?? json['schedule_date']?.toString() ?? '';
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

    return SessionItem(
      id: id,
      title: title,
      speakerName: 'You', // Speaker's own session
      speakerTitle: format,
      speakerInitials: 'YS',
      speakerBg: _getColorForIndex(index),
      date: displayDate,
      time: timeStr,
      location: locationStr,
      isBookmarked: false,
      isAdded: false,
      topicId: topicId,
      assignmentId: json['assignment_id']?.toString() ?? sessDetails?['assignment_id']?.toString(),
      participantsCount: int.tryParse(json['participants_count']?.toString() ?? '0') ?? 0,
      description: json['background_introduction']?.toString() ?? json['description']?.toString() ?? '',
      keywords: json['keywords']?.toString(),
      venueAddress: sessDetails?['address']?.toString() ?? json['venue_address']?.toString() ?? json['address']?.toString(),
      summitTitle: json['summit_title']?.toString(),
      coordinatorName: json['coordinator_name']?.toString() ?? json['coordinator']?.toString(),
      coordinatorPhone: (json['coordinator_phone'] ?? json['coordinator_mobile'] ?? json['coordinator_contact'])?.toString(),
      coordinatorEmail: json['coordinator_email']?.toString(),
      speakerProfileImage: cleanSpeakerProfileImage,
      startTime: startTime,
      endTime: endTime,
      scheduleDate: scheduleDateStr,
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

    final sessDetails = (json['session_details'] is Map)
        ? json['session_details'] as Map<String, dynamic>
        : null;

    String displayDate = '';
    final scheduleDateStr = sessDetails?['schedule_date']?.toString() ?? json['schedule_date']?.toString() ?? '';
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

    final startTime = sessDetails?['start_time']?.toString() ?? json['start_time']?.toString() ?? '';
    final endTime = sessDetails?['end_time']?.toString() ?? json['end_time']?.toString() ?? '';
    final slotLabel = sessDetails?['slot_label']?.toString() ?? json['slot_label']?.toString() ?? '';
    final slotName = sessDetails?['slot_name']?.toString() ?? json['slot_name']?.toString() ?? '';

    String timeStr = '';
    if (startTime.isNotEmpty && endTime.isNotEmpty && startTime.toLowerCase() != 'null' && endTime.toLowerCase() != 'null') {
      timeStr = '${TimeFormatter.formatTime(startTime)} - ${TimeFormatter.formatTime(endTime)}';
    } else if (slotLabel.isNotEmpty) {
      timeStr = slotLabel;
    } else if (slotName.isNotEmpty) {
      timeStr = slotName;
    }

    final hallLabel = sessDetails?['hall_label']?.toString() ??
        json['hall_label']?.toString() ??
        (json['hall'] is Map ? json['hall']['hall_label']?.toString() : null) ??
        '';
    final hallName = sessDetails?['hall_name']?.toString() ??
        json['hall_name']?.toString() ??
        (json['hall'] is Map ? json['hall']['hall_name']?.toString() : null) ??
        (json['hall'] is String ? json['hall'].toString() : null) ??
        '';
    final displayHall = hallLabel.trim().isNotEmpty ? hallLabel.trim() : hallName.trim();

    final venueName = sessDetails?['venue_name']?.toString() ?? json['venue_name']?.toString() ?? '';
    final locationStr = venueName.isNotEmpty
        ? (displayHall.isNotEmpty ? '$displayHall, $venueName' : venueName)
        : displayHall;

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
      assignmentId: json['assignment_id']?.toString() ?? sessDetails?['assignment_id']?.toString(),
      topicId: json['topic_id']?.toString(),
      bookmarkId: bookmarkId,
      participantsCount: participantsCount,
      description: json['abstract_description']?.toString() ?? json['background_introduction']?.toString() ?? json['description']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString(),
      keywords: json['keywords']?.toString(),
      acceptedFilePath: json['accepted_file_path']?.toString(),
      venueAddress: sessDetails?['address']?.toString() ?? json['venue_address']?.toString() ?? json['address']?.toString(),
      summitTitle: json['summit_title']?.toString(),
      coordinatorName: json['coordinator_name']?.toString() ?? json['coordinator']?.toString(),
      coordinatorPhone: (json['coordinator_phone'] ?? json['coordinator_mobile'] ?? json['coordinator_contact'])?.toString(),
      coordinatorEmail: json['coordinator_email']?.toString(),
      speakerProfileImage: cleanSpeakerProfileImage,
      startTime: startTime,
      endTime: endTime,
      scheduleDate: scheduleDateStr,
    );
  }
}
