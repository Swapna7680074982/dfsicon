import 'package:flutter/material.dart';

class ParticipantItem {
  final String id;
  final String name;
  final String title;
  final String initials;
  final Color bg;
  bool isConnected;

  ParticipantItem({
    required this.id,
    required this.name,
    required this.title,
    required this.initials,
    required this.bg,
    this.isConnected = false,
  });
}

class ConnectionsProvider extends ChangeNotifier {
  final List<ParticipantItem> _participants = [
    ParticipantItem(
      id: 'p1',
      name: 'Marcus Johnson',
      title: 'VP Engineering, ChainLogic',
      initials: 'MJ',
      bg: const Color(0xFFE0DBFC),
      isConnected: false,
    ),
    ParticipantItem(
      id: 'p2',
      name: 'Emily Rodriguez',
      title: 'Head of Design, DesignLab',
      initials: 'ER',
      bg: const Color(0xFFD1FAE5),
      isConnected: false,
    ),
    ParticipantItem(
      id: 'p3',
      name: 'Dr. Alan Park',
      title: 'Research Director, Quan',
      initials: 'AP',
      bg: const Color(0xFFFEF3C7),
      isConnected: true,
    ),
    ParticipantItem(
      id: 'p4',
      name: 'Lisa Wong',
      title: 'CEO, GreenFuture Ventures',
      initials: 'LW',
      bg: const Color(0xFFFCE7F3),
      isConnected: false,
    ),
    ParticipantItem(
      id: 'p5',
      name: 'Raj Kumar',
      title: 'CTO, NexusTech',
      initials: 'RK',
      bg: const Color(0xFFE0E7FF),
      isConnected: false,
    ),
    ParticipantItem(
      id: 'p6',
      name: 'Aisha Mensah',
      title: 'Product Lead, InnovateLab',
      initials: 'AM',
      bg: const Color(0xFFCCFBF1),
      isConnected: false,
    ),
    ParticipantItem(
      id: 'p7',
      name: 'Thomas Ng',
      title: 'Data Scientist, DataSync',
      initials: 'TN',
      bg: const Color(0xFFF1F5F9),
      isConnected: true,
    ),
    ParticipantItem(
      id: 'p8',
      name: 'Sofia Okonjo',
      title: 'UX Researcher, DesignLab',
      initials: 'SO',
      bg: const Color(0xFFFFE4E6),
      isConnected: false,
    ),
  ];

  List<ParticipantItem> get participants => _participants;

  void toggleConnect(String id) {
    final index = _participants.indexWhere((p) => p.id == id);
    if (index != -1) {
      _participants[index].isConnected = !_participants[index].isConnected;
      notifyListeners();
    }
  }
}
