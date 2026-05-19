import 'package:flutter/material.dart';

class SessionGallery {
  final String title;
  final String date;
  final String photoCount;
  final String imageUrl;
  final List<String> photos;

  const SessionGallery({
    required this.title,
    required this.date,
    required this.photoCount,
    required this.imageUrl,
    required this.photos,
  });
}

class PersonGallery {
  final String name;
  final String photoCount;
  final String imageUrl;
  final List<String> photos;

  const PersonGallery({
    required this.name,
    required this.photoCount,
    required this.imageUrl,
    required this.photos,
  });
}

class GalleryProvider with ChangeNotifier {
  final List<SessionGallery> _sessions = const [
    SessionGallery(
      title: 'Digital Pathology',
      date: '10 Mar, 2026',
      photoCount: '40 Photos',
      imageUrl: 'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=600',
      photos: [
        'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=600',
        'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=600',
        'https://images.unsplash.com/photo-1431540015161-0bf868a2d407?w=600',
        'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600',
        'https://images.unsplash.com/photo-1507537297725-24a1c029d3ca?w=600',
        'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600',
      ],
    ),
    SessionGallery(
      title: 'AI in Clinical Diagnostics',
      date: '10 Mar, 2026',
      photoCount: '40 Photos',
      imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600',
      photos: [
        'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600',
        'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=600',
        'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600',
        'https://images.unsplash.com/photo-1431540015161-0bf868a2d407?w=600',
        'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=600',
        'https://images.unsplash.com/photo-1507537297725-24a1c029d3ca?w=600',
      ],
    ),
    SessionGallery(
      title: 'Digital Pathology Workflows',
      date: '10 Mar, 2026',
      photoCount: '40 Photos',
      imageUrl: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600',
      photos: [
        'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600',
        'https://images.unsplash.com/photo-1431540015161-0bf868a2d407?w=600',
        'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600',
        'https://images.unsplash.com/photo-1507537297725-24a1c029d3ca?w=600',
        'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=600',
        'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=600',
      ],
    ),
  ];

  final List<PersonGallery> _people = const [
    PersonGallery(
      name: 'Dr. Emily Carter',
      photoCount: '19 Photos',
      imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400',
      photos: [
        'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=600',
        'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600',
        'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=600',
      ],
    ),
    PersonGallery(
      name: 'Dr. Michael',
      photoCount: '19 Photos',
      imageUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400',
      photos: [
        'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=600',
        'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=600',
        'https://images.unsplash.com/photo-1431540015161-0bf868a2d407?w=600',
      ],
    ),
    PersonGallery(
      name: 'Dr. Sophia Patel',
      photoCount: '19 Photos',
      imageUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400',
      photos: [
        'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=600',
        'https://images.unsplash.com/photo-1507537297725-24a1c029d3ca?w=600',
      ],
    ),
    PersonGallery(
      name: 'Dr. James',
      photoCount: '19 Photos',
      imageUrl: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=400',
      photos: [
        'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=600',
        'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600',
      ],
    ),
    PersonGallery(
      name: 'Dr. Olivia Martinez',
      photoCount: '19 Photos',
      imageUrl: 'https://images.unsplash.com/photo-1527613426441-4da17471b66d?w=400',
      photos: [
        'https://images.unsplash.com/photo-1527613426441-4da17471b66d?w=600',
        'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600',
      ],
    ),
    PersonGallery(
      name: 'Dr. Benjamin Lee',
      photoCount: '19 Photos',
      imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400',
      photos: [
        'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=600',
        'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=600',
      ],
    ),
    PersonGallery(
      name: 'Dr. Ava Robinson',
      photoCount: '19 Photos',
      imageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
      photos: [
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=600',
      ],
    ),
    PersonGallery(
      name: 'Dr. William Kim',
      photoCount: '19 Photos',
      imageUrl: 'https://images.unsplash.com/photo-1550831107-1553da8c8464?w=400',
      photos: [
        'https://images.unsplash.com/photo-1550831107-1553da8c8464?w=600',
      ],
    ),
    PersonGallery(
      name: 'Dr. Mia Hernandez',
      photoCount: '19 Photos',
      imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      photos: [
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600',
      ],
    ),
    PersonGallery(
      name: 'Dr. Alexander',
      photoCount: '19 Photos',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      photos: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600',
      ],
    ),
    PersonGallery(
      name: 'Dr. Isabella',
      photoCount: '19 Photos',
      imageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      photos: [
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=600',
      ],
    ),
    PersonGallery(
      name: 'Dr. Daniel Brown',
      photoCount: '19 Photos',
      imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      photos: [
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600',
      ],
    ),
  ];

  List<SessionGallery> get sessions => _sessions;
  List<PersonGallery> get people => _people;
}
