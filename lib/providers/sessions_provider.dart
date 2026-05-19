import 'package:flutter/material.dart';

class SessionItem {
  final int id;
  final String title;
  final String speakerName;
  final String speakerTitle;
  final String speakerInitials;
  final Color speakerBg;
  final String time;
  final String location;
  bool isBookmarked;
  bool isAdded;

  SessionItem({
    required this.id,
    required this.title,
    required this.speakerName,
    required this.speakerTitle,
    required this.speakerInitials,
    required this.speakerBg,
    required this.time,
    required this.location,
    this.isBookmarked = false,
    this.isAdded = false,
  });
}

class SessionsProvider extends ChangeNotifier {
  String _searchQuery = '';
  bool _showOnlyBookmarked = false;

  String get searchQuery => _searchQuery;
  bool get showOnlyBookmarked => _showOnlyBookmarked;

  final List<SessionItem> _sessions = [
    SessionItem(
      id: 1,
      title: 'AI-Powered Diagnostics: Transforming Clinical Decision-Making',
      speakerName: 'Dr. Sarah Chen',
      speakerTitle: 'Chief Medical AI Officer, MedCore Health',
      speakerInitials: 'SC',
      speakerBg: const Color(0xFF6366F1),
      time: '09:00 AM – 10:00 AM',
      location: 'Hall A',
      isBookmarked: true,
      isAdded: false,
    ),
    SessionItem(
      id: 2,
      title: 'Electronic Health Records: Achieving True Interoperability',
      speakerName: 'Dr. Marcus Johnson',
      speakerTitle: 'VP of Clinical Systems, HealthBridge Systems',
      speakerInitials: 'MJ',
      speakerBg: const Color(0xFFEC4899),
      time: '10:30 AM – 11:30 AM',
      location: 'Hall B',
      isBookmarked: false,
      isAdded: false,
    ),
    SessionItem(
      id: 3,
      title: 'Accelerating Clinical Trials with Decentralized & Digital Tools',
      speakerName: 'Dr. Emily Rodriguez',
      speakerTitle: 'Head of Clinical Research, PharmaTech Labs',
      speakerInitials: 'ER',
      speakerBg: const Color(0xFF10B981),
      time: '12:00 PM – 01:00 PM',
      location: 'Hall A',
      isBookmarked: false,
      isAdded: true,
    ),
    SessionItem(
      id: 4,
      title: 'the Future of Wearable Health Tech',
      speakerName: 'Dr. Alan Park',
      speakerTitle: 'Director of Digital Health, MediWear Inc.',
      speakerInitials: 'AP',
      speakerBg: const Color(0xFFF59E0B),
      time: '02:00 PM – 03:00 PM',
      location: 'Hall A',
      isBookmarked: false,
      isAdded: false,
    ),
    SessionItem(
      id: 5,
      title: 'Value-Based Care: Outcomes, Economics & Provider Workflows',
      speakerName: 'Dr. Lisa Wong',
      speakerTitle: 'Chief Medical Officer, CareFirst Network',
      speakerInitials: 'LW',
      speakerBg: const Color(0xFFEF4444),
      time: '03:30 PM – 04:30 PM',
      location: 'Hall B',
      isBookmarked: true,
      isAdded: false,
    ),
  ];

  List<SessionItem> get sessions => _sessions;

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
}
