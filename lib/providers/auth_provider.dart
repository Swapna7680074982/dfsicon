import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dfsicon/domain/api_service.dart';
import 'package:dfsicon/utils/custom_logger.dart';

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

  // Default meta fields for request bodies
  static const Map<String, String> _defaultMeta = {
    "device_id": "ANDROID_123",
    "device_name": "Samsung S24",
    "device_type": "Android",
    "app_version": "1.0.0",
    "latitude": "",
    "longitude": "",
    "fcmToken": ""
  };

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

  String get email => _profileData['email'] ?? (isSpeaker ? 'sarah.ahmed@example.com' : 'alex.kumar@hotmail.com');
  String get mobile => _profileData['mobile'] ?? _phoneNumber;
  String get specialization => _profileData['specialization'] ?? (isSpeaker ? 'Senior Pathologist' : 'Sr. Surgeon');
  String get qualification => _profileData['qualification'] ?? (isSpeaker ? 'MD' : 'MS');
  String get experienceYears => _profileData['experience_years'] ?? '10';
  String get hospitalClinicName => _profileData['hospital_clinic_name'] ?? (isSpeaker ? 'National Pathology Institute' : 'Medcare Hospitals');
  String get medicalRegistrationNumber => _profileData['medical_registration_number'] ?? '123456';
  String get designation => _profileData['designation'] ?? (isSpeaker ? 'Chief Speaker' : 'Sr. Consultant');
  String get profileImage => _profileData['profile_image'] ?? 'NA';

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
  Future<bool> sendOtp() async {
    if (!isPhoneValid) return false;
    
    _isSendingOtp = true;
    notifyListeners();
    
    try {
      final response = await ApiService.sendOtp(
        phoneNumber: _phoneNumber,
        meta: _defaultMeta,
      );

      _isSendingOtp = false;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _otpSent = true;
          _resendSeconds = 30;
          notifyListeners();
          _startTimer();
          return true;
        }
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Send OTP failed', e, stack);
      _isSendingOtp = false;
      notifyListeners();
      return false;
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
  Future<bool> resendOtp() async {
    if (_resendSeconds > 0) return false;
    
    _otpCode = '';
    _resendSeconds = 30;
    notifyListeners();
    _startTimer();

    return await sendOtp();
  }

  // API Call: Verify OTP
  Future<bool> verifyOtp() async {
    if (!isOtpComplete) return false;

    _isVerifying = true;
    notifyListeners();

    try {
      final response = await ApiService.verifyOtp(
        phoneNumber: _phoneNumber,
        otpCode: _otpCode,
        meta: _defaultMeta,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _accessToken = data['access_token'] ?? '';
          _refreshToken = data['refresh_token'] ?? '';
          _profileData = data['use_profile'] ?? {};
          
          await _saveSession();

          _isVerifying = false;
          notifyListeners();
          return true;
        }
      }
      
      _isVerifying = false;
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Verify OTP failed', e, stack);
      _isVerifying = false;
      notifyListeners();
      return false;
    }
  }

  // API Call: Refresh Token
  Future<bool> refreshSessionToken() async {
    if (_refreshToken.isEmpty) return false;
    try {
      final response = await ApiService.refreshSessionToken(
        refreshToken: _refreshToken,
        meta: _defaultMeta,
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
        await ApiService.logout(
          refreshToken: savedRefreshToken,
          meta: _defaultMeta,
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

  Future<void> updateProfileLocal({
    required String name,
    required String email,
    required String mobile,
    required String hospitalClinicName,
    required String specialization,
    required String designation,
  }) async {
    _profileData['full_name'] = name;
    _profileData['email'] = email;
    _profileData['mobile'] = mobile;
    _profileData['hospital_clinic_name'] = hospitalClinicName;
    _profileData['specialization'] = specialization;
    _profileData['designation'] = designation;
    await _saveSession();
    notifyListeners();
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
