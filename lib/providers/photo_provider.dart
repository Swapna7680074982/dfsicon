import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dfsicon/main.dart';
import 'package:dfsicon/constants/api_urls.dart';
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
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void clearImage() {
    _imagePath = null;
    _uploadSuccess = false;
    notifyListeners();
  }

  Future<String?> uploadPhoto(String accessToken) async {
    if (accessToken.isEmpty) return null;
    if (!hasPhoto) return null;

    _isUploading = true;
    notifyListeners();

    try {
      final url = Uri.parse(ApiUrls.uploadProfilePicture);
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $accessToken';
      final fileExtension = _imagePath!.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg';
      if (fileExtension == 'png') {
        mimeType = 'image/png';
      } else if (fileExtension == 'webp') {
        mimeType = 'image/webp';
      } else if (fileExtension == 'gif') {
        mimeType = 'image/gif';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_picture',
          _imagePath!,
          contentType: MediaType.parse(mimeType),
        ),
      );

      CustomLogger.logRequest('POST (Multipart)', url.toString(), headers: request.headers, body: 'File path: $_imagePath');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);

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
        }
      }
      notifyListeners();
      return null;
    } catch (e, stack) {
      CustomLogger.logError('Upload profile photo failed', e, stack);
      _isUploading = false;
      notifyListeners();
      return null;
    }
  }
}
