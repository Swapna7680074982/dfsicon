import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dfsicon/domain/api_service.dart';
import 'package:dfsicon/domain/utility_models.dart';
import 'package:dfsicon/utils/custom_logger.dart';
import 'package:dfsicon/main.dart';
import 'package:dfsicon/services/fcm_service.dart';

class AuthProvider with ChangeNotifier {
  MyQrData? _myQrData;
  bool _isFetchingQr = false;
  
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

  bool _isLoggingInPassword = false;

  // Getters
  String get phoneNumber => _phoneNumber;
  bool get otpSent => _otpSent;
  String get otpCode => _otpCode;
  bool get isVerifying => _isVerifying;
  bool get isSendingOtp => _isSendingOtp;
  bool get isLoggingInPassword => _isLoggingInPassword;
  int get resendSeconds => _resendSeconds;
  
  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;
  Map<String, dynamic> get profileData => _profileData;
  MyQrData? get myQrData => _myQrData;
  bool get isFetchingQr => _isFetchingQr;

  Future<MyQrData?> fetchMyQr({bool forceRefresh = false}) async {
    if (!forceRefresh && _myQrData != null) {
      return _myQrData;
    }
    if (_accessToken.isEmpty) return null;

    _isFetchingQr = true;
    notifyListeners();

    try {
      final response = await ApiService.fetchMyQr(accessToken: _accessToken);

      if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        _isFetchingQr = false;
        notifyListeners();
        return null;
      }

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          _myQrData = MyQrData.fromJson(body['data']);
        }
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch My QR failed', e, stack);
    } finally {
      _isFetchingQr = false;
      notifyListeners();
    }
    return _myQrData;
  }

  String get citizenType => (_profileData['citizen_type'] ?? '').toString();
  bool get isForeignUser {
    final type = citizenType.toUpperCase();
    if (type == 'FOREIGN') return true;
    if (type == 'INDIAN') return false;
    // Fallback: check if mobile number is non-Indian (length > 10 and doesn't start with 0)
    final mob = mobile.trim();
    if (mob.length > 10 && !mob.startsWith('0')) {
      return true;
    }
    return false;
  }

  // Dynamic profile fields with mock fallbacks
  String get userId => (_profileData['user_id'] ?? _profileData['id'] ?? '').toString();
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
  Future<String?> sendOtp({String citizenType = 'INDIAN'}) async {
    if (!isPhoneValid) return 'Invalid phone number';
    
    _isSendingOtp = true;
    notifyListeners();
    
    try {
      final meta = await _getMeta();
      final response = await ApiService.sendOtp(
        phoneNumber: _phoneNumber,
        citizenType: citizenType,
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
  Future<String?> resendOtp({String citizenType = 'INDIAN'}) async {
    if (_resendSeconds > 0) return 'Please wait for the timer';
    
    _otpCode = '';
    _resendSeconds = 30;
    notifyListeners();
    _startTimer();

    return await sendOtp(citizenType: citizenType);
  }

  // API Call: Verify OTP
  Future<String?> verifyOtp({String citizenType = 'INDIAN'}) async {
    if (!isOtpComplete) return 'Please enter the complete OTP';

    _isVerifying = true;
    notifyListeners();

    try {
      final meta = await _getMeta();
      final response = await ApiService.verifyOtp(
        phoneNumber: _phoneNumber,
        otpCode: _otpCode,
        citizenType: citizenType,
        meta: meta,
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        if (data['status'] == true) {
          _accessToken = data['access_token'] ?? '';
          _refreshToken = data['refresh_token'] ?? '';
          _profileData = Map<String, dynamic>.from(data['use_profile'] ?? data['user_profile'] ?? {});
          _profileData['citizen_type'] = citizenType;
          _myQrData = null;
          
          await _saveSession();
          registerDeviceToken();

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

  // API Call: Foreign Citizen Password Login
  Future<String?> loginPassword({
    required String mobile,
    required String password,
    String citizenType = 'FOREIGN',
  }) async {
    if (mobile.trim().isEmpty) return 'Mobile number is required';
    if (password.isEmpty) return 'Password is required';

    _isLoggingInPassword = true;
    notifyListeners();

    try {
      final meta = await _getMeta();
      final response = await ApiService.loginPassword(
        mobile: mobile.trim(),
        password: password,
        citizenType: citizenType,
        meta: meta,
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        if (data['status'] == true) {
          _accessToken = data['access_token'] ?? '';
          _refreshToken = data['refresh_token'] ?? '';
          _profileData = Map<String, dynamic>.from(data['use_profile'] ?? data['user_profile'] ?? {});
          _profileData['citizen_type'] = citizenType;
          _myQrData = null;

          await _saveSession();
          registerDeviceToken();

          _isLoggingInPassword = false;
          notifyListeners();
          return null;
        }
      }

      _isLoggingInPassword = false;
      notifyListeners();
      return data['message'] ?? 'Login failed';
    } catch (e, stack) {
      CustomLogger.logError('Password Login failed', e, stack);
      _isLoggingInPassword = false;
      notifyListeners();
      return e.toString();
    }
  }

  // API Call: Foreign Citizen Change Password
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (_accessToken.isEmpty) return 'Not authenticated';
    if (currentPassword.isEmpty) return 'Current password is required';
    if (newPassword.isEmpty) return 'New password is required';
    if (newPassword != confirmPassword) return 'New password and confirm password do not match';

    try {
      final response = await ApiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        accessToken: _accessToken,
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        if (data['status'] == true) {
          return null; // Success
        }
      } else if (response.statusCode == 401) {
        MyApp.redirectToLogin();
        return 'Session expired. Please login again.';
      }

      return data['message'] ?? 'Failed to change password';
    } catch (e, stack) {
      CustomLogger.logError('Change password failed', e, stack);
      return e.toString();
    }
  }

  // API Call: Delete Account
  Future<String?> deleteAccount({
    bool confirm = true,
  }) async {
    if (_accessToken.isEmpty) return 'Not authenticated';

    try {
      final response = await ApiService.deleteAccount(
        confirm: confirm,
        accessToken: _accessToken,
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201 || data['status'] == true) {
        // Account deleted successfully
        _phoneNumber = '';
        _otpSent = false;
        _otpCode = '';
        _accessToken = '';
        _refreshToken = '';
        _profileData = {};
        _userRole = 'DL';
        _userName = 'Alex Kumar';
        _myQrData = null;

        await _clearSession();
        notifyListeners();
        return null; // Success
      }

      return data['message'] ?? 'Failed to delete account';
    } catch (e, stack) {
      CustomLogger.logError('Delete account failed', e, stack);
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
    _myQrData = null;
    
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
    _myQrData = null;
    await FcmService.deleteFcmToken();
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
          final savedCitizenType = _profileData['citizen_type'];
          _profileData = Map<String, dynamic>.from(data['data']);
          if ((!_profileData.containsKey('citizen_type') || _profileData['citizen_type'] == null || _profileData['citizen_type'].toString().isEmpty) &&
              savedCitizenType != null &&
              savedCitizenType.toString().isNotEmpty) {
            _profileData['citizen_type'] = savedCitizenType;
          }
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

  Future<bool> registerDeviceToken({bool forceRecreate = true}) async {
    if (_accessToken.isEmpty) return false;
    try {
      final fcmToken = forceRecreate
          ? await FcmService.recreateFcmToken()
          : await FcmService.getFcmToken();
      if (fcmToken.isEmpty) return false;

      final response = await ApiService.registerFcmToken(
        fcmToken: fcmToken,
        accessToken: _accessToken,
        deviceType: Platform.isAndroid ? "android" : (Platform.isIOS ? "ios" : "android"),
        deviceId: "android_123",
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == true;
      }
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Register FCM Token failed', e, stack);
      return false;
    }
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
        registerDeviceToken();
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
