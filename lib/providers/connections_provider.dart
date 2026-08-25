import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dfsicon/domain/api_service.dart';
import 'package:dfsicon/utils/custom_logger.dart';
import 'package:dfsicon/main.dart';

class ParticipantItem {
  final String id;
  final String name;
  final String title;
  final String initials;
  final Color bg;
  bool isConnected;
  final String? profileImage;
  final int? connectionId;
  final String connectionStatus;
  final String action;
  final int? conversationId;

  ParticipantItem({
    required this.id,
    required this.name,
    required this.title,
    required this.initials,
    required this.bg,
    this.isConnected = false,
    this.profileImage,
    this.connectionId,
    this.connectionStatus = 'NONE',
    this.action = 'CONNECT',
    this.conversationId,
  });
}

class ConnectionsProvider extends ChangeNotifier {
  List<ParticipantItem> _participants = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _participantsCount = 0;
  Map<String, dynamic>? _sessionData;
  String? _topicTitle;

  List<ParticipantItem> get participants => _participants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get participantsCount => _participantsCount;
  Map<String, dynamic>? get sessionData => _sessionData;
  String? get topicTitle => _topicTitle;

  static String _getInitials(String name) {
    if (name.trim().isEmpty) return 'PA';
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

  Future<bool> fetchSessionParticipants({
    String? assignmentId,
    String? topicId,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return false;
    _isLoading = true;
    _errorMessage = null;
    _participants = [];
    _participantsCount = 0;
    _sessionData = null;
    _topicTitle = null;
    notifyListeners();

    try {
      // First try Networking Session Participants API if assignmentId is present
      final response = await ApiService.fetchNetworkSessionParticipants(
        assignmentId: assignmentId ?? topicId,
        accessToken: accessToken,
      );

      _isLoading = false;
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          _topicTitle = data['topic_title']?.toString();
          final List list = data['data'] ?? [];
          _participantsCount = data['total'] as int? ?? list.length;

          _participants = list.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final String userId = (item['user_id'] ?? item['delegate_id'] ?? idx).toString();
            final String fullName = item['full_name']?.toString() ?? 'Participant';
            final String designation = item['designation']?.toString() ?? '';
            final String organisation = item['organisation_name']?.toString() ?? item['organisation']?.toString() ?? '';
            final String title = designation.isNotEmpty && organisation.isNotEmpty
                ? '$designation, $organisation'
                : (designation.isNotEmpty ? designation : (organisation.isNotEmpty ? organisation : 'Attendee'));

            String? profileImage = item['profile_image']?.toString();
            if (profileImage != null && profileImage.contains('/./')) {
              profileImage = profileImage.replaceAll('/./', '/');
            }

            final String connStatus = item['connection_status']?.toString() ?? 'NONE';
            final String actionStr = item['action']?.toString() ?? 'CONNECT';

            return ParticipantItem(
              id: userId,
              name: fullName,
              title: title,
              initials: _getInitials(fullName),
              bg: _getColorForIndex(idx),
              isConnected: connStatus == 'CONNECTED' || actionStr == 'CONNECTED',
              profileImage: (profileImage != null && profileImage.isNotEmpty && profileImage != 'null') ? profileImage : null,
              connectionId: item['connection_id'] is int ? item['connection_id'] : int.tryParse(item['connection_id']?.toString() ?? ''),
              connectionStatus: connStatus,
              action: actionStr,
              conversationId: item['conversation_id'] is int ? item['conversation_id'] : int.tryParse(item['conversation_id']?.toString() ?? ''),
            );
          }).toList();

          notifyListeners();
          return true;
        }
      }

      // Fallback to utility viewSessionParticipants
      final fallbackResponse = await ApiService.viewSessionParticipants(
        assignmentId: assignmentId,
        topicId: topicId,
        accessToken: accessToken,
      );

      if (fallbackResponse.statusCode == 200) {
        final data = json.decode(fallbackResponse.body);
        if (data['status'] == true && data['data'] != null) {
          _sessionData = data['data']['session'] as Map<String, dynamic>?;
          final List list = data['data']['participants'] ?? [];
          _participantsCount = data['data']['participants_count'] as int? ?? list.length;
          _participants = list.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final String delegateId = item['delegate_id']?.toString() ?? idx.toString();
            final String fullName = item['full_name']?.toString() ?? 'Participant';
            final String designation = item['designation']?.toString() ?? '';
            final String organisation = item['organisation']?.toString() ?? '';
            final String title = designation.isNotEmpty && organisation.isNotEmpty
                ? '$designation, $organisation'
                : (designation.isNotEmpty ? designation : (organisation.isNotEmpty ? organisation : 'Attendee'));

            String? profileImage = item['profile_image']?.toString();
            if (profileImage != null && profileImage.contains('/./')) {
              profileImage = profileImage.replaceAll('/./', '/');
            }

            return ParticipantItem(
              id: delegateId,
              name: fullName,
              title: title,
              initials: _getInitials(fullName),
              bg: _getColorForIndex(idx),
              isConnected: false,
              profileImage: (profileImage != null && profileImage.isNotEmpty && profileImage != 'null') ? profileImage : null,
            );
          }).toList();
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Failed to load participants';
        }
      } else {
        _errorMessage = 'Server error: ${fallbackResponse.statusCode}';
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch session participants failed', e, stack);
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void toggleConnect(String id) {
    final index = _participants.indexWhere((p) => p.id == id);
    if (index != -1) {
      _participants[index].isConnected = !_participants[index].isConnected;
      notifyListeners();
    }
  }
}
