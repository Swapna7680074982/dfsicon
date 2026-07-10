import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dfsicon/main.dart';
import 'package:dfsicon/domain/api_service.dart';
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

  String? _errorMessage;

  // Topics-specific state variables
  List<Map<String, dynamic>> _myTopics = [];
  Map<String, dynamic>? _selectedTopicDetails;
  bool _isLoadingTopicsList = false;
  bool _isLoadingTopicDetails = false;
  bool _isUpdatingTopic = false;

  // Getters
  List<Map<String, dynamic>> get myAbstracts => _myAbstracts;
  List<Map<String, dynamic>> get myTopics => _myTopics;
  Map<String, dynamic>? get selectedTopicDetails => _selectedTopicDetails;
  bool get isLoadingTopicsList => _isLoadingTopicsList;
  bool get isLoadingTopicDetails => _isLoadingTopicDetails;
  bool get isUpdatingTopic => _isUpdatingTopic;
  bool get isLoadingList => _isLoadingList;
  
  Map<String, dynamic>? get selectedAbstractDetails => _selectedAbstractDetails;
  bool get isLoadingDetails => _isLoadingDetails;

  bool get isSubmitting => _isSubmitting;
  bool get isResubmitting => _isResubmitting;

  List<Map<String, dynamic>> get summits => _summits;
  bool get isLoadingSummits => _isLoadingSummits;

  String? get errorMessage => _errorMessage;

  // API Call: Fetch my abstracts
  Future<bool> fetchMyAbstracts(String accessToken) async {
    if (accessToken.isEmpty) return false;
    if (_isLoadingList) return false; // Prevent duplicate concurrent loading
    _isLoadingList = true;
    _myAbstracts = []; // Clear previous abstracts
    notifyListeners();

    try {
      final response = await ApiService.fetchMyAbstracts(accessToken: accessToken);

      _isLoadingList = false;
      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('profile_data');
        notifyListeners();
        MyApp.redirectToLogin();
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
    if (accessToken.isEmpty) return false;
    _isLoadingDetails = true;
    _selectedAbstractDetails = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchAbstractDetails(
        abstractId: abstractId,
        accessToken: accessToken,
      );

      _isLoadingDetails = false;
      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('profile_data');
        notifyListeners();
        MyApp.redirectToLogin();
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
    if (accessToken.isEmpty) return false;
    _isLoadingSummits = true;
    notifyListeners();

    try {
      final response = await ApiService.fetchSummits(accessToken: accessToken);

      _isLoadingSummits = false;
      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('profile_data');
        notifyListeners();
        MyApp.redirectToLogin();
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
    File? thumbnail,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return null;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.submitAbstract(
        summitId: summitId,
        title: title,
        description: description,
        keywords: keywords,
        presentationType: presentationType,
        file: file,
        thumbnail: thumbnail,
        accessToken: accessToken,
      );

      _isSubmitting = false;
      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('profile_data');
        notifyListeners();
        MyApp.redirectToLogin();
        return null;
      }
      try {
        final data = json.decode(response.body);
        if (response.statusCode == 200 && data['status'] == true) {
          notifyListeners();
          return data['abstract_id'] is int ? data['abstract_id'] : int.tryParse(data['abstract_id'].toString());
        } else {
          _errorMessage = data['message'] ?? 'Failed to submit abstract.';
        }
      } catch (e) {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
      notifyListeners();
      return null;
    } catch (e, stack) {
      CustomLogger.logError('Submit abstract failed', e, stack);
      _isSubmitting = false;
      _errorMessage = e.toString();
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
    File? thumbnail,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return false;
    _isResubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.resubmitAbstract(
        abstractId: abstractId,
        title: title,
        description: description,
        keywords: keywords,
        file: file,
        thumbnail: thumbnail,
        accessToken: accessToken,
      );

      _isResubmitting = false;
      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('profile_data');
        notifyListeners();
        MyApp.redirectToLogin();
        return false;
      }
      try {
        final data = json.decode(response.body);
        if (response.statusCode == 200 && data['status'] == true) {
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Failed to resubmit abstract.';
        }
      } catch (e) {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Resubmit abstract failed', e, stack);
      _isResubmitting = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==========================================
  // Speaker Topics API Calls
  // ==========================================
  Future<bool> fetchMyTopics(String accessToken, {bool forceRefresh = false}) async {
    if (accessToken.isEmpty) return false;
    if (!forceRefresh && _myTopics.isNotEmpty) return true;
    if (_isLoadingTopicsList) return false; // Prevent duplicate concurrent loading
    _isLoadingTopicsList = true;
    _myTopics = []; // Clear previous topics
    notifyListeners();

    try {
      final response = await ApiService.fetchSpeakerMyTopics(accessToken: accessToken);
      _isLoadingTopicsList = false;

      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('profile_data');
        notifyListeners();
        MyApp.redirectToLogin();
        return false;
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _myTopics = List<Map<String, dynamic>>.from(data['data'] ?? []);
          notifyListeners();
          return true;
        }
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch my topics failed', e, stack);
      _isLoadingTopicsList = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchTopicDetails(String topicId, String accessToken) async {
    if (accessToken.isEmpty) return false;
    _isLoadingTopicDetails = true;
    _selectedTopicDetails = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchSpeakerTopicDetails(
        topicId: topicId,
        accessToken: accessToken,
      );
      _isLoadingTopicDetails = false;

      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('profile_data');
        notifyListeners();
        MyApp.redirectToLogin();
        return false;
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _selectedTopicDetails = data['data'];
          notifyListeners();
          return true;
        }
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Fetch topic details failed', e, stack);
      _isLoadingTopicDetails = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTopicDetails({
    required Map<String, dynamic> body,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) return false;
    _isUpdatingTopic = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.updateSpeakerTopicDetails(
        body: body,
        accessToken: accessToken,
      );
      _isUpdatingTopic = false;

      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('profile_data');
        notifyListeners();
        MyApp.redirectToLogin();
        return false;
      }
      
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Failed to update topic details';
      }
      notifyListeners();
      return false;
    } catch (e, stack) {
      CustomLogger.logError('Update topic details failed', e, stack);
      _isUpdatingTopic = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
