import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dfsicon/domain/api_service.dart';
import 'package:dfsicon/domain/utility_models.dart';
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
  final String? speakerDesignation;
  final String? speakerOrganisation;

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
    this.speakerDesignation,
    this.speakerOrganisation,
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
  List<VenueLayoutItem> _venueLayouts = [];
  bool _isFetchingVenueLayouts = false;

  List<VenueLayoutItem> get venueLayouts => _venueLayouts;
  bool get isFetchingVenueLayouts => _isFetchingVenueLayouts;

  String _searchQuery = '';
  bool _showOnlyBookmarked = false;
  bool _isLoading = false;
  bool _isLoadingMySessions = false;
  String? _errorMessage;

  List<SessionItem> _sessions = [];
  List<SessionItem> _mySessions = []; // Speaker-specific confirmed sessions

  String? _lastAccessToken;
  String? _lastMySessionsAccessToken;

  String get searchQuery => _searchQuery;
  bool get showOnlyBookmarked => _showOnlyBookmarked;
  bool get isLoading => _isLoading || _isLoadingMySessions;
  bool get isLoadingConfirmedSessions => _isLoading;
  bool get isLoadingMySessions => _isLoadingMySessions;
  String? get errorMessage => _errorMessage;

  List<SessionItem> get sessions => _sessions;
  List<SessionItem> get mySessions => _mySessions;

  void clear() {
    _venueInfo = null;
    _halls = [];
    _venueMedia = [];
    _venueLayouts = [];
    _searchQuery = '';
    _showOnlyBookmarked = false;
    _isLoading = false;
    _isLoadingMySessions = false;
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

  Future<String?> toggleBookmark(
    int sessionId,
    String accessToken, {
    String? assignmentIdOverride,
    String? topicIdOverride,
    String? titleOverride,
  }) async {
    SessionItem? session;
    final index = _sessions.indexWhere((s) =>
        s.id == sessionId ||
        (assignmentIdOverride != null && s.assignmentId == assignmentIdOverride) ||
        (topicIdOverride != null && s.topicId == topicIdOverride));
    if (index != -1) {
      session = _sessions[index];
    } else {
      final myIndex = _mySessions.indexWhere((s) =>
          s.id == sessionId ||
          (assignmentIdOverride != null && s.assignmentId == assignmentIdOverride) ||
          (topicIdOverride != null && s.topicId == topicIdOverride));
      if (myIndex != -1) {
        session = _mySessions[myIndex];
      }
    }

    final String assignmentId = (assignmentIdOverride != null && assignmentIdOverride.isNotEmpty)
        ? assignmentIdOverride
        : (session?.assignmentId ?? session?.id.toString() ?? sessionId.toString());

    if (assignmentId.isEmpty || assignmentId == '0') {
      return 'Invalid session assignment ID';
    }

    final isCurrentlyBookmarked = session?.isBookmarked ?? true;

    if (!isCurrentlyBookmarked && session != null) {
      final allSessionsToCheck = [..._sessions, ..._mySessions];
      for (final other in allSessionsToCheck) {
        if (other.id != session.id && other.isBookmarked && _isTimeOverlap(session, other)) {
          return 'This session conflicts with another bookmarked session ("${other.title}") scheduled at the same time!';
        }
      }
    }

    try {
      final response = isCurrentlyBookmarked
          ? await ApiService.unbookmarkSession(assignmentId: assignmentId, accessToken: accessToken)
          : await ApiService.bookmarkSession(assignmentId: assignmentId, accessToken: accessToken);

      final dynamic data = _safeJsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data is Map && data['status'] == true) {
          if (session != null) {
            session.isBookmarked = !isCurrentlyBookmarked;
          }
          for (final s in _sessions) {
            if (s.id == sessionId || (assignmentId.isNotEmpty && s.assignmentId == assignmentId)) {
              s.isBookmarked = !isCurrentlyBookmarked;
            }
          }
          for (final s in _mySessions) {
            if (s.id == sessionId || (assignmentId.isNotEmpty && s.assignmentId == assignmentId)) {
              s.isBookmarked = !isCurrentlyBookmarked;
            }
          }
          if (isCurrentlyBookmarked) {
            fetchConfirmedSessions(accessToken, forceRefresh: true);
          }
          notifyListeners();
          return null; // Success
        } else if (data is Map && data['message'] != null) {
          return data['message'].toString();
        } else {
          return 'Failed to update bookmark status';
        }
      } else {
        if (data is Map && data['message'] != null && data['message'].toString().trim().isNotEmpty) {
          return data['message'].toString();
        }
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

  Future<bool> fetchVenueLayouts(String accessToken, {dynamic summitId, String? layoutType}) async {
    if (accessToken.isEmpty) return false;
    _isFetchingVenueLayouts = true;
    notifyListeners();

    try {
      final response = await ApiService.fetchVenueLayouts(
        accessToken: accessToken,
        summitId: summitId,
        layoutType: layoutType,
      );

      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        _isFetchingVenueLayouts = false;
        notifyListeners();
        return false;
      }

      if (response.statusCode == 200) {
        final data = _safeJsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List list = data['data'];
          _venueLayouts = list
              .whereType<Map<String, dynamic>>()
              .map((item) => VenueLayoutItem.fromJson(item))
              .toList();
          _isFetchingVenueLayouts = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch venue layouts failed', e, stack);
    } finally {
      _isFetchingVenueLayouts = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool>? _ongoingConfirmedSessionsFuture;
  Future<bool>? _ongoingMySessionsFuture;

  Future<bool> fetchConfirmedSessions(String accessToken, {bool forceRefresh = false}) async {
    if (accessToken.isEmpty) return false;
    if (accessToken != _lastAccessToken) {
      forceRefresh = true;
      _lastAccessToken = accessToken;
    }
    if (!forceRefresh && _sessions.isNotEmpty) return true;
    if (_ongoingConfirmedSessionsFuture != null) {
      return _ongoingConfirmedSessionsFuture!;
    }
    _ongoingConfirmedSessionsFuture = _doFetchConfirmedSessions(accessToken, forceRefresh: forceRefresh);
    try {
      return await _ongoingConfirmedSessionsFuture!;
    } finally {
      _ongoingConfirmedSessionsFuture = null;
    }
  }

  Future<bool> _doFetchConfirmedSessions(String accessToken, {bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    if (forceRefresh && _sessions.isEmpty) {
      _sessions = [];
    }
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
          _enrichMySessionsFromConfirmed();
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

  void _enrichMySessionsFromConfirmed() {
    if (_sessions.isEmpty || _mySessions.isEmpty) return;
    for (int i = 0; i < _mySessions.length; i++) {
      final my = _mySessions[i];
      try {
        final matched = _sessions.firstWhere((s) =>
            (my.topicId != null && my.topicId!.isNotEmpty && (s.topicId == my.topicId || s.id.toString() == my.topicId)) ||
            (my.assignmentId != null && my.assignmentId!.isNotEmpty && s.assignmentId == my.assignmentId) ||
            (s.title.toLowerCase().trim() == my.title.toLowerCase().trim()));

        final finalDate = my.date.isNotEmpty ? my.date : matched.date;
        final finalTime = my.time.isNotEmpty ? my.time : matched.time;
        final finalScheduleDate = (my.scheduleDate != null && my.scheduleDate!.isNotEmpty) ? my.scheduleDate : matched.scheduleDate;
        final finalStartTime = (my.startTime != null && my.startTime!.isNotEmpty) ? my.startTime : matched.startTime;
        final finalEndTime = (my.endTime != null && my.endTime!.isNotEmpty) ? my.endTime : matched.endTime;
        final finalLocation = my.location.isNotEmpty ? my.location : matched.location;

        _mySessions[i] = SessionItem(
          id: my.id,
          title: my.title,
          speakerName: my.speakerName,
          speakerTitle: my.speakerTitle,
          speakerInitials: my.speakerInitials,
          speakerBg: my.speakerBg,
          date: finalDate,
          time: finalTime,
          location: finalLocation,
          isBookmarked: my.isBookmarked || matched.isBookmarked,
          isAdded: my.isAdded || matched.isAdded,
          topicId: my.topicId ?? matched.topicId,
          assignmentId: my.assignmentId ?? matched.assignmentId,
          bookmarkId: my.bookmarkId ?? matched.bookmarkId,
          participantsCount: my.participantsCount > 0 ? my.participantsCount : matched.participantsCount,
          description: (my.description != null && my.description!.isNotEmpty) ? my.description : matched.description,
          thumbnail: my.thumbnail ?? matched.thumbnail,
          keywords: my.keywords ?? matched.keywords,
          acceptedFilePath: my.acceptedFilePath ?? matched.acceptedFilePath,
          venueAddress: my.venueAddress ?? matched.venueAddress,
          summitTitle: my.summitTitle ?? matched.summitTitle,
          coordinatorName: my.coordinatorName ?? matched.coordinatorName,
          coordinatorPhone: my.coordinatorPhone ?? matched.coordinatorPhone,
          coordinatorEmail: my.coordinatorEmail ?? matched.coordinatorEmail,
          speakerProfileImage: my.speakerProfileImage ?? matched.speakerProfileImage,
          startTime: finalStartTime,
          endTime: finalEndTime,
          scheduleDate: finalScheduleDate,
          speakerDesignation: my.speakerDesignation ?? matched.speakerDesignation,
          speakerOrganisation: my.speakerOrganisation ?? matched.speakerOrganisation,
        );
      } catch (_) {}
    }
  }

  // ==========================================
  // Fetch Speaker Confirmed Sessions
  // ==========================================
  SessionItem _mapTopicToSession(Map<String, dynamic> json, int index) {
    final topicId = json['topic_id']?.toString() ?? json['abstract_id']?.toString() ?? '';
    final id = int.tryParse(topicId) ?? index;
    final title = json['title']?.toString() ?? json['abstract_title']?.toString() ?? 'Session';
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
            : (json['session_data'] is Map)
                ? json['session_data'] as Map<String, dynamic>
                : (json['slot'] is Map)
                    ? json['slot'] as Map<String, dynamic>
                    : null;

    final hallMap = (json['hall'] is Map) ? json['hall'] as Map<String, dynamic> : null;

    final hallLabel = sessDetails?['hall_label']?.toString() ??
        json['hall_label']?.toString() ??
        hallMap?['hall_label']?.toString() ??
        (sessDetails?['hall'] is Map ? sessDetails!['hall']['hall_label']?.toString() : null) ??
        '';
    final hallName = sessDetails?['hall_name']?.toString() ??
        json['hall_name']?.toString() ??
        hallMap?['hall_name']?.toString() ??
        (json['hall'] is String ? json['hall'].toString() : null) ??
        (sessDetails?['hall'] is Map ? sessDetails!['hall']['hall_name']?.toString() : null) ??
        (sessDetails?['hall'] is String ? sessDetails!['hall'].toString() : null) ??
        '';
    final displayHall = hallLabel.trim().isNotEmpty ? hallLabel.trim() : hallName.trim();

    final slotLabel = sessDetails?['slot_label']?.toString() ?? json['slot_label']?.toString() ?? '';
    final slotName = sessDetails?['slot_name']?.toString() ?? json['slot_name']?.toString() ?? '';

    final startTime = sessDetails?['start_time']?.toString() ??
        json['start_time']?.toString() ??
        sessDetails?['from_time']?.toString() ??
        json['from_time']?.toString() ??
        sessDetails?['slot_start_time']?.toString() ??
        json['slot_start_time']?.toString() ??
        '';
    final endTime = sessDetails?['end_time']?.toString() ??
        json['end_time']?.toString() ??
        sessDetails?['to_time']?.toString() ??
        json['to_time']?.toString() ??
        sessDetails?['slot_end_time']?.toString() ??
        json['slot_end_time']?.toString() ??
        '';

    String timeStr = '';
    if (startTime.isNotEmpty && endTime.isNotEmpty && startTime.toLowerCase() != 'null' && endTime.toLowerCase() != 'null') {
      timeStr = '${TimeFormatter.formatTime(startTime)} - ${TimeFormatter.formatTime(endTime)}';
    } else if (slotLabel.isNotEmpty) {
      timeStr = slotLabel;
    } else if (slotName.isNotEmpty) {
      timeStr = slotName;
    } else if (json['time'] != null && json['time'].toString().isNotEmpty) {
      timeStr = json['time'].toString();
    } else if (sessDetails?['time'] != null && sessDetails!['time'].toString().isNotEmpty) {
      timeStr = sessDetails['time'].toString();
    }

    final venueName = sessDetails?['venue_name']?.toString() ?? json['venue_name']?.toString() ?? '';
    final locationStr = venueName.isNotEmpty
        ? (displayHall.isNotEmpty ? '$displayHall, $venueName' : venueName)
        : displayHall;

    String displayDate = '';
    final scheduleDateStr = sessDetails?['schedule_date']?.toString() ??
        json['schedule_date']?.toString() ??
        sessDetails?['session_date']?.toString() ??
        json['session_date']?.toString() ??
        sessDetails?['date']?.toString() ??
        json['date']?.toString() ??
        '';
    if (scheduleDateStr.isNotEmpty) {
      try {
        final dt = DateTime.tryParse(scheduleDateStr);
        if (dt != null) {
          const months = [
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

    // Cross-reference with _sessions if available
    SessionItem? matchedSession;
    if (_sessions.isNotEmpty) {
      try {
        matchedSession = _sessions.firstWhere((s) =>
            (topicId.isNotEmpty && (s.topicId == topicId || s.id.toString() == topicId)) ||
            (json['assignment_id'] != null && s.assignmentId == json['assignment_id'].toString()) ||
            (s.title.toLowerCase().trim() == title.toLowerCase().trim()));
      } catch (_) {}
    }

    final finalStartTime = startTime.isNotEmpty && startTime.toLowerCase() != 'null'
        ? startTime
        : (matchedSession?.startTime ?? '');
    final finalEndTime = endTime.isNotEmpty && endTime.toLowerCase() != 'null'
        ? endTime
        : (matchedSession?.endTime ?? '');
    final finalScheduleDate = scheduleDateStr.isNotEmpty && scheduleDateStr.toLowerCase() != 'null'
        ? scheduleDateStr
        : (matchedSession?.scheduleDate ?? '');
    final finalDisplayDate = displayDate.isNotEmpty
        ? displayDate
        : (matchedSession?.date ?? '');
    final finalTimeStr = timeStr.isNotEmpty
        ? timeStr
        : (matchedSession?.time ?? (finalStartTime.isNotEmpty && finalEndTime.isNotEmpty ? '${TimeFormatter.formatTime(finalStartTime)} - ${TimeFormatter.formatTime(finalEndTime)}' : ''));
    final finalLocation = locationStr.isNotEmpty
        ? locationStr
        : (matchedSession?.location ?? '');

    return SessionItem(
      id: id,
      title: title,
      speakerName: 'You', // Speaker's own session
      speakerTitle: format,
      speakerInitials: 'YS',
      speakerBg: _getColorForIndex(index),
      date: finalDisplayDate,
      time: finalTimeStr,
      location: finalLocation,
      isBookmarked: false,
      isAdded: false,
      topicId: topicId,
      assignmentId: json['assignment_id']?.toString() ?? sessDetails?['assignment_id']?.toString() ?? matchedSession?.assignmentId,
      participantsCount: int.tryParse(json['participants_count']?.toString() ?? '0') ?? matchedSession?.participantsCount ?? 0,
      description: json['background_introduction']?.toString() ?? json['description']?.toString() ?? matchedSession?.description ?? '',
      keywords: json['keywords']?.toString() ?? matchedSession?.keywords,
      venueAddress: sessDetails?['address']?.toString() ?? json['venue_address']?.toString() ?? json['address']?.toString() ?? matchedSession?.venueAddress,
      summitTitle: json['summit_title']?.toString() ?? matchedSession?.summitTitle,
      coordinatorName: json['coordinator_name']?.toString() ?? json['coordinator']?.toString() ?? matchedSession?.coordinatorName,
      coordinatorPhone: (json['coordinator_phone'] ?? json['coordinator_mobile'] ?? json['coordinator_contact'])?.toString() ?? matchedSession?.coordinatorPhone,
      coordinatorEmail: json['coordinator_email']?.toString() ?? matchedSession?.coordinatorEmail,
      speakerProfileImage: cleanSpeakerProfileImage ?? matchedSession?.speakerProfileImage,
      startTime: finalStartTime,
      endTime: finalEndTime,
      scheduleDate: finalScheduleDate,
      speakerDesignation: matchedSession?.speakerDesignation,
      speakerOrganisation: matchedSession?.speakerOrganisation,
    );
  }

  Future<bool> fetchMyConfirmedSessions(String accessToken, {bool forceRefresh = false}) async {
    if (accessToken.isEmpty) return false;
    if (accessToken != _lastMySessionsAccessToken) {
      forceRefresh = true;
      _lastMySessionsAccessToken = accessToken;
    }
    if (!forceRefresh && _mySessions.isNotEmpty) return true;
    if (_ongoingMySessionsFuture != null) {
      return _ongoingMySessionsFuture!;
    }
    _ongoingMySessionsFuture = _doFetchMyConfirmedSessions(accessToken, forceRefresh: forceRefresh);
    try {
      return await _ongoingMySessionsFuture!;
    } finally {
      _ongoingMySessionsFuture = null;
    }
  }

  Future<bool> _doFetchMyConfirmedSessions(String accessToken, {bool forceRefresh = false}) async {
    _isLoadingMySessions = true;
    _errorMessage = null;
    if (forceRefresh && _mySessions.isEmpty) {
      _mySessions = [];
    }
    notifyListeners();

    try {
      final response = await ApiService.fetchSpeakerMyTopics(accessToken: accessToken);
      _isLoadingMySessions = false;
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }
      if (response.statusCode == 200) {
        final data = _safeJsonDecode(response.body);
        if (data['status'] == true) {
          final List topicsJson = data['data'] ?? [];
          final confirmedTopics = topicsJson.where((t) => t['status'] == 'Confirmed').toList();
          
          // Initial map so topics appear immediately
          _mySessions = confirmedTopics.asMap().entries.map((entry) {
            return _mapTopicToSession(entry.value, entry.key);
          }).toList();
          _enrichMySessionsFromConfirmed();
          notifyListeners();

          // Fetch topic_details in parallel to obtain full session_details (hall, slot, schedule_date, start_time, end_time)
          if (confirmedTopics.isNotEmpty) {
            final detailFutures = confirmedTopics.map((topic) async {
              final topicId = topic['topic_id']?.toString() ?? topic['abstract_id']?.toString() ?? '';
              if (topicId.isNotEmpty) {
                try {
                  final detailResp = await ApiService.fetchSpeakerTopicDetails(
                    topicId: topicId,
                    accessToken: accessToken,
                  );
                  if (detailResp.statusCode == 200) {
                    final detailData = _safeJsonDecode(detailResp.body);
                    if (detailData['status'] == true && detailData['data'] is Map<String, dynamic>) {
                      return detailData['data'] as Map<String, dynamic>;
                    }
                  }
                } catch (e, stack) {
                  CustomLogger.logError('Fetch topic details for $topicId in fetchMyConfirmedSessions failed', e, stack);
                }
              }
              return topic is Map<String, dynamic> ? topic : Map<String, dynamic>.from(topic);
            }).toList();

            final detailedTopics = await Future.wait(detailFutures);
            _mySessions = detailedTopics.asMap().entries.map((entry) {
              return _mapTopicToSession(entry.value, entry.key);
            }).toList();
            _enrichMySessionsFromConfirmed();
            notifyListeners();
          }

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
      _isLoadingMySessions = false;
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
    final rawDesignation = json['designation']?.toString().trim() ?? '';
    final rawClinicName = (json['organisation'] ?? json['hospital_clinic_name'] ?? json['organisation_name'])?.toString().trim() ?? '';

    String? speakerDesignation;
    if (rawDesignation.isNotEmpty && rawDesignation.toLowerCase() != 'null') {
      if (rawDesignation.toUpperCase().contains('INFORMATION IS PRIVATE') || rawDesignation.toUpperCase() == 'PRIVATE') {
        speakerDesignation = 'Designation: This information is private';
      } else {
        speakerDesignation = 'Designation: $rawDesignation';
      }
    }

    String? speakerOrganisation;
    if (rawClinicName.isNotEmpty && rawClinicName.toLowerCase() != 'null') {
      final isPrivate = rawClinicName.toUpperCase().contains('INFORMATION IS PRIVATE') || rawClinicName.toUpperCase() == 'PRIVATE';
      if (isPrivate) {
        speakerOrganisation = 'Organisation: This information is private';
      } else {
        final prefix = (rawClinicName.toLowerCase().contains('hospital') || rawClinicName.toLowerCase().contains('clinic'))
            ? 'Hospital'
            : 'Organisation';
        speakerOrganisation = '$prefix: $rawClinicName';
      }
    }

    final speakerTitle = [speakerDesignation, speakerOrganisation]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');

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
      speakerDesignation: speakerDesignation,
      speakerOrganisation: speakerOrganisation,
    );
  }
}
