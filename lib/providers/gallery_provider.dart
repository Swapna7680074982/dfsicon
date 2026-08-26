import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dfsicon/constants/api_urls.dart';
import 'package:dfsicon/domain/api_service.dart';
import 'package:dfsicon/utils/custom_logger.dart';

class GalleryFace {
  final int userId;
  final String fullName;
  final String roleCode;
  final String designation;
  final String organisationName;
  final String photoUrl;
  final bool isMe;

  const GalleryFace({
    required this.userId,
    required this.fullName,
    required this.roleCode,
    required this.designation,
    required this.organisationName,
    required this.photoUrl,
    required this.isMe,
  });

  factory GalleryFace.fromJson(Map<String, dynamic> json) {
    String photo = json['photo_url']?.toString() ?? '';
    if (photo.startsWith('./')) {
      photo = photo.replaceFirst('./', '');
    }
    if (photo.isNotEmpty && !photo.startsWith('http')) {
      photo = '${ApiUrls.domain}/$photo';
    }
    return GalleryFace(
      userId: json['user_id'] is int
          ? json['user_id']
          : (int.tryParse(json['user_id']?.toString() ?? '0') ?? 0),
      fullName: json['full_name']?.toString() ?? '',
      roleCode: json['role_code']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      organisationName: json['organisation_name']?.toString() ?? '',
      photoUrl: photo,
      isMe: json['is_me'] == true || json['is_me'] == 'true' || json['is_me'] == 1,
    );
  }
}

class GalleryDay {
  final int galleryDayId;
  final int dayNumber;
  final String dayTitle;
  final String galleryDate;
  final String description;
  final int totalImages;
  final String coverUrl;

  const GalleryDay({
    required this.galleryDayId,
    required this.dayNumber,
    required this.dayTitle,
    required this.galleryDate,
    required this.description,
    required this.totalImages,
    required this.coverUrl,
  });

  factory GalleryDay.fromJson(Map<String, dynamic> json) {
    String cover = json['cover_url']?.toString() ?? '';
    if (cover.startsWith('./')) {
      cover = cover.replaceFirst('./', '');
    }
    if (cover.isNotEmpty && !cover.startsWith('http')) {
      cover = '${ApiUrls.domain}/$cover';
    }
    return GalleryDay(
      galleryDayId: json['gallery_day_id'] is int
          ? json['gallery_day_id']
          : (int.tryParse(json['gallery_day_id']?.toString() ?? '0') ?? 0),
      dayNumber: json['day_number'] is int
          ? json['day_number']
          : (int.tryParse(json['day_number']?.toString() ?? '0') ?? 0),
      dayTitle: json['day_title']?.toString() ?? '',
      galleryDate: json['gallery_date']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      totalImages: json['total_images'] is int
          ? json['total_images']
          : (int.tryParse(json['total_images']?.toString() ?? '0') ?? 0),
      coverUrl: cover,
    );
  }
}

class GalleryImage {
  final int? galleryImageId;
  final String thumbnailUrl;
  final String imageUrl;
  final String? caption;
  final String? altText;
  final int? width;
  final int? height;
  final String? uploadedAt;
  final int? galleryDayId;
  final int? dayNumber;
  final String? dayTitle;
  final List<String> matchedNames;
  final bool isAllMatch;
  final String? source;

  const GalleryImage({
    this.galleryImageId,
    required this.thumbnailUrl,
    required this.imageUrl,
    this.caption,
    this.altText,
    this.width,
    this.height,
    this.uploadedAt,
    this.galleryDayId,
    this.dayNumber,
    this.dayTitle,
    this.matchedNames = const [],
    this.isAllMatch = true,
    this.source,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    String thumb = json['thumbnail_url']?.toString() ?? json['image_url']?.toString() ?? '';
    String mainImg = json['image_url']?.toString() ?? json['thumbnail_url']?.toString() ?? '';

    if (thumb.startsWith('./')) thumb = thumb.replaceFirst('./', '');
    if (mainImg.startsWith('./')) mainImg = mainImg.replaceFirst('./', '');
    if (thumb.isNotEmpty && !thumb.startsWith('http')) thumb = '${ApiUrls.domain}/$thumb';
    if (mainImg.isNotEmpty && !mainImg.startsWith('http')) mainImg = '${ApiUrls.domain}/$mainImg';

    List<String> matched = [];
    if (json['matched_names'] != null && json['matched_names'] is List) {
      matched = (json['matched_names'] as List).map((e) => e.toString()).toList();
    }

    return GalleryImage(
      galleryImageId: json['gallery_image_id'] != null
          ? (json['gallery_image_id'] is int
              ? json['gallery_image_id']
              : int.tryParse(json['gallery_image_id'].toString()))
          : null,
      thumbnailUrl: thumb,
      imageUrl: mainImg,
      caption: json['caption']?.toString(),
      altText: json['alt_text']?.toString(),
      width: json['width'] != null
          ? (json['width'] is int ? json['width'] : int.tryParse(json['width'].toString()))
          : null,
      height: json['height'] != null
          ? (json['height'] is int ? json['height'] : int.tryParse(json['height'].toString()))
          : null,
      uploadedAt: json['uploaded_at']?.toString(),
      galleryDayId: json['gallery_day_id'] != null
          ? (json['gallery_day_id'] is int
              ? json['gallery_day_id']
              : int.tryParse(json['gallery_day_id'].toString()))
          : null,
      dayNumber: json['day_number'] != null
          ? (json['day_number'] is int
              ? json['day_number']
              : int.tryParse(json['day_number'].toString()))
          : null,
      dayTitle: json['day_title']?.toString(),
      matchedNames: matched,
      isAllMatch: json['is_all_match'] == true ||
          json['is_all_match'] == 'true' ||
          json['is_all_match'] == 1,
      source: json['source']?.toString(),
    );
  }
}

// Backward-compatibility adapter classes for existing caller screens
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
  List<GalleryDay> _days = [];
  List<GalleryFace> _faces = [];
  bool _isLoadingDays = false;
  bool _isLoadingFaces = false;
  String? _daysError;
  String? _facesError;

  List<GalleryDay> get days => _days;
  List<GalleryFace> get faces => _faces;
  bool get isLoadingDays => _isLoadingDays;
  bool get isLoadingFaces => _isLoadingFaces;
  String? get daysError => _daysError;
  String? get facesError => _facesError;

  // Backward compatibility getters
  List<SessionGallery> get sessions => _days.map((d) => SessionGallery(
        title: d.dayTitle,
        date: d.galleryDate,
        photoCount: '${d.totalImages} Photos',
        imageUrl: d.coverUrl,
        photos: d.coverUrl.isNotEmpty ? [d.coverUrl] : [],
      )).toList();

  List<PersonGallery> get people => _faces.map((f) => PersonGallery(
        name: f.fullName,
        photoCount: f.designation.isNotEmpty
            ? f.designation
            : (f.roleCode == 'SK' ? 'Speaker' : 'Delegate'),
        imageUrl: f.photoUrl,
        photos: f.photoUrl.isNotEmpty ? [f.photoUrl] : [],
      )).toList();

  // 1. Fetch Gallery Days API
  Future<bool> fetchGalleryDays({
    required String accessToken,
    dynamic summitId = 1,
    bool forceRefresh = false,
  }) async {
    if (accessToken.isEmpty) return false;
    if (_days.isNotEmpty && !forceRefresh && !_isLoadingDays) return true;

    _isLoadingDays = true;
    _daysError = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchGalleryDays(
        accessToken: accessToken,
        summitId: summitId,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List list = data['data'];
          _days = list.map((item) => GalleryDay.fromJson(item)).toList();
          _isLoadingDays = false;
          notifyListeners();
          return true;
        }
      }
      _daysError = 'Failed to fetch gallery days';
    } catch (e) {
      CustomLogger.logError('Error fetching gallery days', e);
      _daysError = e.toString();
    }

    _isLoadingDays = false;
    notifyListeners();
    return false;
  }

  // 2. Fetch Gallery Faces API
  Future<bool> fetchGalleryFaces({
    required String accessToken,
    String? search,
    int? page,
    bool forceRefresh = false,
  }) async {
    if (accessToken.isEmpty) return false;
    if (_faces.isNotEmpty && (search == null || search.isEmpty) && !forceRefresh && !_isLoadingFaces) return true;

    _isLoadingFaces = true;
    _facesError = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchGalleryFaces(
        accessToken: accessToken,
        search: search,
        page: page,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List list = data['data'];
          _faces = list.map((item) => GalleryFace.fromJson(item)).toList();
          _isLoadingFaces = false;
          notifyListeners();
          return true;
        }
      }
      _facesError = 'Failed to fetch faces';
    } catch (e) {
      CustomLogger.logError('Error fetching gallery faces', e);
      _facesError = e.toString();
    }

    _isLoadingFaces = false;
    notifyListeners();
    return false;
  }

  // 3. Fetch Gallery Images API
  Future<List<GalleryImage>> fetchGalleryImages({
    required String accessToken,
    dynamic galleryDayId,
    int? page,
  }) async {
    if (accessToken.isEmpty) return [];

    try {
      final response = await ApiService.fetchGalleryImages(
        accessToken: accessToken,
        galleryDayId: galleryDayId,
        page: page,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List list = data['data'];
          return list.map((item) => GalleryImage.fromJson(item)).toList();
        }
      }
    } catch (e) {
      CustomLogger.logError('Error fetching gallery images', e);
    }
    return [];
  }

  // 4. Fetch Gallery Match API
  Future<List<GalleryImage>> fetchGalleryMatch({
    required String accessToken,
    List<int>? userIds,
    bool requireAll = false,
  }) async {
    if (accessToken.isEmpty) return [];

    try {
      final response = await ApiService.fetchGalleryMatch(
        accessToken: accessToken,
        userIds: userIds,
        requireAll: requireAll,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List list = data['data'];
          return list.map((item) => GalleryImage.fromJson(item)).toList();
        }
      }
    } catch (e) {
      CustomLogger.logError('Error fetching gallery face match', e);
    }
    return [];
  }
}
