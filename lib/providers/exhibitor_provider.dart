import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../domain/api_service.dart';
import '../models/exhibitor_models.dart';

class ExhibitorProvider extends ChangeNotifier {
  ExhibitorCountsData? _countsData;
  List<ExhibitorParticipant> _participants = [];

  bool _isLoadingCounts = false;
  bool _isLoadingParticipants = false;
  bool _isScanning = false;
  String? _errorMessage;

  String? _selectedDate;
  dynamic _selectedBoothId;
  String _searchQuery = '';

  // Getters
  ExhibitorCountsData? get countsData => _countsData;
  ExhibitorSummary get summary => _countsData?.summary ?? ExhibitorSummary(totalVisits: 0, uniqueVisitors: 0);
  List<BoothDayCount> get byBoothDay => _countsData?.byBoothDay ?? [];
  List<ExhibitorParticipant> get participants => _participants;

  bool get isLoadingCounts => _isLoadingCounts;
  bool get isLoadingParticipants => _isLoadingParticipants;
  bool get isLoading => _isLoadingCounts || _isLoadingParticipants;
  bool get isScanning => _isScanning;
  String? get errorMessage => _errorMessage;

  String? get selectedDate => _selectedDate;
  dynamic get selectedBoothId => _selectedBoothId;
  String get searchQuery => _searchQuery;

  // Filtered Participants based on search query, date, and booth
  List<ExhibitorParticipant> get filteredParticipants {
    return _participants.where((p) {
      if (_selectedDate != null && _selectedDate!.isNotEmpty) {
        if (p.visitedDate.isNotEmpty && p.visitedDate != _selectedDate) {
          return false;
        }
      }
      if (_selectedBoothId != null && _selectedBoothId.toString().isNotEmpty && _selectedBoothId.toString() != 'All') {
        if (p.boothId != null && p.boothId.toString() != _selectedBoothId.toString()) {
          return false;
        }
      }
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      final matchName = p.name.toLowerCase().contains(q);
      final matchRole = p.roleLabel.toLowerCase().contains(q) || p.role.toLowerCase().contains(q);
      final matchDesig = p.designation.toLowerCase().contains(q);
      final matchOrg = p.organisation.toLowerCase().contains(q);
      final matchCity = p.city.toLowerCase().contains(q);
      final matchMobile = p.mobile.toLowerCase().contains(q);
      final matchEmail = p.email.toLowerCase().contains(q);
      final matchBooth = p.boothNumber.toLowerCase().contains(q);
      return matchName || matchRole || matchDesig || matchOrg || matchCity || matchMobile || matchEmail || matchBooth;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedDate(String? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSelectedBoothId(dynamic boothId) {
    _selectedBoothId = boothId;
    notifyListeners();
  }

  void clearFilters() {
    _selectedDate = null;
    _selectedBoothId = null;
    _searchQuery = '';
    notifyListeners();
  }

  // Fetch Footfall Counts
  Future<void> fetchCounts(
    String accessToken, {
    dynamic summitId = 1,
    String? date,
    bool forceRefresh = false,
  }) async {
    if (accessToken.isEmpty) return;
    if (_isLoadingCounts && !forceRefresh) return;

    _isLoadingCounts = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getExhibitorCounts(
        accessToken: accessToken,
        summitId: summitId,
        date: date ?? _selectedDate,
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          _countsData = ExhibitorCountsData.fromJson(Map<String, dynamic>.from(body['data']));
        }
      } else {
        debugPrint('⚠️ [ExhibitorProvider] fetchCounts failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ [ExhibitorProvider] fetchCounts error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoadingCounts = false;
      notifyListeners();
    }
  }

  // Fetch Visited Participants
  Future<void> fetchParticipants(
    String accessToken, {
    dynamic summitId = 1,
    String? date,
    dynamic boothId,
    bool forceRefresh = false,
  }) async {
    if (accessToken.isEmpty) return;
    if (_isLoadingParticipants && !forceRefresh) return;

    _isLoadingParticipants = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getExhibitorParticipants(
        accessToken: accessToken,
        summitId: summitId,
        date: date ?? _selectedDate,
        boothId: boothId ?? (_selectedBoothId != 'All' ? _selectedBoothId : null),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          final List<dynamic> list = body['data'] is List ? body['data'] : [];
          _participants = list
              .map((item) => ExhibitorParticipant.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      } else {
        debugPrint('⚠️ [ExhibitorProvider] fetchParticipants failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ [ExhibitorProvider] fetchParticipants error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoadingParticipants = false;
      notifyListeners();
    }
  }

  // Fetch All Footfall & Participants Data
  Future<void> fetchAllExhibitorData(
    String accessToken, {
    dynamic summitId = 1,
    String? date,
    dynamic boothId,
    bool forceRefresh = false,
  }) async {
    await Future.wait([
      fetchCounts(accessToken, summitId: summitId, date: date, forceRefresh: forceRefresh),
      fetchParticipants(accessToken, summitId: summitId, date: date, boothId: boothId, forceRefresh: forceRefresh),
    ]);
  }

  // Record a QR scan
  Future<Map<String, dynamic>> recordScan(
    String accessToken, {
    required String qrData,
    dynamic boothId,
    String? remarks,
    dynamic summitId = 1,
  }) async {
    if (accessToken.isEmpty) {
      return {'status': false, 'message': 'Authentication required'};
    }

    _isScanning = true;
    notifyListeners();

    try {
      final response = await ApiService.recordExhibitorScan(
        accessToken: accessToken,
        qrData: qrData,
        boothId: boothId ?? _selectedBoothId,
        remarks: remarks,
      );

      final body = json.decode(response.body);
      final bool status = body['status'] == true;
      final String message = body['message']?.toString() ??
          (status ? 'Visit recorded successfully' : 'Failed to record visit');

      if (status) {
        // Refresh counts and history
        await fetchAllExhibitorData(accessToken, summitId: summitId, forceRefresh: true);
      }

      return {
        'status': status,
        'message': message,
        'data': body['data'],
      };
    } catch (e) {
      debugPrint('⚠️ [ExhibitorProvider] recordScan error: $e');
      return {
        'status': false,
        'message': 'Failed to record scan: $e',
      };
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }
}
