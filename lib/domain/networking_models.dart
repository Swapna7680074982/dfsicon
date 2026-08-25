class SessionParticipantItem {
  final int userId;
  final String fullName;
  final String? designation;
  final String? organisationName;
  final String? profileImage;
  final bool isSpeaker;
  final String? roleCode;
  final int? connectionId;
  final String connectionStatus;
  final String action;
  final int? conversationId;

  SessionParticipantItem({
    required this.userId,
    required this.fullName,
    this.designation,
    this.organisationName,
    this.profileImage,
    this.isSpeaker = false,
    this.roleCode,
    this.connectionId,
    this.connectionStatus = 'NONE',
    this.action = 'CONNECT',
    this.conversationId,
  });

  factory SessionParticipantItem.fromJson(Map<String, dynamic> json) {
    String? img = json['profile_image']?.toString();
    if (img != null && img.contains('/./')) {
      img = img.replaceAll('/./', '/');
    }
    return SessionParticipantItem(
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      designation: json['designation']?.toString(),
      organisationName: json['organisation_name']?.toString(),
      profileImage: img,
      isSpeaker: json['is_speaker'] == true || json['is_speaker'] == 1 || json['is_speaker'] == '1',
      roleCode: json['role_code']?.toString(),
      connectionId: json['connection_id'] is int ? json['connection_id'] : int.tryParse(json['connection_id']?.toString() ?? ''),
      connectionStatus: json['connection_status']?.toString() ?? 'NONE',
      action: json['action']?.toString() ?? 'CONNECT',
      conversationId: json['conversation_id'] is int ? json['conversation_id'] : int.tryParse(json['conversation_id']?.toString() ?? ''),
    );
  }
}

class PendingRequestItem {
  final int connectionId;
  final int? assignmentId;
  final String? topicTitle;
  final int userId;
  final String fullName;
  final String? designation;
  final String? organisationName;
  final String? profileImage;
  final String? requestedAt;

  PendingRequestItem({
    required this.connectionId,
    this.assignmentId,
    this.topicTitle,
    required this.userId,
    required this.fullName,
    this.designation,
    this.organisationName,
    this.profileImage,
    this.requestedAt,
  });

  factory PendingRequestItem.fromJson(Map<String, dynamic> json) {
    String? img = json['profile_image']?.toString();
    if (img != null && img.contains('/./')) {
      img = img.replaceAll('/./', '/');
    }
    return PendingRequestItem(
      connectionId: json['connection_id'] is int ? json['connection_id'] : int.tryParse(json['connection_id']?.toString() ?? '0') ?? 0,
      assignmentId: json['assignment_id'] is int ? json['assignment_id'] : int.tryParse(json['assignment_id']?.toString() ?? ''),
      topicTitle: json['topic_title']?.toString(),
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      designation: json['designation']?.toString(),
      organisationName: json['organisation_name']?.toString(),
      profileImage: img,
      requestedAt: json['requested_at']?.toString(),
    );
  }
}

class MyConnectionItem {
  final int connectionId;
  final int? assignmentId;
  final String? topicTitle;
  final int userId;
  final String fullName;
  final String? designation;
  final String? organisationName;
  final String? profileImage;
  final int? conversationId;

  MyConnectionItem({
    required this.connectionId,
    this.assignmentId,
    this.topicTitle,
    required this.userId,
    required this.fullName,
    this.designation,
    this.organisationName,
    this.profileImage,
    this.conversationId,
  });

  factory MyConnectionItem.fromJson(Map<String, dynamic> json) {
    String? img = json['profile_image']?.toString();
    if (img != null && img.contains('/./')) {
      img = img.replaceAll('/./', '/');
    }
    return MyConnectionItem(
      connectionId: json['connection_id'] is int ? json['connection_id'] : int.tryParse(json['connection_id']?.toString() ?? '0') ?? 0,
      assignmentId: json['assignment_id'] is int ? json['assignment_id'] : int.tryParse(json['assignment_id']?.toString() ?? ''),
      topicTitle: json['topic_title']?.toString(),
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      designation: json['designation']?.toString(),
      organisationName: json['organisation_name']?.toString(),
      profileImage: img,
      conversationId: json['conversation_id'] is int ? json['conversation_id'] : int.tryParse(json['conversation_id']?.toString() ?? ''),
    );
  }
}

class ConversationItem {
  final int conversationId;
  final String type; // "DIRECT" or "GROUP"
  final int? assignmentId;
  final String? topicTitle;
  final String title;
  final String? subtitle;
  final String? image;
  final int? peerId;
  final int? connectionId;
  final int memberCount;
  final bool isOwner;
  final bool ownerLeft;
  final String? lastMessage;
  final String? lastMessageAt;
  final int unreadCount;
  final bool isMuted;
  final bool isReadOnly;
  final String? notice;

  ConversationItem({
    required this.conversationId,
    required this.type,
    this.assignmentId,
    this.topicTitle,
    required this.title,
    this.subtitle,
    this.image,
    this.peerId,
    this.connectionId,
    this.memberCount = 1,
    this.isOwner = false,
    this.ownerLeft = false,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isReadOnly = false,
    this.notice,
  });

  bool get isGroup => type.toUpperCase() == 'GROUP';

  String get displayLastMessage {
    if (lastMessage != null && lastMessage!.trim().isNotEmpty) {
      return lastMessage!.trim();
    }
    if (subtitle != null && subtitle!.trim().isNotEmpty) {
      return subtitle!.trim();
    }
    return isGroup ? 'Group created' : 'Connection established';
  }

  factory ConversationItem.fromJson(Map<String, dynamic> json) {
    String? img = json['image']?.toString();
    if (img != null && img.contains('/./')) {
      img = img.replaceAll('/./', '/');
    }
    return ConversationItem(
      conversationId: json['conversation_id'] is int ? json['conversation_id'] : int.tryParse(json['conversation_id']?.toString() ?? '0') ?? 0,
      type: json['type']?.toString() ?? 'DIRECT',
      assignmentId: json['assignment_id'] is int ? json['assignment_id'] : int.tryParse(json['assignment_id']?.toString() ?? ''),
      topicTitle: json['topic_title']?.toString(),
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      image: img,
      peerId: json['peer_id'] is int ? json['peer_id'] : int.tryParse(json['peer_id']?.toString() ?? ''),
      connectionId: json['connection_id'] is int ? json['connection_id'] : int.tryParse(json['connection_id']?.toString() ?? ''),
      memberCount: json['member_count'] is int ? json['member_count'] : int.tryParse(json['member_count']?.toString() ?? '1') ?? 1,
      isOwner: json['is_owner'] == true || json['is_owner'] == 1 || json['is_owner'] == '1',
      ownerLeft: json['owner_left'] == true || json['owner_left'] == 1 || json['owner_left'] == '1',
      lastMessage: json['last_message']?.toString(),
      lastMessageAt: json['last_message_at']?.toString(),
      unreadCount: json['unread_count'] is int ? json['unread_count'] : int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0,
      isMuted: json['is_muted'] == true || json['is_muted'] == 1 || json['is_muted'] == '1',
      isReadOnly: json['is_read_only'] == true || json['is_read_only'] == 1 || json['is_read_only'] == '1',
      notice: json['notice']?.toString(),
    );
  }
}

class MessageItem {
  final int messageId;
  final int? conversationId;
  final String type; // "TEXT", "FILE", etc.
  final bool isMine;
  final int? senderId;
  final String? senderName;
  final String? senderImage;
  final String? body;
  final String? systemEvent;
  final dynamic systemMeta;
  final String? systemText;
  final String? attachmentUrl;
  final String? attachmentName;
  final String? attachmentMime;
  final int? attachmentSize;
  final bool isDeleted;
  final String createdAt;

  MessageItem({
    required this.messageId,
    this.conversationId,
    required this.type,
    required this.isMine,
    this.senderId,
    this.senderName,
    this.senderImage,
    this.body,
    this.systemEvent,
    this.systemMeta,
    this.systemText,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentMime,
    this.attachmentSize,
    this.isDeleted = false,
    required this.createdAt,
  });

  String get displayText {
    if (body != null && body!.trim().isNotEmpty) {
      return body!.trim();
    }
    if (systemText != null && systemText!.trim().isNotEmpty) {
      return systemText!.trim();
    }
    if (systemEvent != null && systemEvent!.trim().isNotEmpty) {
      final eventUpper = systemEvent!.toUpperCase();
      if (eventUpper.contains('CONNECT') || eventUpper.contains('ACCEPT')) {
        return 'Connection established';
      } else if (eventUpper.contains('GROUP')) {
        return 'Group created';
      } else if (eventUpper.contains('CREATE')) {
        return 'Conversation created';
      }
      return systemEvent!;
    }
    if (attachmentUrl != null && attachmentUrl!.isNotEmpty) {
      return '';
    }
    return 'Connection established';
  }

  factory MessageItem.fromJson(Map<String, dynamic> json) {
    String? img = json['sender_image']?.toString();
    if (img != null && img.contains('/./')) {
      img = img.replaceAll('/./', '/');
    }
    String? attUrl = json['attachment_url']?.toString();
    if (attUrl != null && attUrl.contains('/./')) {
      attUrl = attUrl.replaceAll('/./', '/');
    }

    return MessageItem(
      messageId: json['message_id'] is int ? json['message_id'] : int.tryParse(json['message_id']?.toString() ?? '0') ?? 0,
      conversationId: json['conversation_id'] is int ? json['conversation_id'] : int.tryParse(json['conversation_id']?.toString() ?? ''),
      type: json['type']?.toString() ?? 'TEXT',
      isMine: json['is_mine'] == true || json['is_mine'] == 1 || json['is_mine'] == '1',
      senderId: json['sender_id'] is int ? json['sender_id'] : int.tryParse(json['sender_id']?.toString() ?? ''),
      senderName: json['sender_name']?.toString(),
      senderImage: img,
      body: json['body']?.toString(),
      systemEvent: json['system_event']?.toString(),
      systemMeta: json['system_meta'],
      systemText: json['system_text']?.toString(),
      attachmentUrl: attUrl,
      attachmentName: json['attachment_name']?.toString(),
      attachmentMime: json['attachment_mime']?.toString(),
      attachmentSize: json['attachment_size'] is int ? json['attachment_size'] : int.tryParse(json['attachment_size']?.toString() ?? ''),
      isDeleted: json['is_deleted'] == true || json['is_deleted'] == 1 || json['is_deleted'] == '1',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class GroupMemberItem {
  final int userId;
  final String fullName;
  final String? designation;
  final String? organisationName;
  final String? profileImage;
  final String role; // "OWNER", "MEMBER"
  final bool isMe;
  final String? joinedAt;

  GroupMemberItem({
    required this.userId,
    required this.fullName,
    this.designation,
    this.organisationName,
    this.profileImage,
    required this.role,
    this.isMe = false,
    this.joinedAt,
  });

  factory GroupMemberItem.fromJson(Map<String, dynamic> json) {
    String? img = json['profile_image']?.toString();
    if (img != null && img.contains('/./')) {
      img = img.replaceAll('/./', '/');
    }
    return GroupMemberItem(
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      designation: json['designation']?.toString(),
      organisationName: json['organisation_name']?.toString(),
      profileImage: img,
      role: json['role']?.toString() ?? 'MEMBER',
      isMe: json['is_me'] == true || json['is_me'] == 1 || json['is_me'] == '1',
      joinedAt: json['joined_at']?.toString(),
    );
  }
}

class GroupDetailsData {
  final int conversationId;
  final String groupName;
  final String? groupDescription;
  final String? groupImage;
  final int? assignmentId;
  final String? topicTitle;
  final int ownerId;
  final bool ownerLeft;
  final bool isOwner;
  final int memberCount;
  final String status;
  final bool isReadOnly;
  final List<GroupMemberItem> members;

  GroupDetailsData({
    required this.conversationId,
    required this.groupName,
    this.groupDescription,
    this.groupImage,
    this.assignmentId,
    this.topicTitle,
    required this.ownerId,
    this.ownerLeft = false,
    this.isOwner = false,
    this.memberCount = 0,
    this.status = 'ACTIVE',
    this.isReadOnly = false,
    required this.members,
  });

  factory GroupDetailsData.fromJson(Map<String, dynamic> json) {
    String? img = json['group_image']?.toString();
    if (img != null && img.contains('/./')) {
      img = img.replaceAll('/./', '/');
    }
    final membersList = (json['members'] as List?)
            ?.map((m) => GroupMemberItem.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];

    return GroupDetailsData(
      conversationId: json['conversation_id'] is int ? json['conversation_id'] : int.tryParse(json['conversation_id']?.toString() ?? '0') ?? 0,
      groupName: json['group_name']?.toString() ?? '',
      groupDescription: json['group_description']?.toString(),
      groupImage: img,
      assignmentId: json['assignment_id'] is int ? json['assignment_id'] : int.tryParse(json['assignment_id']?.toString() ?? ''),
      topicTitle: json['topic_title']?.toString(),
      ownerId: json['owner_id'] is int ? json['owner_id'] : int.tryParse(json['owner_id']?.toString() ?? '0') ?? 0,
      ownerLeft: json['owner_left'] == true || json['owner_left'] == 1 || json['owner_left'] == '1',
      isOwner: json['is_owner'] == true || json['is_owner'] == 1 || json['is_owner'] == '1',
      memberCount: json['member_count'] is int ? json['member_count'] : int.tryParse(json['member_count']?.toString() ?? '0') ?? membersList.length,
      status: json['status']?.toString() ?? 'ACTIVE',
      isReadOnly: json['is_read_only'] == true || json['is_read_only'] == 1 || json['is_read_only'] == '1',
      members: membersList,
    );
  }
}

class SendMessageResult {
  final bool success;
  final MessageItem? message;
  final String? errorMessage;
  final String? errorCode;

  SendMessageResult({
    required this.success,
    this.message,
    this.errorMessage,
    this.errorCode,
  });
}

