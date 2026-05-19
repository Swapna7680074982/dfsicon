import 'dart:async';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String _phoneNumber = '';
  bool _otpSent = false;
  String _otpCode = '';
  bool _isVerifying = false;
  
  int _resendSeconds = 0;
  Timer? _resendTimer;

  String _userRole = 'delegate';
  String _userName = 'Alex Kumar';

  String get phoneNumber => _phoneNumber;
  bool get otpSent => _otpSent;
  String get otpCode => _otpCode;
  bool get isVerifying => _isVerifying;
  int get resendSeconds => _resendSeconds;
  
  String get userRole => _userRole;
  String get userName => _userName;
  bool get isSpeaker => _userRole == 'speaker';

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

  Future<void> sendOtp() async {
    if (!isPhoneValid) return;
    
    _otpSent = true;
    _resendSeconds = 30;
    notifyListeners();

    _startTimer();
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

  Future<void> resendOtp() async {
    if (_resendSeconds > 0) return;
    
    _otpCode = '';
    _resendSeconds = 30;
    notifyListeners();
    
    _startTimer();
  }

  Future<bool> verifyOtp() async {
    if (!isOtpComplete) return false;

    _isVerifying = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    if (_phoneNumber == '8765432109') {
      _userRole = 'speaker';
      _userName = 'Sarah Ahmed';
    } else {
      _userRole = 'delegate';
      _userName = 'Alex Kumar';
    }

    _isVerifying = false;
    notifyListeners();
    
    return true;
  }

  void logout() {
    _phoneNumber = '';
    _otpSent = false;
    _otpCode = '';
    _userRole = 'delegate';
    _userName = 'Alex Kumar';
    notifyListeners();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}
