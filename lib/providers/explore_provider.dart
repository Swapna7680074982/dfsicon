import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dfsicon/constants/api_urls.dart';
import 'package:dfsicon/utils/custom_logger.dart';

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

  List<Exhibitor> _exhibitors = const [
    Exhibitor(
      id: 'mc',
      name: 'MedCore Health',
      category: 'Health IT & EMR',
      boothCode: 'Booth A-12',
      boothZone: 'Exhibition Hall',
      initials: 'MC',
      bg: Color(0xFF1E1B4B),
      description: 'A leading provider of enterprise electronic medical record systems and AI-assisted clinical decision support. Deployed across 800+ hospitals and health networks, MedCore powers better care through smarter data.',
      products: [
        'Electronic Medical Records',
        'Clinical Decision Support',
        'AI Diagnostics Suite',
        'Patient Engagement Portal',
      ],
      website: 'medcorehealth.com',
      email: 'exhibits@medcorehealth.com',
    ),
    Exhibitor(
      id: 'hb',
      name: 'HealthBridge',
      category: 'Interoperability',
      boothCode: 'Booth B-05',
      boothZone: 'Hall B',
      initials: 'HB',
      bg: Color(0xFF9333EA),
      description: 'HealthBridge offers seamless medical record synchronization and data integration suites for hospital management systems, establishing secure inter-hospital telemetry corridors.',
      products: [
        'Sync Core Interoperability API',
        'Secure Telemetry Gateways',
        'HL7 Real-time Brokerage Services',
      ],
      website: 'healthbridge.io',
      email: 'contact@healthbridge.io',
    ),
    Exhibitor(
      id: 'pt',
      name: 'PharmaTech Labs',
      category: 'Population Health',
      boothCode: 'Booth D-03',
      boothZone: 'Room D',
      initials: 'PT',
      bg: Color(0xFF10B981),
      description: 'Pioneers in population-level pharmaceutical modeling and interactive treatment telemetry. Accelerating drug discovery pathways through advanced decentralized computational clinical trials.',
      products: [
        'Population Health Telemetry Suite',
        'Decentralized Trial Orchestrators',
        'Interactive Drug Modeling Tools',
      ],
      website: 'pharmatechlabs.com',
      email: 'trials@pharmatechlabs.com',
    ),
    Exhibitor(
      id: 'cf',
      name: 'CareFirst Network',
      category: 'Primary Care',
      boothCode: 'Booth C-11',
      boothZone: 'Room C',
      initials: 'CF',
      bg: Color(0xFFF97316),
      description: 'Empowering primary care practices with smart predictive panel analytics. Integrated clinic scheduling hubs, automated treatment checklists, and virtual-first primary care portals.',
      products: [
        'Practice Panel Analytics Hub',
        'Smart Clinic Scheduling Engine',
        'Virtual-First Care Portals',
      ],
      website: 'carefirst.network',
      email: 'support@carefirst.network',
    ),
    Exhibitor(
      id: 'bg',
      name: 'BioGen Solutions',
      category: 'Biotechnology',
      boothCode: 'Booth E-08',
      boothZone: 'Room E',
      initials: 'BG',
      bg: Color(0xFFEC4899),
      description: 'BioGen Solutions designs cutting-edge genome processing arrays and clinical gene expression analytics tools for localized cellular therapeutic developments.',
      products: [
        'Genome Array Processors',
        'Cellular Analytics Framework',
      ],
      website: 'biogensolutions.com',
      email: 'exhibits@biogensolutions.com',
    ),
    Exhibitor(
      id: 'nd',
      name: 'Nova Diagnostics',
      category: 'Diagnostics',
      boothCode: 'Booth F-02',
      boothZone: 'Room F',
      initials: 'ND',
      bg: Color(0xFF3B82F6),
      description: 'Nova Diagnostics manufactures portable rapid screening laboratories, blood biomarker detectors, and real-time medical imaging network nodes.',
      products: [
        'Rapid Biomarker Labs',
        'Imaging Telemetry Nodes',
      ],
      website: 'novadiagnostics.com',
      email: 'sales@novadiagnostics.com',
    ),
  ];

  final List<SightseeingPlace> _places = const [
    SightseeingPlace(
      id: 'museum',
      name: 'Grand City Museum',
      distance: '1.2 km away',
      duration: '2-3 hours',
      imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=600',
      description: "One of the city's most iconic cultural institutions, housing over 80,000 artifacts spanning 5,000 years of history. World-class exhibits, interactive galleries, and a stunning central atrium.",
      highlights: [
        'Ancient Civilizations Wing',
        'Modern Art Gallery',
        'IMAX Theater',
        'Rooftop Garden',
      ],
    ),
    SightseeingPlace(
      id: 'deck',
      name: 'Skyline Observation Deck',
      distance: '2.4 km away',
      duration: '1 hour',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600',
      description: 'Witness breathtaking 360-degree panorama vistas of the entire metropolis and coastal bays. Equipped with interactive telescopes, a premium glass floor pathway, and sky cafe dining.',
      highlights: [
        'Glass Skywalk Pathway',
        'High-Resolution Telescopes',
        'Sky Lounge Cafe',
        'Sunset Photo Pavilion',
      ],
    ),
    SightseeingPlace(
      id: 'walk',
      name: 'Innovation District Walk',
      distance: '0.8 km away',
      duration: '1.5 hours',
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600',
      description: 'Take a self-guided outdoor walking audio tour through the beating heart of local science and architecture. Experience futuristic public installations and vibrant local design showrooms.',
      highlights: [
        'Futuristic Architecture Hubs',
        'Vibrant Design Showrooms',
        'Augmented Reality Street Art',
        'Locally Roasted Coffee Hubs',
      ],
    ),
  ];

  List<Exhibitor> get exhibitors => _exhibitors;
  List<SightseeingPlace> get places => _places;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Exhibitor> get featuredExhibitors {
    final featured = _exhibitors.where((ex) => ex.category.toLowerCase() == 'featured').toList();
    if (featured.isEmpty && _exhibitors.isNotEmpty) {
      return _exhibitors.take(4).toList();
    }
    return featured;
  }

  Future<bool> fetchSponsors(String accessToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse(ApiUrls.getSponsors);
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };
      
      final body = json.encode({
        "summit_id": "4"
      });

      CustomLogger.logRequest('POST', url.toString(), headers: headers, body: body);

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);

      _isLoading = false;
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
          
          if (fetchedList.isNotEmpty) {
            _exhibitors = fetchedList;
          }
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
    if (parts.length > 1) {
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
}
