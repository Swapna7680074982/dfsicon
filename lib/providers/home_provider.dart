import 'dart:convert';
import 'package:flutter/material.dart';
import '../domain/api_service.dart';
import '../main.dart';

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
  final String? imageUrl;

  HomeExhibitor({
    required this.initials,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.booth,
    this.imageUrl,
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

class HomeProvider with ChangeNotifier {
  List<Map<String, dynamic>> _summits = [];
  bool _isLoading = false;

  HomeEventInfo _eventInfo = HomeEventInfo(
    name: 'TechSummit 2026',
    location: 'Convention Center, Hall 4',
    date: 'Oct 12 - 14, 2026',
  );

  bool get isLoading => _isLoading;
  HomeEventInfo get eventInfo => _eventInfo;
  List<Map<String, dynamic>> get summits => _summits;

  String _formatSummitDates(String start, String end) {
    if (start.isEmpty && end.isEmpty) return 'Oct 12 - 14, 2026';
    if (start.isEmpty) return end;
    if (end.isEmpty) return start;
    
    try {
      final startDate = DateTime.tryParse(start);
      final endDate = DateTime.tryParse(end);
      if (startDate != null && endDate != null) {
        final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final startMonth = months[startDate.month - 1];
        final endMonth = months[endDate.month - 1];
        
        if (startDate.year == endDate.year) {
          if (startDate.month == endDate.month) {
            return '$startMonth ${startDate.day} - ${endDate.day}, ${startDate.year}';
          } else {
            return '$startMonth ${startDate.day} - $endMonth ${endDate.day}, ${startDate.year}';
          }
        } else {
          return '$startMonth ${startDate.day}, ${startDate.year} - $endMonth ${endDate.day}, ${endDate.year}';
        }
      }
    } catch (_) {}
    
    return '$start - $end';
  }

  Future<void> fetchSummits(String accessToken) async {
    if (accessToken.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.fetchSummits(accessToken: accessToken);
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return;
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null && (data['data'] as List).isNotEmpty) {
          _summits = List<Map<String, dynamic>>.from(data['data']);
          final first = _summits.first;
          _eventInfo = HomeEventInfo(
            name: first['summit_title'] ?? 'TechSummit 2026',
            location: first['venue_name'] ?? 'Convention Center, Hall 4',
            date: _formatSummitDates(
              first['summit_start_date']?.toString() ?? '',
              first['summit_end_date']?.toString() ?? '',
            ),
          );

          // Fetch the dynamic sponsors for the current active summit
          final String summitId = first['summit_id']?.toString() ?? '';
          if (summitId.isNotEmpty) {
            await fetchSponsors(summitId, accessToken);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching summits in HomeProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  List<HomeExhibitor> _exhibitors = [
    HomeExhibitor(
      initials: 'MC',
      color: const Color(0xFF1E3A8A),
      title: 'MedCore Health',
      subtitle: 'Health IT & EMR',
      booth: 'Booth A-12',
      imageUrl: 'https://images.unsplash.com/photo-1516841273335-e39b37888115?w=200&fit=crop',
    ),
    HomeExhibitor(
      initials: 'HB',
      color: const Color(0xFF8B5CF6),
      title: 'HealthBridge',
      subtitle: 'Interoperability',
      booth: 'Booth B-05',
      imageUrl: 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=200&fit=crop',
    ),
    HomeExhibitor(
      initials: 'BS',
      color: const Color(0xFF10B981),
      title: 'BioSync Analytics',
      subtitle: 'Clinical Data & Research',
      booth: 'Booth C-08',
      imageUrl: 'https://images.unsplash.com/photo-1530026405186-ed1ea0ac7a63?w=200&fit=crop',
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'featured':
        return const Color(0xFF1E3A8A);
      case 'premium':
        return const Color(0xFF8B5CF6);
      case 'standard':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'EX';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0].isNotEmpty && parts[1].isNotEmpty)
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'EX';
  }

  Future<void> fetchSponsors(String summitId, String accessToken) async {
    try {
      final response = await ApiService.fetchSponsors(
        summitId: summitId,
        accessToken: accessToken,
      );

      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List<dynamic> list = data['data'];
          
          // Only replace if there are active sponsors returned from the API
          if (list.isNotEmpty) {
            final List<HomeExhibitor> fetchedList = [];
            for (var item in list) {
              final String sponsorId = item['sponsor_id']?.toString() ?? '';
              final String companyName = item['company_name']?.toString() ?? '';
              final String category = item['sponsor_category']?.toString() ?? 'Standard';
              
              String? logoUrl;
              final media = item['media'];
              if (media != null) {
                final logos = media['logo'] as List<dynamic>?;
                if (logos != null && logos.isNotEmpty) {
                  logoUrl = logos.first['media_url']?.toString();
                }
              }

              final String initials = _getInitials(companyName);
              final Color bg = _getCategoryColor(category);

              fetchedList.add(
                HomeExhibitor(
                  initials: initials,
                  color: bg,
                  title: companyName,
                  subtitle: category,
                  booth: 'Booth $sponsorId',
                  imageUrl: logoUrl,
                ),
              );
            }
            _exhibitors = fetchedList;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching sponsors in HomeProvider: $e');
    }
  }
}
