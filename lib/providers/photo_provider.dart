import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<bool> uploadPhoto() async {
    if (!hasPhoto) return false;

    _isUploading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 2000));

    _isUploading = false;
    _uploadSuccess = true;
    notifyListeners();

    return true;
  }
}
