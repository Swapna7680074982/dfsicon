import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dfsicon/domain/api_service.dart';
import 'package:dfsicon/utils/custom_logger.dart';
import '../main.dart';

class WorkshopParticipant {
  final String userId;
  final String fullName;
  final String mobile;
  final String email;
  final String designation;
  final String? profileImage;
  final String initials;
  final Color bg;

  WorkshopParticipant({
    required this.userId,
    required this.fullName,
    required this.mobile,
    required this.email,
    required this.designation,
    this.profileImage,
    required this.initials,
    required this.bg,
  });
}

class WorkshopItem {
  final String workshopId;
  final String workshopCode;
  final String workshopName;
  final String workshopType;
  final String description;
  final String venueName;
  final String address;
  final String state;
  final String city;
  final String postalCode;
  final String? workshopImage;
  final String? brochureFile;
  final String maxCapacity;
  final String registrationStart;
  final String registrationEnd;
  final String workshopStart;
  final String workshopEnd;
  final String fee;
  final String currency;
  final String certificateAvailable;
  final String status;
  final String assignmentId;
  final String? role;
  final String attendanceStatus;
  final String certificateGenerated;
  final String feedbackSubmitted;
  final String assignedOn;
  final int speakersCount;
  final int delegatesCount;

  WorkshopItem({
    required this.workshopId,
    required this.workshopCode,
    required this.workshopName,
    required this.workshopType,
    required this.description,
    required this.venueName,
    required this.address,
    required this.state,
    required this.city,
    required this.postalCode,
    this.workshopImage,
    this.brochureFile,
    required this.maxCapacity,
    required this.registrationStart,
    required this.registrationEnd,
    required this.workshopStart,
    required this.workshopEnd,
    required this.fee,
    required this.currency,
    required this.certificateAvailable,
    required this.status,
    required this.assignmentId,
    this.role,
    required this.attendanceStatus,
    required this.certificateGenerated,
    required this.feedbackSubmitted,
    required this.assignedOn,
    required this.speakersCount,
    required this.delegatesCount,
  });

  factory WorkshopItem.fromJson(Map<String, dynamic> json) {
    return WorkshopItem(
      workshopId: json['workshop_id']?.toString() ?? '',
      workshopCode: json['workshop_code']?.toString() ?? '',
      workshopName: json['workshop_name']?.toString() ?? '',
      workshopType: json['workshop_type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      venueName: json['venue_name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
      workshopImage: json['workshop_image']?.toString(),
      brochureFile: json['brochure_file']?.toString(),
      maxCapacity: json['max_capacity']?.toString() ?? '0',
      registrationStart: json['registration_start']?.toString() ?? '',
      registrationEnd: json['registration_end']?.toString() ?? '',
      workshopStart: json['workshop_start']?.toString() ?? '',
      workshopEnd: json['workshop_end']?.toString() ?? '',
      fee: json['fee']?.toString() ?? '0.00',
      currency: json['currency']?.toString() ?? 'INR',
      certificateAvailable: json['certificate_available']?.toString() ?? '0',
      status: json['status']?.toString() ?? '',
      assignmentId: json['assignment_id']?.toString() ?? '',
      role: json['role']?.toString(),
      attendanceStatus: json['attendance_status']?.toString() ?? 'Pending',
      certificateGenerated: json['certificate_generated']?.toString() ?? '0',
      feedbackSubmitted: json['feedback_submitted']?.toString() ?? '0',
      assignedOn: json['assigned_on']?.toString() ?? '',
      speakersCount: int.tryParse(json['speakers_count']?.toString() ?? '0') ?? 0,
      delegatesCount: int.tryParse(json['delegates_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class WorkshopsProvider with ChangeNotifier {
  List<WorkshopItem> _workshops = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _lastAccessToken;

  List<WorkshopParticipant> _workshopSpeakers = [];
  List<WorkshopParticipant> _workshopDelegates = [];
  bool _isLoadingParticipants = false;
  String? _participantsErrorMessage;

  List<WorkshopItem> get workshops => _workshops;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<WorkshopParticipant> get workshopSpeakers => _workshopSpeakers;
  List<WorkshopParticipant> get workshopDelegates => _workshopDelegates;
  bool get isLoadingParticipants => _isLoadingParticipants;
  String? get participantsErrorMessage => _participantsErrorMessage;

  void clear() {
    _workshops = [];
    _isLoading = false;
    _errorMessage = null;
    _lastAccessToken = null;
    _workshopSpeakers = [];
    _workshopDelegates = [];
    _isLoadingParticipants = false;
    _participantsErrorMessage = null;
    notifyListeners();
  }

  static String _getInitials(String name) {
    if (name.isEmpty) return 'PA';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  static Color _getColorForIndex(int index) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Purple
    ];
    return colors[index % colors.length];
  }

  Future<bool> fetchWorkshopParticipants(String workshopId, String accessToken) async {
    if (accessToken.isEmpty || workshopId.isEmpty) return false;
    _isLoadingParticipants = true;
    _participantsErrorMessage = null;
    _workshopSpeakers = [];
    _workshopDelegates = [];
    notifyListeners();

    try {
      final response = await ApiService.viewWorkshopParticipants(
        workshopId: workshopId,
        accessToken: accessToken,
      );
      _isLoadingParticipants = false;

      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final dynamic innerData = data['data'];
          
          final List speakersList = innerData['speakers'] ?? [];
          _workshopSpeakers = speakersList.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final String userId = item['user_id']?.toString() ?? idx.toString();
            final String fullName = item['full_name']?.toString() ?? 'Speaker';
            final String mobile = item['mobile']?.toString() ?? '';
            final String email = item['email']?.toString() ?? '';
            final String designation = item['designation']?.toString() ?? 'Speaker';
            String? profileImage = item['profile_image']?.toString();
            
            return WorkshopParticipant(
              userId: userId,
              fullName: fullName,
              mobile: mobile,
              email: email,
              designation: designation,
              profileImage: (profileImage != null && profileImage.isNotEmpty && profileImage != 'null') ? profileImage : null,
              initials: _getInitials(fullName),
              bg: _getColorForIndex(idx),
            );
          }).toList();

          final List delegatesList = innerData['delegates'] ?? [];
          _workshopDelegates = delegatesList.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final String userId = item['user_id']?.toString() ?? idx.toString();
            final String fullName = item['full_name']?.toString() ?? 'Delegate';
            final String mobile = item['mobile']?.toString() ?? '';
            final String email = item['email']?.toString() ?? '';
            final String designation = item['designation']?.toString() ?? 'Delegate';
            String? profileImage = item['profile_image']?.toString();
            
            return WorkshopParticipant(
              userId: userId,
              fullName: fullName,
              mobile: mobile,
              email: email,
              designation: designation,
              profileImage: (profileImage != null && profileImage.isNotEmpty && profileImage != 'null') ? profileImage : null,
              initials: _getInitials(fullName),
              bg: _getColorForIndex(idx),
            );
          }).toList();

          notifyListeners();
          return true;
        } else {
          _participantsErrorMessage = data['message'] ?? 'Failed to load workshop participants';
        }
      } else {
        _participantsErrorMessage = 'Server error: ${response.statusCode}';
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch workshop participants failed', e, stack);
      _isLoadingParticipants = false;
      _participantsErrorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchMyWorkshops(String accessToken, {bool forceRefresh = false}) async {
    if (accessToken.isEmpty) return false;
    if (accessToken != _lastAccessToken) {
      forceRefresh = true;
      _lastAccessToken = accessToken;
    }
    if (!forceRefresh && _workshops.isNotEmpty) return true;
    if (_isLoading) return false; // Prevent duplicate concurrent loading
    _isLoading = true;
    _errorMessage = null;
    _workshops = []; // Clear previous data to prevent leaking across user sessions
    notifyListeners();

    try {
      final response = await ApiService.fetchMyWorkshops(accessToken: accessToken);
      _isLoading = false;

      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final List list = data['data'] ?? [];
          _workshops = list.map((w) => WorkshopItem.fromJson(w)).toList();
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Failed to load workshops';
        }
      } else {
        try {
          final data = json.decode(response.body);
          _errorMessage = data['message'] ?? 'Server error: ${response.statusCode}';
        } catch (_) {
          _errorMessage = 'Server error: ${response.statusCode}';
        }
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch workshops failed', e, stack);
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
