import 'package:flutter/material.dart';

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
  final List<Exhibitor> _exhibitors = const [
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

  List<Exhibitor> get featuredExhibitors => _exhibitors.take(4).toList();
}
