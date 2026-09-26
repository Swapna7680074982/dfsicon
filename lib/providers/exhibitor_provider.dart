import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/api_service.dart';
import '../models/exhibitor_models.dart';

class ExhibitorProvider extends ChangeNotifier {
  static const String _kPendingScansKey = 'pending_exhibitor_scans_queue';

  ExhibitorCountsData? _countsData;
  List<ExhibitorParticipant> _participants = [];
  List<Map<String, dynamic>> _pendingScans = [];

  bool _isLoadingCounts = false;
  bool _isLoadingParticipants = false;
  bool _isScanning = false;
  bool _isSyncing = false;
  String? _errorMessage;

  String? _selectedDate;
  dynamic _selectedBoothId;
  String _selectedRoleFilter = 'All'; // 'All', 'Delegates', 'Exhibitors', 'Speakers'
  String _searchQuery = '';

  ExhibitorProvider() {
    loadPendingScans();
  }

  // Getters
  ExhibitorCountsData? get countsData => _countsData;
  ExhibitorSummary get summary => _countsData?.summary ?? ExhibitorSummary(totalVisits: 0, uniqueVisitors: 0);
  List<BoothDayCount> get byBoothDay => _countsData?.byBoothDay ?? [];
  List<ExhibitorParticipant> get participants => _participants;
  List<Map<String, dynamic>> get pendingScans => List.unmodifiable(_pendingScans);
  int get pendingScansCount => _pendingScans.length;

  bool get isLoadingCounts => _isLoadingCounts;
  bool get isLoadingParticipants => _isLoadingParticipants;
  bool get isLoading => _isLoadingCounts || _isLoadingParticipants;
  bool get isScanning => _isScanning;
  bool get isSyncing => _isSyncing;
  String? get errorMessage => _errorMessage;

  String? get selectedDate => _selectedDate;
  dynamic get selectedBoothId => _selectedBoothId;
  String get selectedRoleFilter => _selectedRoleFilter;
  String get searchQuery => _searchQuery;

  // Filtered Participants based on search query, date, booth, and attendee role
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
      if (_selectedRoleFilter != 'All') {
        final r = p.role.toUpperCase();
        final rl = p.roleLabel.toLowerCase();
        if (_selectedRoleFilter == 'Delegates') {
          if (r != 'DG' && !rl.contains('delegate')) return false;
        } else if (_selectedRoleFilter == 'Exhibitors') {
          if (r != 'EX' && !rl.contains('exhibitor')) return false;
        } else if (_selectedRoleFilter == 'Speakers') {
          if (r != 'SK' && !rl.contains('speaker')) return false;
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

  void setSelectedRoleFilter(String role) {
    _selectedRoleFilter = role;
    notifyListeners();
  }

  void clearFilters() {
    _selectedDate = null;
    _selectedBoothId = null;
    _selectedRoleFilter = 'All';
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
          _participants = list.map((item) {
            final p = ExhibitorParticipant.fromJson(Map<String, dynamic>.from(item));
            if (p.boothLabel.isEmpty && _countsData != null) {
              for (final b in _countsData!.byBoothDay) {
                if ((p.boothId != null && b.boothId?.toString() == p.boothId?.toString()) ||
                    (p.boothNumber.isNotEmpty && b.boothNumber.toLowerCase() == p.boothNumber.toLowerCase())) {
                  if (b.boothLabel.isNotEmpty) {
                    return ExhibitorParticipant(
                      footfallId: p.footfallId,
                      userId: p.userId,
                      name: p.name,
                      role: p.role,
                      roleLabel: p.roleLabel,
                      designation: p.designation,
                      organisation: p.organisation,
                      city: p.city,
                      mobile: p.mobile,
                      email: p.email,
                      boothId: p.boothId,
                      boothNumber: p.boothNumber.isNotEmpty ? p.boothNumber : b.boothNumber,
                      boothLabel: b.boothLabel,
                      visitedDate: p.visitedDate,
                      visitedTime: p.visitedTime,
                      visitCount: p.visitCount,
                    );
                  }
                }
              }
            }
            return p;
          }).toList();
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

  // ==========================================
  // OFFLINE FOOTFALL VISITS & SYNC LATER LOGIC
  // ==========================================

  // Load queued scans from local storage
  Future<void> loadPendingScans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_kPendingScansKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = json.decode(raw);
        _pendingScans = decoded.whereType<Map<String, dynamic>>().toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('⚠️ [ExhibitorProvider] loadPendingScans error: $e');
    }
  }

  // Save current queue to local storage
  Future<void> _savePendingScansToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_pendingScans);
      await prefs.setString(_kPendingScansKey, encoded);
    } catch (e) {
      debugPrint('⚠️ [ExhibitorProvider] _savePendingScansToPrefs error: $e');
    }
  }

  // Queue a visit locally for syncing later
  Future<Map<String, dynamic>> queueOfflineScan({
    String? qrData,
    String? mobile,
    dynamic boothId,
    String? remarks,
    dynamic summitId = 1,
    String? previewName,
  }) async {
    final Map<String, dynamic> item = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'qr_data': qrData,
      'mobile': mobile,
      'booth_id': boothId ?? _selectedBoothId,
      'remarks': remarks,
      'summit_id': summitId,
      'timestamp': DateTime.now().toIso8601String(),
      'preview_name': previewName ?? (qrData ?? mobile ?? 'Offline Visitor'),
    };

    // Prevent identical duplicates in queue
    final isDuplicate = _pendingScans.any((s) =>
        (qrData != null && qrData.isNotEmpty && s['qr_data'] == qrData) ||
        (mobile != null && mobile.isNotEmpty && s['mobile'] == mobile));

    if (!isDuplicate) {
      _pendingScans.add(item);
      await _savePendingScansToPrefs();
      notifyListeners();
    }

    return {
      'status': true,
      'isOffline': true,
      'message': 'Visit saved offline. Will sync automatically when network connects.',
      'data': {
        'visitor_name': item['preview_name'],
        'visitor_role': 'Offline Saved',
      },
    };
  }

  // Sync all pending visits to the server
  Future<Map<String, dynamic>> syncPendingScans(
    String accessToken, {
    dynamic summitId = 1,
  }) async {
    if (_isSyncing || _pendingScans.isEmpty || accessToken.isEmpty) {
      return {
        'total': _pendingScans.length,
        'synced': 0,
        'failed': 0,
      };
    }

    _isSyncing = true;
    notifyListeners();

    int syncedCount = 0;
    int failedCount = 0;
    final List<Map<String, dynamic>> remainingQueue = [];

    for (final scan in _pendingScans) {
      try {
        final response = await ApiService.recordExhibitorScan(
          accessToken: accessToken,
          qrData: scan['qr_data']?.toString(),
          mobile: scan['mobile']?.toString(),
          boothId: scan['booth_id'],
          remarks: scan['remarks']?.toString(),
        );

        if (response.statusCode == 200) {
          final body = json.decode(response.body);
          if (body['status'] == true) {
            syncedCount++;
          } else {
            final msg = body['message']?.toString().toLowerCase() ?? '';
            if (msg.contains('already') || msg.contains('duplicate')) {
              syncedCount++; // Already registered on server, treat as synced
            } else {
              failedCount++;
              remainingQueue.add(scan);
            }
          }
        } else {
          failedCount++;
          remainingQueue.add(scan);
        }
      } catch (e) {
        debugPrint('⚠️ [ExhibitorProvider] sync error for item: $e');
        failedCount++;
        remainingQueue.add(scan);
      }
    }

    _pendingScans = remainingQueue;
    await _savePendingScansToPrefs();

    if (syncedCount > 0) {
      // Refresh counts and attendee list
      await fetchAllExhibitorData(accessToken, summitId: summitId, forceRefresh: true);
    }

    _isSyncing = false;
    notifyListeners();

    return {
      'total': syncedCount + failedCount,
      'synced': syncedCount,
      'failed': failedCount,
      'remaining': _pendingScans.length,
    };
  }

  // Clear pending queue
  Future<void> clearPendingScans() async {
    _pendingScans.clear();
    await _savePendingScansToPrefs();
    notifyListeners();
  }

  // Record a QR scan or mobile entry (with graceful offline fallback)
  Future<Map<String, dynamic>> recordScan(
    String accessToken, {
    String? qrData,
    String? mobile,
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
        mobile: mobile,
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
      debugPrint('⚠️ [ExhibitorProvider] recordScan network error, queueing offline: $e');
      // Gracefully save visit offline when network is disconnected
      final offlineResult = await queueOfflineScan(
        qrData: qrData,
        mobile: mobile,
        boothId: boothId ?? _selectedBoothId,
        remarks: remarks,
        summitId: summitId,
      );
      return offlineResult;
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }
}
