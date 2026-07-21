import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dfsicon/domain/api_service.dart';
import 'package:dfsicon/utils/custom_logger.dart';
import '../main.dart';
import '../constants/api_urls.dart';

class BoothItem {
  final String boothId;
  final String boothNumber;
  final String boothLabel;
  final String boothCapacity;
  final String status;
  final String? assignmentId;
  final String? sponsorId;
  final String? companyName;
  final String? sponsorType;
  final String? boothType;
  final String? sizeSqft;
  final String? price;
  final String? logo;
  final bool isOccupied;

  const BoothItem({
    required this.boothId,
    required this.boothNumber,
    required this.boothLabel,
    required this.boothCapacity,
    this.status = '1',
    this.assignmentId,
    this.sponsorId,
    this.companyName,
    this.sponsorType,
    this.boothType,
    this.sizeSqft,
    this.price,
    this.logo,
    this.isOccupied = false,
  });

  factory BoothItem.fromJson(Map<String, dynamic> json) {
    final num = json['booth_number']?.toString() ?? '';
    final label = json['booth_label']?.toString() ?? '';
    final rawLogo = json['logo']?.toString() ?? json['company_logo']?.toString() ?? json['sponsor_logo']?.toString();
    String? cleanLogo = rawLogo;
    if (cleanLogo != null) {
      cleanLogo = cleanLogo.trim();
      if (cleanLogo.isEmpty || cleanLogo == 'null' || cleanLogo == 'NA') {
        cleanLogo = null;
      } else if (!cleanLogo.startsWith('http')) {
        cleanLogo = '${ApiUrls.domain}/$cleanLogo'.replaceAll('//dfs-icon', '/dfs-icon');
      }
    }

    final isOcc = json['is_occupied'] == true ||
        json['is_occupied'] == 'true' ||
        json['is_occupied'] == 1 ||
        json['is_occupied'] == '1';

    return BoothItem(
      boothId: json['booth_id']?.toString() ?? '',
      boothNumber: num,
      boothLabel: label.isNotEmpty ? label : (num.isNotEmpty ? num : 'Booth'),
      boothCapacity: json['booth_capacity']?.toString() ?? json['size_sqft']?.toString() ?? '0',
      status: json['status']?.toString() ?? '1',
      assignmentId: json['assignment_id']?.toString(),
      sponsorId: json['sponsor_id']?.toString(),
      companyName: json['company_name']?.toString() ?? json['organisation']?.toString(),
      sponsorType: json['sponsor_type']?.toString() ?? json['sponsor_type_id']?.toString() ?? json['sponsor_title']?.toString(),
      boothType: json['booth_type']?.toString(),
      sizeSqft: json['size_sqft']?.toString(),
      price: json['price']?.toString(),
      logo: cleanLogo,
      isOccupied: isOcc,
    );
  }
}

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
  final List<BoothItem> booths;

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
    this.booths = const [],
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

            String boothCode = '';
            String boothZone = '';
            final List<BoothItem> parsedBooths = [];

            final boothsList = item['booths'] as List<dynamic>?;
            if (boothsList != null && boothsList.isNotEmpty) {
              final boothNumbers = <String>[];
              final boothLabels = <String>[];

              for (var b in boothsList) {
                if (b is Map<String, dynamic>) {
                  parsedBooths.add(BoothItem.fromJson(b));
                  final num = b['booth_number']?.toString().trim();
                  final label = b['booth_label']?.toString().trim();

                  if (num != null && num.isNotEmpty && !boothNumbers.contains(num)) {
                    boothNumbers.add(num);
                  }
                  if (label != null && label.isNotEmpty && !boothLabels.contains(label)) {
                    boothLabels.add(label);
                  }
                }
              }

              if (boothNumbers.isNotEmpty) {
                boothCode = boothNumbers.join(', ');
              }
              if (boothLabels.isNotEmpty) {
                boothZone = boothLabels.join(', ');
              }
            }

            if (boothCode.isEmpty) {
              boothCode = 'Booth $sponsorId';
            }
            if (boothZone.isEmpty) {
              boothZone = category.toLowerCase() == 'featured' ? 'Featured Zone' : 'Exhibition Hall';
            }

            final String initials = _getInitials(companyName);
            final Color bg = _getCategoryColor(category);

            final List<String> parsedProducts = [];
            final rawProducts = item['products'] ?? item['products_services'] ?? item['services'];
            if (rawProducts is List) {
              for (var p in rawProducts) {
                if (p != null && p.toString().trim().isNotEmpty) {
                  parsedProducts.add(p.toString().trim());
                }
              }
            } else if (rawProducts is String && rawProducts.trim().isNotEmpty) {
              parsedProducts.addAll(rawProducts.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
            }

            fetchedList.add(
              Exhibitor(
                id: sponsorId,
                name: companyName,
                category: category,
                boothCode: boothCode,
                boothZone: boothZone,
                initials: initials,
                bg: bg,
                description: description,
                products: parsedProducts,
                website: website,
                email: email,
                logoUrl: logoUrl,
                bannerUrl: bannerUrl,
                brochureUrl: brochureUrl,
                booths: parsedBooths,
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

  List<BoothItem> _summitBooths = [];
  bool _isLoadingBooths = false;
  String? _boothsError;

  List<BoothItem> get summitBooths => _summitBooths;
  bool get isLoadingBooths => _isLoadingBooths;
  String? get boothsError => _boothsError;

  Future<bool> fetchSummitBooths(String summitId, String accessToken) async {
    if (summitId.isEmpty || accessToken.isEmpty) return false;
    _isLoadingBooths = true;
    _boothsError = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchSummitBooths(
        summitId: summitId,
        accessToken: accessToken,
      );

      _isLoadingBooths = false;
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }
      if (response.statusCode == 200) {
        dynamic data;
        try {
          data = json.decode(response.body);
        } catch (_) {
          final trimmed = response.body.trim();
          final idx = trimmed.indexOf('{');
          if (idx != -1) {
            data = json.decode(trimmed.substring(idx));
          }
        }
        if (data != null && data['status'] == true) {
          final List list = (data['data'] is List)
              ? data['data']
              : (data['data'] is Map && data['data']['booths'] is List)
                  ? data['data']['booths']
                  : (data['booths'] is List)
                      ? data['booths']
                      : [];
          _summitBooths = list
              .whereType<Map<String, dynamic>>()
              .map((b) => BoothItem.fromJson(b))
              .toList();
          notifyListeners();
          return true;
        } else {
          _boothsError = data?['message'] ?? 'Failed to fetch summit booths';
        }
      } else {
        _boothsError = 'Server error: ${response.statusCode}';
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch summit booths failed', e, stack);
      _isLoadingBooths = false;
      _boothsError = e.toString();
      notifyListeners();
      return false;
    }
  }
}
