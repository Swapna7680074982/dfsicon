import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dfsicon/domain/api_service.dart';
import 'package:dfsicon/utils/custom_logger.dart';
import '../main.dart';

class Exhibitor {
  final String id;
  final String name;
  final String category;
  final String boothCode;
  final String boothZone;
  final String initials;
  final Color bg;
  final String description;
  final List<String> products;
  final String website;
  final String email;
  final String? logoUrl;
  final String? bannerUrl;
  final String? brochureUrl;

  const Exhibitor({
    required this.id,
    required this.name,
    required this.category,
    required this.boothCode,
    required this.boothZone,
    required this.initials,
    required this.bg,
    required this.description,
    required this.products,
    required this.website,
    required this.email,
    this.logoUrl,
    this.bannerUrl,
    this.brochureUrl,
  });
}

class SightseeingPlace {
  final String id;
  final String name;
  final String distance;
  final String duration;
  final String imageUrl;
  final String description;
  final List<String> highlights;

  const SightseeingPlace({
    required this.id,
    required this.name,
    required this.distance,
    required this.duration,
    required this.imageUrl,
    required this.description,
    required this.highlights,
  });
}

class ExploreProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  List<Exhibitor> _exhibitors = const [];

  final List<SightseeingPlace> _places = const [
    SightseeingPlace(
      id: '1',
      name: 'Grand City Museum',
      distance: '1.2 km',
      duration: '2-3 hours',
      imageUrl: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600',
      description: 'Explore world-class art collections, interactive historical exhibits, and scientific marvels in this architectural masterpiece. Perfect for delegates looking to experience culture.',
      highlights: [
        'Renaissance Masterpieces',
        'Interactive Science Lab',
        'Historical Artifacts Gallery',
      ],
    ),
    SightseeingPlace(
      id: '2',
      name: 'Skyline Observation Deck',
      distance: '2.4 km',
      duration: '1-2 hours',
      imageUrl: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=600',
      description: 'Enjoy breathtaking 360-degree panoramic views of the entire city skyline from the 88th floor. Ideal for photography enthusiasts and evening visits.',
      highlights: [
        'High-speed Glass Elevator',
        'Breathtaking Sunset Views',
        'Sky-high Coffee Lounge',
      ],
    ),
    SightseeingPlace(
      id: '3',
      name: 'Botanical Glasshouse Gardens',
      distance: '3.5 km',
      duration: '1.5-2 hours',
      imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=600',
      description: 'Stroll through massive, climate-controlled glass dome structures showcasing thousands of exotic plant species and orchids from across the globe.',
      highlights: [
        'Exotic Orchid House',
        'Indoor Mist Waterfall',
        'Japanese Zen Garden Walk',
      ],
    ),
  ];

  List<Exhibitor> get exhibitors => _exhibitors;
  List<SightseeingPlace> get places => _places;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clear() {
    _exhibitors = const [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  List<Exhibitor> get featuredExhibitors {
    final featured = _exhibitors.where((ex) => ex.category.toLowerCase() == 'featured').toList();
    if (featured.isEmpty && _exhibitors.isNotEmpty) {
      return _exhibitors.take(4).toList();
    }
    return featured;
  }

  Future<bool> fetchSponsors(String summitId, String accessToken) async {
    if (summitId.isEmpty || accessToken.isEmpty) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchSponsors(
        summitId: summitId,
        accessToken: accessToken,
      );

      _isLoading = false;
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final List<dynamic> list = data['data'] ?? [];
          final List<Exhibitor> fetchedList = [];
          
          for (var item in list) {
            final String sponsorId = item['sponsor_id']?.toString() ?? '';
            final String companyName = item['company_name']?.toString() ?? '';
            final String category = item['sponsor_category']?.toString() ?? 'Standard';
            final String email = item['email']?.toString() ?? '';
            final String website = item['website']?.toString() ?? '';
            final String description = item['company_description']?.toString() ?? '';
            
            String? logoUrl;
            String? bannerUrl;
            String? brochureUrl;
            
            final media = item['media'];
            if (media != null) {
              final logos = media['logo'] as List<dynamic>?;
              if (logos != null && logos.isNotEmpty) {
                logoUrl = logos.first['media_url']?.toString();
              }
              final banners = media['banner'] as List<dynamic>?;
              if (banners != null && banners.isNotEmpty) {
                bannerUrl = banners.first['media_url']?.toString();
              }
              final brochures = media['brochure'] as List<dynamic>?;
              if (brochures != null && brochures.isNotEmpty) {
                brochureUrl = brochures.first['media_url']?.toString();
              }
            }

            final String initials = _getInitials(companyName);
            final Color bg = _getCategoryColor(category);

            fetchedList.add(
              Exhibitor(
                id: sponsorId,
                name: companyName,
                category: category,
                boothCode: 'Booth $sponsorId',
                boothZone: category.toLowerCase() == 'featured' ? 'Featured Zone' : 'Exhibition Hall',
                initials: initials,
                bg: bg,
                description: description.isEmpty ? 'Exhibitor & Sponsor' : description,
                products: const [
                  'Healthcare Infrastructure',
                  'Clinical Operations Management',
                  'Vibrant Medical Technologies',
                ],
                website: website.isEmpty ? 'heterohcl.com' : website,
                email: email.isEmpty ? 'sponsors@heterohcl.com' : email,
                logoUrl: logoUrl,
                bannerUrl: bannerUrl,
                brochureUrl: brochureUrl,
              ),
            );
          }
          
          _exhibitors = fetchedList;
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Failed to fetch sponsors';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch sponsors failed', e, stack);
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'EX';
    final parts = name.trim().split(RegExp(r'\s+'));
    if   (parts.length > 1) {
      return (parts[0].isNotEmpty && parts[1].isNotEmpty)
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'EX';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'featured':
        return const Color(0xFF1E1B4B);
      case 'premium':
        return const Color(0xFF9333EA);
      case 'standard':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  List<Map<String, dynamic>> _invitedSpeakers = [];
  bool _isLoadingSpeakers = false;
  String? _speakersError;

  List<Map<String, dynamic>> get invitedSpeakers => _invitedSpeakers;
  bool get isLoadingSpeakers => _isLoadingSpeakers;
  String? get speakersError => _speakersError;

  Future<bool> fetchInvitedSpeakers(String accessToken, {bool showLoading = true}) async {
    if (accessToken.isEmpty) return false;
    if (showLoading) {
      _isLoadingSpeakers = true;
      _speakersError = null;
      notifyListeners();
    }

    try {
      final response = await ApiService.fetchInvitedSpeakers(accessToken: accessToken);
      if (showLoading) {
        _isLoadingSpeakers = false;
      }
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final speakersList = data['data']['speakers'] as List<dynamic>? ?? [];
          _invitedSpeakers = List<Map<String, dynamic>>.from(speakersList);
          notifyListeners();
          return true;
        } else {
          _speakersError = data['message'] ?? 'Failed to load invited speakers';
        }
      } else {
        _speakersError = 'Server error: ${response.statusCode}';
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch invited speakers failed', e, stack);
      if (showLoading) {
        _isLoadingSpeakers = false;
      }
      _speakersError = e.toString();
      notifyListeners();
      return false;
    }
  }
}
