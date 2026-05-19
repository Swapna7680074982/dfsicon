import 'package:flutter/material.dart';

class HomeEventInfo {
  final String name;
  final String location;
  final String date;

  HomeEventInfo({
    required this.name,
    required this.location,
    required this.date,
  });
}

class HomeStat {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String value;
  final String label;

  HomeStat({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.value,
    required this.label,
  });
}

class HomeSession {
  final String title;
  final String speaker;
  final String speakerInitials;
  final Color speakerBg;
  final String time;
  final String hall;
  final String gradientStart;
  final String gradientEnd;
  final String imageUrl;

  HomeSession({
    required this.title,
    required this.speaker,
    required this.speakerInitials,
    required this.speakerBg,
    required this.time,
    required this.hall,
    required this.gradientStart,
    required this.gradientEnd,
    required this.imageUrl,
  });
}

class HomeExhibitor {
  final String initials;
  final Color color;
  final String title;
  final String subtitle;
  final String booth;

  HomeExhibitor({
    required this.initials,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.booth,
  });
}

class HomeSightsee {
  final String title;
  final String distance;
  final String cost;
  final String colorStart;
  final String colorEnd;
  final IconData icon;
  final String imageUrl;

  HomeSightsee({
    required this.title,
    required this.distance,
    required this.cost,
    required this.colorStart,
    required this.colorEnd,
    required this.icon,
    required this.imageUrl,
  });
}

class HomeProvider extends ChangeNotifier {
  final HomeEventInfo _eventInfo = HomeEventInfo(
    name: 'TechSummit 2026',
    location: 'Convention Center, Hall 4',
    date: 'Oct 12 - 14, 2026',
  );

  HomeEventInfo get eventInfo => _eventInfo;

  final List<HomeStat> _stats = [
    HomeStat(
      icon: Icons.medical_services_outlined,
      iconColor: const Color(0xFF6366F1),
      iconBgColor: const Color(0xFFEEF2FF),
      value: '48',
      label: 'Sessions',
    ),
    HomeStat(
      icon: Icons.business,
      iconColor: const Color(0xFFEC4899),
      iconBgColor: const Color(0xFFFDF2F8),
      value: '120+',
      label: 'Exhibitors',
    ),
    HomeStat(
      icon: Icons.people_outline,
      iconColor: const Color(0xFF10B981),
      iconBgColor: const Color(0xFFECFDF5),
      value: '2.4K',
      label: 'Delegates',
    ),
  ];

  List<HomeStat> get stats => _stats;

  final List<HomeSession> _featuredSessions = [
    HomeSession(
      title: 'AI-Powered Diagnostics: Transforming Clinical Decision-Making',
      speaker: 'Dr. Sarah Chen',
      speakerInitials: 'SC',
      speakerBg: const Color(0xFF6366F1),
      time: '09:00 AM',
      hall: 'Hall A',
      gradientStart: '0xFF4F46E5',
      gradientEnd: '0xFF818CF8',
      imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=400&auto=format&fit=crop',
    ),
    HomeSession(
      title: 'Electronic Health Records: Achieving True Interoperability',
      speaker: 'Dr. Marcus Johnson',
      speakerInitials: 'MJ',
      speakerBg: const Color(0xFFEC4899),
      time: '10:30 AM',
      hall: 'Hall B',
      gradientStart: '0xFFDB2777',
      gradientEnd: '0xFFF472B6',
      imageUrl: 'https://images.unsplash.com/photo-1504868584819-f8e8b4b6d7e3?w=400&auto=format&fit=crop',
    ),
  ];

  List<HomeSession> get featuredSessions => _featuredSessions;

  final List<HomeExhibitor> _exhibitors = [
    HomeExhibitor(
      initials: 'MC',
      color: const Color(0xFF1E3A8A),
      title: 'MedCore Health',
      subtitle: 'Health IT & EMR',
      booth: 'Booth A-12',
    ),
    HomeExhibitor(
      initials: 'HB',
      color: const Color(0xFF8B5CF6),
      title: 'HealthBridge',
      subtitle: 'Interoperability',
      booth: 'Booth B-05',
    ),
    HomeExhibitor(
      initials: 'BS',
      color: const Color(0xFF10B981),
      title: 'BioSync Analytics',
      subtitle: 'Clinical Data & Research',
      booth: 'Booth C-08',
    ),
  ];

  List<HomeExhibitor> get exhibitors => _exhibitors;

  final List<HomeSightsee> _sightseeSpots = [
    HomeSightsee(
      title: 'Grand City Museum',
      distance: '1.2 km',
      cost: 'Free',
      colorStart: '0xFFF59E0B',
      colorEnd: '0xFFFCD34D',
      icon: Icons.museum_outlined,
      imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=600',
    ),
    HomeSightsee(
      title: 'Skyline Observation Deck',
      distance: '2.4 km',
      cost: '\$18',
      colorStart: '0xFFEF4444',
      colorEnd: '0xFFFCA5A5',
      icon: Icons.apartment_outlined,
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600',
    ),
  ];

  List<HomeSightsee> get sightseeSpots => _sightseeSpots;
}
