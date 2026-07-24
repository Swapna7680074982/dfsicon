import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dfsicon/domain/api_service.dart';
import 'package:dfsicon/utils/custom_logger.dart';
import 'package:dfsicon/main.dart';
import 'package:dfsicon/services/fcm_service.dart';

class AuthProvider with ChangeNotifier {
  String _phoneNumber = '';
  bool _otpSent = false;
  String _otpCode = '';
  bool _isVerifying = false;
  bool _isSendingOtp = false;
  
  int _resendSeconds = 0;
  Timer? _resendTimer;

  // Fallback defaults
  String _userRole = 'DL';
  String _userName = 'Alex Kumar';

  // API Tokens and Profile Data
  String _accessToken = '';
  String _refreshToken = '';
  Map<String, dynamic> _profileData = {};

  Future<Map<String, String>> _getMeta() async {
    final token = await FcmService.getFcmToken();
    return {
      "device_id": "ANDROID_123",
      "device_name": Platform.isAndroid ? "Android Device" : (Platform.isIOS ? "iOS Device" : "Device"),
      "device_type": Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
      "app_version": "1.0.0",
      "latitude": "",
      "longitude": "",
      "fcmToken": token
    };
  }

  // Getters
  String get phoneNumber => _phoneNumber;
  bool get otpSent => _otpSent;
  String get otpCode => _otpCode;
  bool get isVerifying => _isVerifying;
  bool get isSendingOtp => _isSendingOtp;
  int get resendSeconds => _resendSeconds;
  
  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;
  Map<String, dynamic> get profileData => _profileData;

  // Dynamic profile fields with mock fallbacks
  String get userRole => _profileData['role_code'] ?? _userRole;
  String get userName => _profileData['full_name'] ?? _userName;
  bool get isSpeaker => userRole.toUpperCase() == 'SK';

  String get email => _profileData['email'] ?? '';
  String get mobile => _profileData['mobile'] ?? _phoneNumber;
  String get specialization => _profileData['specialization'] ?? '';
  String get qualification => _profileData['qualification'] ?? '';
  String get experienceYears => _profileData['experience_years'] ?? '';
  String get hospitalClinicName => _profileData['organisation_name'] ?? _profileData['hospital_clinic_name'] ?? '';
  String get medicalRegistrationNumber => _profileData['medical_registration_number'] ?? '';
  String get designation => _profileData['designation'] ?? '';
  
  String get gender => _profileData['gender'] ?? '';
  String get state => _profileData['state'] ?? '';
  String get city => _profileData['city'] ?? '';
  String get countryId => _profileData['country_id']?.toString() ?? '';
  String get countryName => _profileData['country_name'] ?? '';
  String get postalCode => _profileData['postal_code'] ?? '';
  String get category => _profileData['category'] ?? '';

  bool get showMobile => _profileData['show_mobile'] == '1' || _profileData['show_mobile'] == 1;
  bool get showEmail => _profileData['show_email'] == '1' || _profileData['show_email'] == 1;
  bool get showOrganisation => _profileData['show_organisation'] == '1' || _profileData['show_organisation'] == 1;
  bool get showDesignation => _profileData['show_designation'] == '1' || _profileData['show_designation'] == 1;
  bool get showProfileImage => _profileData['show_profile_image'] == '1' || _profileData['show_profile_image'] == 1;

  String get profileImage {
    final img = (_profileData['profile_image'] ?? 'NA').toString().trim();
    if (img == 'NA' || img.isEmpty) return 'NA';
    if (img.startsWith('http')) {
      return img;
    }
    String cleanPath = img;
    if (cleanPath.startsWith('./')) {
      cleanPath = cleanPath.substring(2);
    } else if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return 'https://services.heterohcl.com/dfs-icon/$cleanPath';
  }

  bool get hasValidProfileImage {
    final img = profileImage.trim();
    if (img == 'NA' || img.isEmpty) return false;
    if (img == 'https://services.heterohcl.com/dfs-icon/' || 
        img == 'https://services.heterohcl.com/dfs-icon' ||
        img == 'https://services.heterohcl.com/dfs-icon/NA') {
      return false;
    }
    return true;
  }

  bool get isPhoneValid => _phoneNumber.length >= 10;
  bool get isOtpComplete => _otpCode.length == 6;

  void setPhoneNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    _phoneNumber = cleaned;
    notifyListeners();
  }

  void setOtpCode(String value) {
    _otpCode = value;
    notifyListeners();
  }

  // API Call: Send OTP
  Future<String?> sendOtp() async {
    if (!isPhoneValid) return 'Invalid phone number';
    
    _isSendingOtp = true;
    notifyListeners();
    
    try {
      final meta = await _getMeta();
      final response = await ApiService.sendOtp(
        phoneNumber: _phoneNumber,
        meta: meta,
      );

      _isSendingOtp = false;
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        if (data['status'] == true) {
          _otpSent = true;
          _resendSeconds = 30;
          notifyListeners();
          _startTimer();
          return null;
        }
      }
      notifyListeners();
      return data['message'] ?? 'Failed to send OTP';
    } catch (e, stack) {
      CustomLogger.logError('Send OTP failed', e, stack);
      _isSendingOtp = false;
      notifyListeners();
      return e.toString();
    }
  }

  void _startTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        _resendSeconds--;
        notifyListeners();
      } else {
        _resendTimer?.cancel();
      }
    });
  }

  // API Call: Resend OTP
  Future<String?> resendOtp() async {
    if (_resendSeconds > 0) return 'Please wait for the timer';
    
    _otpCode = '';
    _resendSeconds = 30;
    notifyListeners();
    _startTimer();

    return await sendOtp();
  }

  // API Call: Verify OTP
  Future<String?> verifyOtp() async {
    if (!isOtpComplete) return 'Please enter the complete OTP';

    _isVerifying = true;
    notifyListeners();

    try {
      final meta = await _getMeta();
      final response = await ApiService.verifyOtp(
        phoneNumber: _phoneNumber,
        otpCode: _otpCode,
        meta: meta,
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        if (data['status'] == true) {
          _accessToken = data['access_token'] ?? '';
          _refreshToken = data['refresh_token'] ?? '';
          _profileData = data['use_profile'] ?? {};
          
          await _saveSession();

          _isVerifying = false;
          notifyListeners();
          return null;
        }
      }
      
      _isVerifying = false;
      notifyListeners();
      return data['message'] ?? 'Verification failed';
    } catch (e, stack) {
      CustomLogger.logError('Verify OTP failed', e, stack);
      _isVerifying = false;
      notifyListeners();
      return e.toString();
    }
  }

  // API Call: Refresh Token
  Future<bool> refreshSessionToken() async {
    if (_refreshToken.isEmpty) return false;
    try {
      final meta = await _getMeta();
      final response = await ApiService.refreshSessionToken(
        refreshToken: _refreshToken,
        meta: meta,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _accessToken = data['access_token'] ?? '';
          _refreshToken = data['refresh_token'] ?? '';
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', _accessToken);
          await prefs.setString('refresh_token', _refreshToken);
          return true;
        }
      }
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Refresh Session Token failed', e, stack);
      return false;
    }
  }

  // API Call: Logout
  Future<bool> logout() async {
    final savedRefreshToken = _refreshToken;
    
    // Reset state locally immediately
    _phoneNumber = '';
    _otpSent = false;
    _otpCode = '';
    _accessToken = '';
    _refreshToken = '';
    _profileData = {};
    _userRole = 'DL';
    _userName = 'Alex Kumar';
    
    await _clearSession();
    notifyListeners();

    try {
      if (savedRefreshToken.isNotEmpty) {
        final meta = await _getMeta();
        await ApiService.logout(
          refreshToken: savedRefreshToken,
          meta: meta,
        );
      }
      return true;
    } catch (e, stack) {
      CustomLogger.logError('Logout failed', e, stack);
      return false;
    }
  }

  // Session Persistence
  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', _accessToken);
    await prefs.setString('refresh_token', _refreshToken);
    await prefs.setString('profile_data', json.encode(_profileData));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('profile_data');
  }

  Future<bool> fetchMyProfile() async {
    if (_accessToken.isEmpty) return false;
    try {
      final response = await ApiService.fetchMyProfile(accessToken: _accessToken);
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          _profileData = Map<String, dynamic>.from(data['data']);
          await _saveSession();
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch profile failed', e, stack);
      return false;
    }
  }

  Future<bool> updateProfileApi({
    required Map<String, String> fields,
    File? profileImage,
  }) async {
    if (_accessToken.isEmpty) return false;
    try {
      final response = await ApiService.updateProfile(
        fields: fields,
        profileImage: profileImage,
        accessToken: _accessToken,
      );
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          await fetchMyProfile();
          return true;
        }
      }
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Update profile failed', e, stack);
      return false;
    }
  }

  Future<bool> updatePrivacySettings({
    required String showMobile,
    required String showEmail,
    String? showOrganisation,
    String? showDesignation,
    String? showProfileImage,
  }) async {
    if (_accessToken.isEmpty) return false;
    try {
      final settings = {
        'show_mobile': showMobile,
        'show_email': showEmail,
      };
      if (showOrganisation != null) settings['show_organisation'] = showOrganisation;
      if (showDesignation != null) settings['show_designation'] = showDesignation;
      if (showProfileImage != null) settings['show_profile_image'] = showProfileImage;

      final response = await ApiService.updatePrivacySettings(
        settings: settings,
        accessToken: _accessToken,
      );
      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return false;
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _profileData['show_mobile'] = showMobile;
          _profileData['show_email'] = showEmail;
          if (showOrganisation != null) _profileData['show_organisation'] = showOrganisation;
          if (showDesignation != null) _profileData['show_designation'] = showDesignation;
          if (showProfileImage != null) _profileData['show_profile_image'] = showProfileImage;

          await _saveSession();
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Update privacy settings failed', e, stack);
      return false;
    }
  }

  Future<void> updateProfileImage(String profileImageUrl) async {
    _profileData['profile_image'] = profileImageUrl;
    await _saveSession();
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('refresh_token')) return false;

      final savedRefreshToken = prefs.getString('refresh_token') ?? '';
      if (savedRefreshToken.isEmpty) return false;

      _refreshToken = savedRefreshToken;
      _accessToken = prefs.getString('access_token') ?? '';
      
      final profileStr = prefs.getString('profile_data') ?? '{}';
      _profileData = json.decode(profileStr) as Map<String, dynamic>;
      final success = await refreshSessionToken();
      if (success) {
        notifyListeners();
        return true;
      } else {
        await _clearSession();
        return false;
      }
    } catch (e) {
      debugPrint('Auto-login error: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}
