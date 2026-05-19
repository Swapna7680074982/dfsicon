import 'package:flutter/material.dart';

class ConnectionRequest {
  final String id;
  final String name;
  final String title;
  final String initials;
  final Color bg;

  ConnectionRequest({
    required this.id,
    required this.name,
    required this.title,
    required this.initials,
    required this.bg,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final String time;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.time,
    required this.isMe,
  });
}

class ChatConversation {
  final String id;
  final String name;
  final String title;
  final String initials;
  final Color bg;
  final List<ChatMessage> messages;
  int unreadCount;
  String lastMessageTime;
  final bool isGroup;
  final int memberCount;
  final String description;

  ChatConversation({
    required this.id,
    required this.name,
    this.title = '',
    required this.initials,
    required this.bg,
    required this.messages,
    this.unreadCount = 0,
    required this.lastMessageTime,
    this.isGroup = false,
    this.memberCount = 1,
    this.description = '',
  });

  String get latestMessageContent {
    if (messages.isEmpty) return '';
    return messages.last.content;
  }
}

class NetworkProvider extends ChangeNotifier {
  final List<ConnectionRequest> _requests = [
    ConnectionRequest(
      id: 'req1',
      name: 'James Osei',
      title: 'Product Manager, NexusPay',
      initials: 'JO',
      bg: const Color(0xFFFEF3C7),
    ),
    ConnectionRequest(
      id: 'req2',
      name: 'Priya Nair',
      title: 'Data Scientist, BioSync Analy',
      initials: 'PN',
      bg: const Color(0xFFD1FAE5),
    ),
    ConnectionRequest(
      id: 'req3',
      name: 'David Kim',
      title: 'UX Lead, HealthFlow',
      initials: 'DK',
      bg: const Color(0xFFE0F2FE),
    ),
    ConnectionRequest(
      id: 'req4',
      name: 'Emma Watson',
      title: 'VP Research, BioLabs',
      initials: 'EW',
      bg: const Color(0xFFFCE7F3),
    ),
  ];

  final List<ChatConversation> _conversations = [
    ChatConversation(
      id: 'c1',
      name: 'Dr. Sarah Chen',
      title: 'Chief Cardiologist, HeartCare',
      initials: 'SC',
      bg: const Color(0xFFFEE2E2),
      unreadCount: 2,
      lastMessageTime: '9:45 AM',
      messages: [
        ChatMessage(
          id: 'm1',
          senderId: 'sarah',
          senderName: 'Dr. Sarah Chen',
          content: 'Hi Alex! Really enjoyed your question during my session.',
          time: '9:30 AM',
          isMe: false,
        ),
        ChatMessage(
          id: 'm2',
          senderId: 'me',
          senderName: 'Alex Kumar',
          content: 'Thank you Dr. Chen! It was such an insightful talk. The AI diagnostics case study was remarkable.',
          time: '9:35 AM',
          isMe: true,
        ),
        ChatMessage(
          id: 'm3',
          senderId: 'sarah',
          senderName: 'Dr. Sarah Chen',
          content: "I'd love to discuss more about our research. Are you free for a quick coffee?",
          time: '9:40 AM',
          isMe: false,
        ),
        ChatMessage(
          id: 'm4',
          senderId: 'sarah',
          senderName: 'Dr. Sarah Chen',
          content: 'Looking forward to our discussion! 😊',
          time: '9:45 AM',
          isMe: false,
        ),
      ],
    ),
    ChatConversation(
      id: 'c2',
      name: 'MedCore Health Team',
      initials: 'MC',
      bg: const Color(0xFFF3E8FF),
      unreadCount: 5,
      lastMessageTime: '9:12 AM',
      isGroup: true,
      memberCount: 8,
      description: 'Coordination group for MedCore Hea',
      messages: [
        ChatMessage(
          id: 'mg1',
          senderId: 'marcus',
          senderName: 'Marcus',
          content: 'Team, booth setup is done. Ready for visitors!',
          time: '8:30 AM',
          isMe: false,
        ),
        ChatMessage(
          id: 'mg2',
          senderId: 'me',
          senderName: 'Alex Kumar',
          content: "Great! I'll be there by 9.",
          time: '8:45 AM',
          isMe: true,
        ),
        ChatMessage(
          id: 'mg3',
          senderId: 'sarah',
          senderName: 'Sarah',
          content: 'Meeting confirmed for 3 PM at Booth A-12',
          time: '9:12 AM',
          isMe: false,
        ),
        ChatMessage(
          id: 'mg4',
          senderId: 'me',
          senderName: 'Alex Kumar',
          content: "I'll be there 👍",
          time: '9:20 AM',
          isMe: true,
        ),
        ChatMessage(
          id: 'mg5',
          senderId: 'marcus',
          senderName: 'Marcus',
          content: "Don't forget your TechCorp badge!",
          time: '9:30 AM',
          isMe: false,
        ),
      ],
    ),
    ChatConversation(
      id: 'c3',
      name: 'Dr. Marcus Johnson',
      title: 'VP Engineering, ChainLogic',
      initials: 'MJ',
      bg: const Color(0xFFE0F2FE),
      unreadCount: 0,
      lastMessageTime: 'Yesterday',
      messages: [
        ChatMessage(
          id: 'm3_1',
          senderId: 'marcus',
          senderName: 'Dr. Marcus Johnson',
          content: 'Great session on EHR interoperability!',
          time: 'Yesterday',
          isMe: false,
        ),
      ],
    ),
    ChatConversation(
      id: 'c4',
      name: 'Clinical Research Group',
      initials: 'CRG',
      bg: const Color(0xFFFFEDD5),
      unreadCount: 0,
      lastMessageTime: 'Yesterday',
      isGroup: true,
      memberCount: 14,
      description: 'Researchers and trial coordinators at Health',
      messages: [
        ChatMessage(
          id: 'mg4_1',
          senderId: 'emily',
          senderName: 'Emily',
          content: 'would love to chat about decentralized trials!',
          time: 'Yesterday',
          isMe: false,
        ),
      ],
    ),
    ChatConversation(
      id: 'c5',
      name: 'Dr. Lisa Wong',
      title: 'CEO, GreenFuture Ventures',
      initials: 'LW',
      bg: const Color(0xFFFCE7F3),
      unreadCount: 1,
      lastMessageTime: 'Mon',
      messages: [
        ChatMessage(
          id: 'm5_1',
          senderId: 'lisa',
          senderName: 'Dr. Lisa Wong',
          content: 'See you at the value-based care panel',
          time: 'Mon',
          isMe: false,
        ),
      ],
    ),
    ChatConversation(
      id: 'c6',
      name: 'AI in Medicine Enthusiasts',
      initials: 'AIM',
      bg: const Color(0xFFE0F2FE),
      unreadCount: 14,
      lastMessageTime: 'Sun',
      isGroup: true,
      memberCount: 31,
      description: 'Attendees passionate about AI appli',
      messages: [
        ChatMessage(
          id: 'mg6_1',
          senderId: 'alan',
          senderName: 'Alan',
          content: 'Excited about the upcoming AI workshops!',
          time: 'Sun',
          isMe: false,
        ),
      ],
    ),
  ];

  List<ConnectionRequest> get requests => _requests;
  List<ChatConversation> get conversations => _conversations;

  List<ChatConversation> get directChats {
    return _conversations.where((c) => !c.isGroup).toList();
  }

  List<ChatConversation> get groupChats {
    return _conversations.where((c) => c.isGroup).toList();
  }

  void acceptRequest(String id) {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index != -1) {
      final req = _requests[index];
      _requests.removeAt(index);

      final newConv = ChatConversation(
        id: 'c_new_${req.id}',
        name: req.name,
        title: req.title,
        initials: req.initials,
        bg: req.bg,
        unreadCount: 0,
        lastMessageTime: 'Now',
        messages: [
          ChatMessage(
            id: 'm_init_${req.id}',
            senderId: 'system',
            senderName: 'System',
            content: 'You are now connected! Say hi to ${req.name}.',
            time: 'Now',
            isMe: false,
          ),
        ],
      );

      _conversations.insert(0, newConv);
      notifyListeners();
    }
  }

  void addMessage(String conversationId, String text) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      final now = DateTime.now();
      final timeStr = "${now.hour > 12 ? now.hour - 12 : now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
      
      final msg = ChatMessage(
        id: 'msg_new_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'me',
        senderName: 'Alex Kumar',
        content: text,
        time: timeStr,
        isMe: true,
      );

      _conversations[index].messages.add(msg);
      _conversations[index].lastMessageTime = timeStr;
      _conversations[index].unreadCount = 0;
      notifyListeners();
    }
  }

  void createGroupChat(String name, String description, List<String> participantNames) {
    final newGroup = ChatConversation(
      id: 'c_group_new_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      initials: name.substring(0, name.length > 2 ? 3 : name.length).toUpperCase(),
      bg: const Color(0xFFF3E8FF),
      unreadCount: 0,
      lastMessageTime: 'Now',
      isGroup: true,
      memberCount: participantNames.length + 1,
      description: description,
      messages: [
        ChatMessage(
          id: 'mg_init_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'system',
          senderName: 'System',
          content: 'Group chat created. Welcome to $name!',
          time: 'Now',
          isMe: false,
        ),
      ],
    );

    _conversations.insert(0, newGroup);
    notifyListeners();
  }

  void markAsRead(String conversationId) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      _conversations[index].unreadCount = 0;
      notifyListeners();
    }
  }
}
