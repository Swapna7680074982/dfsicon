import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dfsicon/main.dart';
import 'package:dfsicon/domain/api_service.dart';
import 'package:dfsicon/utils/custom_logger.dart';

class PhotoProvider extends ChangeNotifier {
  String? _imagePath;
  bool _isUploading = false;
  bool _uploadSuccess = false;
  final ImagePicker _picker = ImagePicker();

  String? get imagePath => _imagePath;
  bool get isUploading => _isUploading;
  bool get uploadSuccess => _uploadSuccess;
  bool get hasPhoto => _imagePath != null;

  String? _uploadError;
  String? get uploadError => _uploadError;

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _imagePath = pickedFile.path;
        _uploadSuccess = false;
        _uploadError = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void clearImage() {
    _imagePath = null;
    _uploadSuccess = false;
    _uploadError = null;
    notifyListeners();
  }

  Future<String?> uploadPhoto(String accessToken) async {
    if (accessToken.isEmpty) return null;
    if (!hasPhoto) return null;

    _isUploading = true;
    _uploadError = null;
    notifyListeners();

    try {
      final response = await ApiService.uploadPhoto(
        imagePath: _imagePath!,
        accessToken: accessToken,
      );

      _isUploading = false;
      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('profile_data');
        notifyListeners();
        MyApp.redirectToLogin();
        return null;
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _uploadSuccess = true;
          notifyListeners();
          return data['profile_picture'] as String?;
        } else {
          _uploadError = data['message'] ?? 'Upload failed';
        }
      } else {
        _uploadError = 'Server error: ${response.statusCode}';
      }
      notifyListeners();
      return null;
    } catch (e, stack) {
      CustomLogger.logError('Upload profile photo failed', e, stack);
      _isUploading = false;
      _uploadError = e.toString().contains('Failed host lookup')
          ? 'Network error: please check your internet connection'
          : 'Upload failed: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
}
