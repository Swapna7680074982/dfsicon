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

  // Getters
  List<Map<String, dynamic>> get myAbstracts => _myAbstracts;
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
    _isLoadingList = true;
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
}
