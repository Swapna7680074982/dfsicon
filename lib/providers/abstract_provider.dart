import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dfsicon/main.dart';
import 'package:dfsicon/constants/api_urls.dart';
import 'package:dfsicon/utils/custom_logger.dart';

class AbstractProvider with ChangeNotifier {
  List<Map<String, dynamic>> _myAbstracts = [];
  bool _isLoadingList = false;
  
  Map<String, dynamic>? _selectedAbstractDetails;
  bool _isLoadingDetails = false;

  bool _isSubmitting = false;
  bool _isResubmitting = false;

  List<Map<String, dynamic>> _summits = [];
  bool _isLoadingSummits = false;

  // Getters
  List<Map<String, dynamic>> get myAbstracts => _myAbstracts;
  bool get isLoadingList => _isLoadingList;
  
  Map<String, dynamic>? get selectedAbstractDetails => _selectedAbstractDetails;
  bool get isLoadingDetails => _isLoadingDetails;

  bool get isSubmitting => _isSubmitting;
  bool get isResubmitting => _isResubmitting;

  List<Map<String, dynamic>> get summits => _summits;
  bool get isLoadingSummits => _isLoadingSummits;

  // API Call: Fetch my abstracts
  Future<bool> fetchMyAbstracts(String accessToken) async {
    _isLoadingList = true;
    notifyListeners();

    try {
      final url = Uri.parse(ApiUrls.myAbstracts);
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      CustomLogger.logRequest('POST', url.toString(), headers: headers);

      final response = await http.post(
        url,
        headers: headers,
      );

      CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);

      _isLoadingList = false;
      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('profile_data');
        notifyListeners();
        MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
        return false;
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _myAbstracts = List<Map<String, dynamic>>.from(data['data'] ?? []);
          notifyListeners();
          return true;
        }
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch my abstracts failed', e, stack);
      _isLoadingList = false;
      notifyListeners();
      return false;
    }
  }

  // API Call: Fetch abstract details
  Future<bool> fetchAbstractDetails(String abstractId, String accessToken) async {
    _isLoadingDetails = true;
    _selectedAbstractDetails = null;
    notifyListeners();

    try {
      final url = Uri.parse(ApiUrls.abstractDetails);
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };
      final body = json.encode({
        'abstract_id': abstractId,
      });

      CustomLogger.logRequest('POST', url.toString(), headers: headers, body: body);

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);

      _isLoadingDetails = false;
      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('profile_data');
        notifyListeners();
        MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
        return false;
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _selectedAbstractDetails = data['data'];
          notifyListeners();
          return true;
        }
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch abstract details failed', e, stack);
      _isLoadingDetails = false;
      notifyListeners();
      return false;
    }
  }

  // API Call: Fetch summits
  Future<bool> fetchSummits(String accessToken) async {
    _isLoadingSummits = true;
    notifyListeners();

    try {
      final url = Uri.parse(ApiUrls.getSummits);
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      CustomLogger.logRequest('GET', url.toString(), headers: headers);

      final response = await http.get(
        url,
        headers: headers,
      );

      CustomLogger.logResponse('GET', url.toString(), response.statusCode, response.body);

      _isLoadingSummits = false;
      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('profile_data');
        notifyListeners();
        MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
        return false;
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _summits = List<Map<String, dynamic>>.from(data['data'] ?? []);
          notifyListeners();
          return true;
        }
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch summits failed', e, stack);
      _isLoadingSummits = false;
      notifyListeners();
      return false;
    }
  }

  // API Call: Submit abstract
  Future<int?> submitAbstract({
    required String summitId,
    required String title,
    required String description,
    required String keywords,
    required String presentationType,
    required File file,
    required String accessToken,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final url = Uri.parse(ApiUrls.submitAbstract);
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.fields['summit_id'] = summitId;
      request.fields['abstract_title'] = title;
      request.fields['abstract_description'] = description;
      request.fields['keywords'] = keywords;
      request.fields['presentation_type'] = presentationType;
      
      final fileExtension = file.path.split('.').last.toLowerCase();
      String mimeType = 'application/octet-stream';
      if (fileExtension == 'pdf') {
        mimeType = 'application/pdf';
      } else if (fileExtension == 'doc') {
        mimeType = 'application/msword';
      } else if (fileExtension == 'docx') {
        mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'abstract_file',
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      CustomLogger.logRequest(
        'POST (Multipart)',
        url.toString(),
        headers: request.headers,
        body: 'Fields: ${request.fields}, File Path: ${file.path}',
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);

      _isSubmitting = false;
      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('profile_data');
        notifyListeners();
        MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
        return null;
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          notifyListeners();
          return data['abstract_id'] is int ? data['abstract_id'] : int.tryParse(data['abstract_id'].toString());
        }
      }
      notifyListeners();
      return null;
    } catch (e, stack) {
      CustomLogger.logError('Submit abstract failed', e, stack);
      _isSubmitting = false;
      notifyListeners();
      return null;
    }
  }

  // API Call: Resubmit abstract
  Future<bool> resubmitAbstract({
    required String abstractId,
    required String title,
    required String description,
    required String keywords,
    required File file,
    required String accessToken,
  }) async {
    _isResubmitting = true;
    notifyListeners();

    try {
      final url = Uri.parse(ApiUrls.resubmitAbstract);
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.fields['abstract_id'] = abstractId;
      request.fields['abstract_title'] = title;
      request.fields['abstract_description'] = description;
      request.fields['keywords'] = keywords;
      
      final fileExtension = file.path.split('.').last.toLowerCase();
      String mimeType = 'application/octet-stream';
      if (fileExtension == 'pdf') {
        mimeType = 'application/pdf';
      } else if (fileExtension == 'doc') {
        mimeType = 'application/msword';
      } else if (fileExtension == 'docx') {
        mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'abstract_file',
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      CustomLogger.logRequest(
        'POST (Multipart)',
        url.toString(),
        headers: request.headers,
        body: 'Fields: ${request.fields}, File Path: ${file.path}',
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);

      _isResubmitting = false;
      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('profile_data');
        notifyListeners();
        MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
        return false;
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          notifyListeners();
          return true;
        }
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Resubmit abstract failed', e, stack);
      _isResubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
