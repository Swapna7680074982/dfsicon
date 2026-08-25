import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dfsicon/domain/api_service.dart';
import 'package:dfsicon/domain/networking_models.dart';
import 'package:dfsicon/main.dart';
import 'package:dfsicon/utils/custom_logger.dart';

class NetworkProvider extends ChangeNotifier {
  List<ConversationItem> _conversations = [];
  List<PendingRequestItem> _pendingRequests = [];
  List<MyConnectionItem> _myConnections = [];
  List<SessionParticipantItem> _sessionParticipants = [];
  
  final Map<int, List<MessageItem>> _conversationMessages = {};
  final Map<int, GroupDetailsData> _groupDetailsMap = {};
  
  int _totalUnreadCount = 0;
  bool _isLoadingConversations = false;
  bool _isLoadingRequests = false;
  bool _isLoadingConnections = false;
  bool _isLoadingMessages = false;
  bool _isLoadingGroupDetails = false;
  bool _isLoadingSessionParticipants = false;
  String? _errorMessage;

  // Getters
  List<ConversationItem> get conversations => _conversations;
  List<ConversationItem> get directChats => _conversations.where((c) => !c.isGroup).toList();
  List<ConversationItem> get groupChats => _conversations.where((c) => c.isGroup).toList();
  List<PendingRequestItem> get requests => _pendingRequests;
  List<PendingRequestItem> get pendingRequests => _pendingRequests;
  List<MyConnectionItem> get myConnections => _myConnections;
  List<SessionParticipantItem> get sessionParticipants => _sessionParticipants;
  int get totalUnreadCount => _totalUnreadCount;

  bool get isLoadingConversations => _isLoadingConversations;
  bool get isLoadingRequests => _isLoadingRequests;
  bool get isLoadingConnections => _isLoadingConnections;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isLoadingGroupDetails => _isLoadingGroupDetails;
  bool get isLoadingSessionParticipants => _isLoadingSessionParticipants;
  String? get errorMessage => _errorMessage;

  List<MessageItem> getMessages(int conversationId) {
    return _conversationMessages[conversationId] ?? [];
  }

  GroupDetailsData? getGroupDetails(int conversationId) {
    return _groupDetailsMap[conversationId];
  }

  int? getConnectionIdForConversation(ConversationItem conversation) {
    if (conversation.connectionId != null && conversation.connectionId! > 0) {
      return conversation.connectionId;
    }
    for (final conn in _myConnections) {
      if (conn.conversationId == conversation.conversationId || (conversation.peerId != null && conn.userId == conversation.peerId)) {
        return conn.connectionId;
      }
    }
    for (final part in _sessionParticipants) {
      if (conversation.peerId != null && part.userId == conversation.peerId && part.connectionId != null && part.connectionId! > 0) {
        return part.connectionId;
      }
    }
    return null;
  }

  static String getInitials(String name) {
    if (name.trim().isEmpty) return 'PA';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  static Color getAvatarBg(int index) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF06B6D4), // Cyan
    ];
    return colors[index % colors.length];
  }

  // ==========================================
  // API Call Implementations
  // ==========================================

  // 1. Fetch Conversations
  Future<bool> fetchConversations({
    String? type,
    String? search,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return false;
    _isLoadingConversations = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchNetworkConversations(
        type: type,
        search: search,
        accessToken: accessToken,
      );

      _isLoadingConversations = false;
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List list = data['data'];
          _conversations = list
              .map((item) => ConversationItem.fromJson(item as Map<String, dynamic>))
              .toList();
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Failed to load conversations';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch conversations failed', e, stack);
      _isLoadingConversations = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 2. Fetch Pending Requests
  Future<bool> fetchPendingRequests({
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return false;
    _isLoadingRequests = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchNetworkPendingRequests(
        accessToken: accessToken,
      );

      _isLoadingRequests = false;
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List list = data['data'];
          _pendingRequests = list
              .map((item) => PendingRequestItem.fromJson(item as Map<String, dynamic>))
              .toList();
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Failed to fetch pending requests';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch pending requests failed', e, stack);
      _isLoadingRequests = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 3. Fetch My Connections
  Future<bool> fetchMyConnections({
    dynamic assignmentId,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return false;
    _isLoadingConnections = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchMyNetworkConnections(
        assignmentId: assignmentId,
        accessToken: accessToken,
      );

      _isLoadingConnections = false;
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List list = data['data'];
          _myConnections = list
              .map((item) => MyConnectionItem.fromJson(item as Map<String, dynamic>))
              .toList();
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Failed to fetch connections';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch connections failed', e, stack);
      _isLoadingConnections = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 4. Fetch Session Participants
  Future<bool> fetchSessionParticipants({
    dynamic assignmentId,
    String? search,
    int page = 1,
    int limit = 20,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return false;
    _isLoadingSessionParticipants = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchNetworkSessionParticipants(
        assignmentId: assignmentId,
        search: search,
        page: page,
        limit: limit,
        accessToken: accessToken,
      );

      _isLoadingSessionParticipants = false;
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List list = data['data'];
          _sessionParticipants = list
              .map((item) => SessionParticipantItem.fromJson(item as Map<String, dynamic>))
              .toList();
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Failed to fetch participants';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch session participants failed', e, stack);
      _isLoadingSessionParticipants = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 5. Send Connection Request
  Future<bool> sendConnectionRequest({
    dynamic assignmentId,
    required dynamic targetId,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return false;

    try {
      final response = await ApiService.sendNetworkRequest(
        assignmentId: assignmentId,
        targetId: targetId,
        accessToken: accessToken,
      );

      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          await fetchPendingRequests(accessToken: accessToken);
          await fetchConversations(accessToken: accessToken);
          return true;
        }
      }
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Send connection request failed', e, stack);
      return false;
    }
  }

  // 6. Respond Connection Request (ACCEPT / REJECT)
  Future<bool> respondConnectionRequest({
    required dynamic connectionId,
    required String action,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return false;

    try {
      final response = await ApiService.respondNetworkRequest(
        connectionId: connectionId,
        action: action,
        accessToken: accessToken,
      );

      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _pendingRequests.removeWhere((r) => r.connectionId == connectionId || r.connectionId.toString() == connectionId.toString());
          notifyListeners();
          await fetchConversations(accessToken: accessToken);
          await fetchMyConnections(accessToken: accessToken);
          return true;
        }
      }
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Respond connection request failed', e, stack);
      return false;
    }
  }

  // 7. Disconnect Connection
  Future<bool> disconnectConnection({
    required dynamic connectionId,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return false;

    try {
      final response = await ApiService.disconnectNetworkConnection(
        connectionId: connectionId,
        accessToken: accessToken,
      );

      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _myConnections.removeWhere((c) => c.connectionId == connectionId || c.connectionId.toString() == connectionId.toString());
          notifyListeners();
          await fetchConversations(accessToken: accessToken);
          return true;
        }
      }
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Disconnect connection failed', e, stack);
      return false;
    }
  }

  // 8. Cancel Request
  Future<bool> cancelConnectionRequest({
    required dynamic connectionId,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return false;

    try {
      final response = await ApiService.cancelNetworkRequest(
        connectionId: connectionId,
        accessToken: accessToken,
      );

      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _pendingRequests.removeWhere((r) => r.connectionId == connectionId || r.connectionId.toString() == connectionId.toString());
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Cancel connection request failed', e, stack);
      return false;
    }
  }

  // 9. Fetch Messages for Conversation
  Future<List<MessageItem>> fetchMessages({
    required dynamic conversationId,
    dynamic beforeId,
    int limit = 30,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return [];
    _isLoadingMessages = true;
    notifyListeners();

    try {
      final response = await ApiService.fetchNetworkMessages(
        conversationId: conversationId,
        beforeId: beforeId,
        limit: limit,
        accessToken: accessToken,
      );

      _isLoadingMessages = false;
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return [];
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List list = data['data'];
          final fetchedMessages = list
              .map((item) => MessageItem.fromJson(item as Map<String, dynamic>))
              .toList();

          final int convIdInt = conversationId is int ? conversationId : int.tryParse(conversationId.toString()) ?? 0;
          
          if (beforeId == null) {
            _conversationMessages[convIdInt] = fetchedMessages;
          } else {
            final existing = _conversationMessages[convIdInt] ?? [];
            _conversationMessages[convIdInt] = [...fetchedMessages, ...existing];
          }
          notifyListeners();
          return _conversationMessages[convIdInt]!;
        }
      }
      notifyListeners();
      return [];
    } catch (e, stack) {
      CustomLogger.logError('Fetch messages failed', e, stack);
      _isLoadingMessages = false;
      notifyListeners();
      return [];
    }
  }

  // 10. Send Text Message
  Future<SendMessageResult> sendTextMessage({
    required dynamic conversationId,
    required String body,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty || body.trim().isEmpty) {
      return SendMessageResult(success: false, errorMessage: 'Message cannot be empty.');
    }

    try {
      final response = await ApiService.sendNetworkMessageText(
        conversationId: conversationId,
        body: body.trim(),
        accessToken: accessToken,
      );

      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return SendMessageResult(
          success: false,
          errorMessage: 'Session expired. Please log in again.',
          errorCode: 'UNAUTHORIZED',
        );
      }

      Map<String, dynamic>? data;
      try {
        data = json.decode(response.body) as Map<String, dynamic>?;
      } catch (_) {}

      if (response.statusCode == 200 && data != null && data['status'] == true && data['data'] != null) {
        final newMsg = MessageItem.fromJson(data['data'] as Map<String, dynamic>);
        final int convIdInt = conversationId is int ? conversationId : int.tryParse(conversationId.toString()) ?? 0;

        final list = _conversationMessages[convIdInt] ?? [];
        list.add(newMsg);
        _conversationMessages[convIdInt] = list;
        notifyListeners();

        fetchConversations(accessToken: accessToken);
        return SendMessageResult(success: true, message: newMsg);
      } else {
        final errorMsg = data != null && data['message'] != null && data['message'].toString().isNotEmpty
            ? data['message'].toString()
            : 'Failed to send message (${response.statusCode})';
        final errorCode = data != null ? data['code']?.toString() : null;
        return SendMessageResult(
          success: false,
          errorMessage: errorMsg,
          errorCode: errorCode,
        );
      }
    } catch (e, stack) {
      CustomLogger.logError('Send text message failed', e, stack);
      return SendMessageResult(
        success: false,
        errorMessage: 'An error occurred while sending message.',
      );
    }
  }

  // 11. Send Attachment Message
  Future<SendMessageResult> sendAttachmentMessage({
    required dynamic conversationId,
    String? body,
    required File attachmentFile,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) {
      return SendMessageResult(success: false, errorMessage: 'Authentication required.');
    }

    try {
      final response = await ApiService.sendNetworkMessageAttachment(
        conversationId: conversationId,
        body: body,
        attachmentFile: attachmentFile,
        accessToken: accessToken,
      );

      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return SendMessageResult(
          success: false,
          errorMessage: 'Session expired. Please log in again.',
          errorCode: 'UNAUTHORIZED',
        );
      }

      Map<String, dynamic>? data;
      try {
        data = json.decode(response.body) as Map<String, dynamic>?;
      } catch (_) {}

      if (response.statusCode == 200 && data != null && data['status'] == true && data['data'] != null) {
        final newMsg = MessageItem.fromJson(data['data'] as Map<String, dynamic>);
        final int convIdInt = conversationId is int ? conversationId : int.tryParse(conversationId.toString()) ?? 0;

        final list = _conversationMessages[convIdInt] ?? [];
        list.add(newMsg);
        _conversationMessages[convIdInt] = list;
        notifyListeners();

        fetchConversations(accessToken: accessToken);
        return SendMessageResult(success: true, message: newMsg);
      } else {
        final errorMsg = data != null && data['message'] != null && data['message'].toString().isNotEmpty
            ? data['message'].toString()
            : 'Failed to send attachment (${response.statusCode})';
        final errorCode = data != null ? data['code']?.toString() : null;
        return SendMessageResult(
          success: false,
          errorMessage: errorMsg,
          errorCode: errorCode,
        );
      }
    } catch (e, stack) {
      CustomLogger.logError('Send attachment message failed', e, stack);
      return SendMessageResult(
        success: false,
        errorMessage: 'An error occurred while sending attachment.',
      );
    }
  }

  // 12. Mark as Read
  Future<bool> markAsRead({
    required dynamic conversationId,
    dynamic uptoMessageId,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return false;

    try {
      final response = await ApiService.markNetworkRead(
        conversationId: conversationId,
        uptoMessageId: uptoMessageId,
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final int convIdInt = conversationId is int ? conversationId : int.tryParse(conversationId.toString()) ?? 0;
          final idx = _conversations.indexWhere((c) => c.conversationId == convIdInt);
          if (idx != -1) {
            _conversations[idx] = ConversationItem(
              conversationId: _conversations[idx].conversationId,
              type: _conversations[idx].type,
              assignmentId: _conversations[idx].assignmentId,
              topicTitle: _conversations[idx].topicTitle,
              title: _conversations[idx].title,
              subtitle: _conversations[idx].subtitle,
              image: _conversations[idx].image,
              peerId: _conversations[idx].peerId,
              memberCount: _conversations[idx].memberCount,
              isOwner: _conversations[idx].isOwner,
              ownerLeft: _conversations[idx].ownerLeft,
              lastMessage: _conversations[idx].lastMessage,
              lastMessageAt: _conversations[idx].lastMessageAt,
              unreadCount: 0,
              isMuted: _conversations[idx].isMuted,
              isReadOnly: _conversations[idx].isReadOnly,
              notice: _conversations[idx].notice,
            );
            notifyListeners();
          }
          fetchUnreadCount(accessToken: accessToken);
          return true;
        }
      }
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Mark as read failed', e, stack);
      return false;
    }
  }

  // 13. Fetch Unread Count
  Future<int> fetchUnreadCount({
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return 0;

    try {
      final response = await ApiService.fetchNetworkUnreadCount(
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['total'] != null) {
          _totalUnreadCount = data['total'] is int ? data['total'] : int.tryParse(data['total'].toString()) ?? 0;
          notifyListeners();
          return _totalUnreadCount;
        }
      }
      return 0;
    } catch (e, stack) {
      CustomLogger.logError('Fetch unread count failed', e, stack);
      return 0;
    }
  }

  // 14. Create Group
  Future<int?> createGroup({
    dynamic assignmentId,
    required String groupName,
    String? groupDescription,
    required List<int> memberIds,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty || groupName.trim().isEmpty) return null;

    try {
      final response = await ApiService.createNetworkGroup(
        assignmentId: assignmentId,
        groupName: groupName.trim(),
        groupDescription: groupDescription,
        memberIds: memberIds,
        accessToken: accessToken,
      );

      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return null;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['conversation_id'] != null) {
          final int newConvId = data['conversation_id'] is int ? data['conversation_id'] : int.parse(data['conversation_id'].toString());
          await fetchConversations(accessToken: accessToken);
          return newConvId;
        }
      }
      return null;
    } catch (e, stack) {
      CustomLogger.logError('Create group failed', e, stack);
      return null;
    }
  }

  // 15. Fetch Group Details
  Future<GroupDetailsData?> fetchGroupDetails({
    required dynamic conversationId,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return null;
    _isLoadingGroupDetails = true;
    notifyListeners();

    try {
      final response = await ApiService.fetchNetworkGroupDetails(
        conversationId: conversationId,
        accessToken: accessToken,
      );

      _isLoadingGroupDetails = false;
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return null;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final details = GroupDetailsData.fromJson(data['data'] as Map<String, dynamic>);
          final int convIdInt = conversationId is int ? conversationId : int.tryParse(conversationId.toString()) ?? 0;
          _groupDetailsMap[convIdInt] = details;
          notifyListeners();
          return details;
        }
      }
      notifyListeners();
      return null;
    } catch (e, stack) {
      CustomLogger.logError('Fetch group details failed', e, stack);
      _isLoadingGroupDetails = false;
      notifyListeners();
      return null;
    }
  }

  // 16. Add Group Members
  Future<bool> addGroupMembers({
    required dynamic conversationId,
    required List<int> memberIds,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty || memberIds.isEmpty) return false;

    try {
      final response = await ApiService.addNetworkGroupMembers(
        conversationId: conversationId,
        memberIds: memberIds,
        accessToken: accessToken,
      );

      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          await fetchGroupDetails(conversationId: conversationId, accessToken: accessToken);
          return true;
        }
      }
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Add group members failed', e, stack);
      return false;
    }
  }

  // 17. Remove Group Member
  Future<bool> removeGroupMember({
    required dynamic conversationId,
    List<int>? memberIds,
    dynamic userId,
    required String accessToken,
  }) async {
    final targetUserId = userId ?? (memberIds != null && memberIds.isNotEmpty ? memberIds.first : null);
    if (accessToken.isEmpty || targetUserId == null) return false;

    try {
      final response = await ApiService.removeNetworkGroupMember(
        conversationId: conversationId,
        memberIds: memberIds,
        userId: targetUserId,
        accessToken: accessToken,
      );

      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          await fetchGroupDetails(conversationId: conversationId, accessToken: accessToken);
          return true;
        }
      }
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Remove group member failed', e, stack);
      return false;
    }
  }

  // 18. Leave Group
  Future<bool> leaveGroup({
    required dynamic conversationId,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return false;

    try {
      final response = await ApiService.leaveNetworkGroup(
        conversationId: conversationId,
        accessToken: accessToken,
      );

      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final int convIdInt = conversationId is int ? conversationId : int.tryParse(conversationId.toString()) ?? 0;
          _conversations.removeWhere((c) => c.conversationId == convIdInt);
          _groupDetailsMap.remove(convIdInt);
          notifyListeners();
          fetchConversations(accessToken: accessToken);
          return true;
        }
      }
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Leave group failed', e, stack);
      return false;
    }
  }
}
