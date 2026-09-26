import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../profile/profile_screen.dart';
import '../calendar/event_calendar_screen.dart';
import '../../services/documents_service.dart';
import '../../services/footfall_report_service.dart';
import '../../widgets/documents_modal_sheet.dart';
import '../../utils/time_formatter.dart';
import 'admin_detail_sheets.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _speakerSearchCtrl = TextEditingController();
  final TextEditingController _delegateSearchCtrl = TextEditingController();
  final TextEditingController _topicSearchCtrl = TextEditingController();
  final TextEditingController _workshopSearchCtrl = TextEditingController();
  final TextEditingController _sponsorSearchCtrl = TextEditingController();
  final TextEditingController _boothSearchCtrl = TextEditingController();
  final TextEditingController _footfallSearchCtrl = TextEditingController();

  Timer? _debounceTimer;
  String _speakerFilterText = '';
  String _delegateFilterText = '';
  String _topicFilterText = '';
  String _workshopFilterText = '';
  String _sponsorFilterText = '';
  String _boothFilterText = '';
  String _footfallFilterText = '';
  String _selectedTopicStatus = 'All'; // 'All', 'Confirmed', 'Approved'
  String _selectedExhibitorCategory = 'All';
  String _selectedBoothStatus = 'All'; // 'All', 'Allocated', 'Free'
  String? _selectedFootfallSponsorId;
  String _selectedFootfallBoothId = 'All';
  String? _selectedFootfallDate;
  AdminSponsorBoothStatsData? _footfallStatsData;
  List<AdminFootfallParticipant> _footfallParticipants = [];
  AdminPagination _footfallPagination = const AdminPagination();
  bool _isLoadingFootfall = false;
  bool _isLoadingMoreParticipants = false;
  String? _footfallError;

  int _lastTabIndex = 0;

  final List<String> _tabs = [
    'Overview',
    'Speakers',
    'Delegates',
    'Topics',
    'Workshops',
    'Exhibitors',
    'Booths',
    'Booth Footfall',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAdminData(forceRefresh: false);
    });
  }

  void _handleTabChange() {
    if (_tabController.index != _lastTabIndex) {
      _lastTabIndex = _tabController.index;
      _clearAllSearches();
      if (_tabController.index == 7 && _footfallStatsData == null && !_isLoadingFootfall) {
        _loadFootfallData();
      }
    }
  }

  void _clearAllSearches() {
    _debounceTimer?.cancel();
    bool needsSetState = false;
    if (_speakerSearchCtrl.text.isNotEmpty || _speakerFilterText.isNotEmpty) {
      _speakerSearchCtrl.clear();
      _speakerFilterText = '';
      needsSetState = true;
    }
    if (_delegateSearchCtrl.text.isNotEmpty || _delegateFilterText.isNotEmpty) {
      _delegateSearchCtrl.clear();
      _delegateFilterText = '';
      needsSetState = true;
    }
    if (_topicSearchCtrl.text.isNotEmpty || _topicFilterText.isNotEmpty) {
      _topicSearchCtrl.clear();
      _topicFilterText = '';
      needsSetState = true;
    }
    if (_workshopSearchCtrl.text.isNotEmpty || _workshopFilterText.isNotEmpty) {
      _workshopSearchCtrl.clear();
      _workshopFilterText = '';
      needsSetState = true;
    }
    if (_sponsorSearchCtrl.text.isNotEmpty || _sponsorFilterText.isNotEmpty) {
      _sponsorSearchCtrl.clear();
      _sponsorFilterText = '';
      needsSetState = true;
    }
    if (_boothSearchCtrl.text.isNotEmpty || _boothFilterText.isNotEmpty) {
      _boothSearchCtrl.clear();
      _boothFilterText = '';
      needsSetState = true;
    }
    if (_footfallSearchCtrl.text.isNotEmpty || _footfallFilterText.isNotEmpty) {
      _footfallSearchCtrl.clear();
      _footfallFilterText = '';
      needsSetState = true;
    }
    if (needsSetState && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _debounceTimer?.cancel();
    _tabController.dispose();
    _speakerSearchCtrl.dispose();
    _delegateSearchCtrl.dispose();
    _topicSearchCtrl.dispose();
    _workshopSearchCtrl.dispose();
    _sponsorSearchCtrl.dispose();
    _boothSearchCtrl.dispose();
    _footfallSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFootfallData({bool reset = true, bool loadMore = false}) async {
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final admin = Provider.of<AdminProvider>(context, listen: false);

    if (auth.accessToken.isEmpty) return;

    if (_selectedFootfallSponsorId == null || _selectedFootfallSponsorId!.isEmpty) {
      if (admin.sponsors.isNotEmpty) {
        _selectedFootfallSponsorId = admin.sponsors.first.sponsorId;
      } else {
        await admin.fetchSponsors(auth.accessToken);
        if (admin.sponsors.isNotEmpty) {
          _selectedFootfallSponsorId = admin.sponsors.first.sponsorId;
        } else {
          return;
        }
      }
    }

    if (reset) {
      setState(() {
        _isLoadingFootfall = true;
        _footfallError = null;
      });
    } else if (loadMore) {
      if (_isLoadingMoreParticipants || !_footfallPagination.hasNext) return;
      setState(() {
        _isLoadingMoreParticipants = true;
      });
    }

    final targetPage = loadMore ? _footfallPagination.currentPage + 1 : 1;

    try {
      final futures = <Future>[];
      if (reset) {
        futures.add(
          admin.fetchSponsorBoothStats(
            auth.accessToken,
            sponsorId: _selectedFootfallSponsorId,
            date: _selectedFootfallDate,
          ),
        );
      }

      futures.add(
        admin.fetchSponsorFootfallParticipants(
          auth.accessToken,
          sponsorId: _selectedFootfallSponsorId,
          boothId: _selectedFootfallBoothId == 'All' ? null : _selectedFootfallBoothId,
          date: _selectedFootfallDate,
          page: targetPage,
          limit: 15,
        ),
      );

      final results = await Future.wait(futures);

      if (mounted) {
        setState(() {
          if (reset && results.isNotEmpty && results[0] is AdminSponsorBoothStatsData) {
            _footfallStatsData = results[0] as AdminSponsorBoothStatsData;
          }

          final participantResult = reset ? results[1] as Map<String, dynamic> : results[0] as Map<String, dynamic>;
          final newParticipants = participantResult['participants'] as List<AdminFootfallParticipant>;
          final newPagination = participantResult['pagination'] as AdminPagination;

          if (loadMore) {
            _footfallParticipants.addAll(newParticipants);
          } else {
            _footfallParticipants = newParticipants;
          }
          _footfallPagination = newPagination;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _footfallError = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFootfall = false;
          _isLoadingMoreParticipants = false;
        });
      }
    }
  }

  void _navigateToFootfallTab(String sponsorId) {
    setState(() {
      _selectedFootfallSponsorId = sponsorId;
      _selectedFootfallBoothId = 'All';
      _selectedFootfallDate = null;
      _footfallStatsData = null;
      _footfallParticipants = [];
    });
    _loadFootfallData();
    _tabController.animateTo(7);
  }



  Future<void> _loadAdminData({bool forceRefresh = false}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    if (auth.accessToken.isNotEmpty) {
      await Future.wait([
        adminProvider.fetchAllAdminData(auth.accessToken, forceRefresh: forceRefresh),
        DocumentsService.fetchDocuments(accessToken: auth.accessToken, roleCode: 'AD'),
      ]);
    }
  }

  Future<void> _handleBackPress() async {
    if (_tabController.index != 0) {
      _tabController.animateTo(0);
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.exit_to_app_rounded, color: Color(0xFF4F46E5), size: 22),
            SizedBox(width: 8),
            Text(
              'Exit Application',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to exit the app?',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Exit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'AD';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0].isNotEmpty && parts[1].isNotEmpty)
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'AD';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final admin = Provider.of<AdminProvider>(context);
    final userName = auth.userName.isNotEmpty ? auth.userName : 'Administrator';
    final initials = _getInitials(userName);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Image.asset(
          'assets/logo2.png',
          height: 30,
          errorBuilder: (context, error, stackTrace) => const Text(
            'DFSICON 2026',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFC7D2FE), width: 0.8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 13,
                  color: Color(0xFF4F46E5),
                ),
                SizedBox(width: 4),
                Text(
                  'ADMIN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                  border: Border.all(
                    color: const Color(0xFFC7D2FE),
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: auth.hasValidProfileImage
                    ? ClipOval(
                        child: Image.network(
                          auth.profileImage,
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              indicatorColor: const Color(0xFF4F46E5),
              indicatorWeight: 2.8,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: const Color(0xFF4F46E5),
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(auth, admin),
          _buildSpeakersTab(auth, admin),
          _buildDelegatesTab(auth, admin),
          _buildTopicsTab(auth, admin),
          _buildWorkshopsTab(auth, admin),
          _buildSponsorsTab(auth, admin),
          _buildBoothsTab(auth, admin),
          _buildFootfallTab(auth, admin),
        ],
      ),
    ),
  );
}

  // ==========================================
  // TAB 1: OVERVIEW & STATS
  // ==========================================
  Widget _buildOverviewTab(AuthProvider auth, AdminProvider admin) {
    final stats = admin.stats ?? const AdminDashboardStats();

    return RefreshIndicator(
      onRefresh: () => _loadAdminData(forceRefresh: true),
      color: const Color(0xFF4F46E5),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Executive Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3730A3), Color(0xFF4F46E5), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.dashboard_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Executive Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Real-time overview of registrations, scientific topics, workshops & exhibitor allocations.',
                    style: TextStyle(
                      color: Color(0xFFE0E7FF),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section Title
            const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 10),
              child: Text(
                'CONFERENCE KEY METRICS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            if (admin.isLoadingStats && admin.stats == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                ),
              )
            else ...[
              // Grid of 6 Stats Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.38,
                children: [
                  _buildStatCard(
                    icon: Icons.record_voice_over_rounded,
                    iconBg: const Color(0xFFEEF2FF),
                    iconColor: const Color(0xFF4F46E5),
                    count: '${stats.totalSpeakers}',
                    label: 'SPEAKERS',
                    onTap: () => _tabController.animateTo(1),
                  ),
                  _buildStatCard(
                    icon: Icons.people_alt_rounded,
                    iconBg: const Color(0xFFECFDF5),
                    iconColor: const Color(0xFF059669),
                    count: '${stats.totalDelegates}',
                    label: 'DELEGATES',
                    onTap: () => _tabController.animateTo(2),
                  ),
                  _buildStatCard(
                    icon: Icons.description_rounded,
                    iconBg: const Color(0xFFFFFBEB),
                    iconColor: const Color(0xFFD97706),
                    count: '${stats.totalTopics}',
                    subCount: '${stats.confirmedTopics} Slot Assigned',
                    label: 'TOPICS',
                    onTap: () => _tabController.animateTo(3),
                  ),
                  _buildStatCard(
                    icon: Icons.assignment_turned_in_rounded,
                    iconBg: const Color(0xFFFAF5FF),
                    iconColor: const Color(0xFF9333EA),
                    count: '${stats.totalWorkshops}',
                    label: 'WORKSHOPS',
                    onTap: () => _tabController.animateTo(4),
                  ),
                  _buildStatCard(
                    icon: Icons.storefront_rounded,
                    iconBg: const Color(0xFFFDF2F8),
                    iconColor: const Color(0xFFDB2777),
                    count: '${stats.totalExhibitors}',
                    label: 'EXHIBITORS',
                    onTap: () => _tabController.animateTo(5),
                  ),
                  _buildStatCard(
                    icon: Icons.meeting_room_rounded,
                    iconBg: const Color(0xFFF0F9FF),
                    iconColor: const Color(0xFF0284C7),
                    count: '${stats.totalAssignedBooths} / ${stats.totalBooths}',
                    subCount: 'Allocated / Total',
                    label: 'BOOTHS',
                    onTap: () => _tabController.animateTo(6),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Master Schedule Calendar Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF312E81).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EventCalendarScreen(role: CalendarRole.admin),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Master Schedule Calendar',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Day-wise sessions, workshops & halls timeline',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFC7D2FE),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Open',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Exhibitor Footfall Analytics Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF065F46), Color(0xFF059669), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () {
                      _tabController.animateTo(7);
                      if (_footfallStatsData == null) {
                        _loadFootfallData();
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: const Icon(
                              Icons.query_stats_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Exhibitor Footfall & Analytics',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Live attendee visits, unique visitor logs & booth stats',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFD1FAE5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Conference Documents Banner Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () {
                      DocumentsModalSheet.show(context, roleCode: 'AD');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: const Icon(
                              Icons.folder_shared_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Conference Documents & Guidelines',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Test PDF, Venue Map, Guidelines & Schedule',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Slots Banner Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => showAdminAllSlotsModal(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDFA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.access_time_filled_rounded,
                              color: Color(0xFF0D9488),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Agenda Presentation Slots',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${stats.availableSlots} available out of ${stats.totalSlots} total slots',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDFA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF99F6E4), width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${stats.availableSlots} Left',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D9488),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF0D9488)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Quick Navigation Shortcuts
            const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 10),
              child: Text(
                'DIRECT DIRECTORIES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            _buildDirectoryTile(
              title: 'All Speakers Directory',
              subtitle: '${stats.totalSpeakers} registered speakers & faculty members',
              icon: Icons.record_voice_over_rounded,
              iconColor: const Color(0xFF4F46E5),
              iconBg: const Color(0xFFEEF2FF),
              onTap: () => _tabController.animateTo(1),
            ),
            const SizedBox(height: 8),
            _buildDirectoryTile(
              title: 'All Delegates Directory',
              subtitle: '${stats.totalDelegates} registered delegates',
              icon: Icons.people_alt_rounded,
              iconColor: const Color(0xFF059669),
              iconBg: const Color(0xFFECFDF5),
              onTap: () => _tabController.animateTo(2),
            ),
            const SizedBox(height: 8),
            _buildDirectoryTile(
              title: 'Scientific Topics & Submissions',
              subtitle: '${stats.totalTopics} topics (${stats.confirmedTopics} slot assigned)',
              icon: Icons.description_rounded,
              iconColor: const Color(0xFFD97706),
              iconBg: const Color(0xFFFFFBEB),
              onTap: () => _tabController.animateTo(3),
            ),
            const SizedBox(height: 8),
            _buildDirectoryTile(
              title: 'Workshops & Practical Labs',
              subtitle: '${stats.totalWorkshops} surgical and clinical workshops',
              icon: Icons.assignment_turned_in_rounded,
              iconColor: const Color(0xFF9333EA),
              iconBg: const Color(0xFFFAF5FF),
              onTap: () => _tabController.animateTo(4),
            ),
            const SizedBox(height: 8),
            _buildDirectoryTile(
              title: 'Exhibitors & Trade Partners',
              subtitle: '${stats.totalExhibitors} registered trade partners & exhibitors',
              icon: Icons.storefront_rounded,
              iconColor: const Color(0xFFDB2777),
              iconBg: const Color(0xFFFDF2F8),
              onTap: () => _tabController.animateTo(5),
            ),
            const SizedBox(height: 8),
            _buildDirectoryTile(
              title: 'Exhibition Booth Assignments',
              subtitle: '${stats.totalAssignedBooths} booths allocated of ${stats.totalBooths}',
              icon: Icons.meeting_room_rounded,
              iconColor: const Color(0xFF0284C7),
              iconBg: const Color(0xFFF0F9FF),
              onTap: () => _tabController.animateTo(6),
            ),
            const SizedBox(height: 8),
            _buildDirectoryTile(
              title: 'Agenda Presentation Slots Schedule',
              subtitle: '${stats.availableSlots} free slots out of ${stats.totalSlots} tracks',
              icon: Icons.access_time_filled_rounded,
              iconColor: const Color(0xFF0D9488),
              iconBg: const Color(0xFFF0FDFA),
              onTap: () => showAdminAllSlotsModal(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String count,
    String? subCount,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 17),
                ),
                const SizedBox(height: 6),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subCount != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subCount,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectoryTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: SPEAKERS LIST
  // ==========================================
  Widget _buildSpeakersTab(AuthProvider auth, AdminProvider admin) {
    final filteredSpeakers = admin.speakers.where((speaker) {
      if (_speakerFilterText.trim().isEmpty) return true;
      final q = _speakerFilterText.trim().toLowerCase();
      final matchName = speaker.fullName.toLowerCase().contains(q);
      final matchCity = speaker.city.toLowerCase().contains(q) || speaker.state.toLowerCase().contains(q);
      final matchOrg = speaker.organisationName.toLowerCase().contains(q);
      final matchDesig = speaker.designation.toLowerCase().contains(q);
      final matchQual = speaker.qualification.toLowerCase().contains(q);
      final matchCitizen = speaker.citizenType.toLowerCase().contains(q);
      return matchName || matchCity || matchOrg || matchDesig || matchQual || matchCitizen;
    }).toList();

    return Column(
      children: [
        _buildSearchBar(
          controller: _speakerSearchCtrl,
          hint: 'Search by name, city, hospital / organisation...',
          onChanged: (val) {
            setState(() => _speakerFilterText = val);
          },
          onSubmitted: (val) {
            setState(() => _speakerFilterText = val);
          },
          onClear: () {
            _speakerSearchCtrl.clear();
            setState(() => _speakerFilterText = '');
          },
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => admin.fetchSpeakers(auth.accessToken, forceRefresh: true),
            color: const Color(0xFF4F46E5),
            child: admin.isLoadingSpeakers && admin.speakers.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                : filteredSpeakers.isEmpty
                    ? _buildEmptyState('No speakers found matching your search')
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        itemCount: filteredSpeakers.length + (admin.speakersPagination.hasNext && _speakerFilterText.isEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredSpeakers.length) {
                            return _buildLoadMoreButton(
                              isLoading: admin.isLoadingMoreSpeakers,
                              onPressed: () {
                                admin.fetchSpeakers(auth.accessToken, loadMore: true);
                              },
                            );
                          }
                          final speaker = filteredSpeakers[index];
                          return _buildSpeakerCard(speaker);
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakerCard(AdminSpeaker speaker) {
    final initials = _getInitials(speaker.fullName);
    final location = [speaker.city, speaker.state].where((s) => s.isNotEmpty).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            showAdminSpeakerDetailsModal(
              context,
              userId: speaker.userId,
              initialSpeaker: speaker,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar, Name & Citizen Type Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            speaker.fullName.isNotEmpty ? speaker.fullName : 'Doctor',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (speaker.citizenType.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            _buildBadge('Citizen Type: ${speaker.citizenType}', const Color(0xFF0F766E), const Color(0xFFF0FDF4)),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Stacked Two-Row Details (Label on row 1, Value on row 2)
                _buildStackedField(label: 'Designation', value: speaker.designation, icon: Icons.work_outline_rounded),
                _buildStackedField(label: 'Hospital / Organisation', value: speaker.organisationName, icon: Icons.business_rounded),
                _buildStackedField(label: 'Qualification', value: speaker.qualification != 'NA' ? speaker.qualification : '', icon: Icons.school_outlined),
                _buildStackedField(label: 'Location', value: location, icon: Icons.location_on_outlined),
                _buildStackedField(label: 'Mobile', value: speaker.mobile, icon: Icons.phone_outlined),
                _buildStackedField(label: 'Email', value: speaker.email, icon: Icons.mail_outline_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: DELEGATES LIST
  // ==========================================
  Widget _buildDelegatesTab(AuthProvider auth, AdminProvider admin) {
    final filteredDelegates = admin.delegates.where((delegate) {
      if (_delegateFilterText.trim().isEmpty) return true;
      final q = _delegateFilterText.trim().toLowerCase();
      final matchName = delegate.fullName.toLowerCase().contains(q);
      final matchCity = delegate.city.toLowerCase().contains(q) || delegate.state.toLowerCase().contains(q);
      final matchOrg = delegate.organisationName.toLowerCase().contains(q);
      final matchDesig = delegate.designation.toLowerCase().contains(q);
      final matchQual = delegate.qualification.toLowerCase().contains(q);
      final matchCitizen = delegate.citizenType.toLowerCase().contains(q);
      return matchName || matchCity || matchOrg || matchDesig || matchQual || matchCitizen;
    }).toList();

    return Column(
      children: [
        _buildSearchBar(
          controller: _delegateSearchCtrl,
          hint: 'Search by name, city, hospital / organisation...',
          onChanged: (val) {
            setState(() => _delegateFilterText = val);
          },
          onSubmitted: (val) {
            setState(() => _delegateFilterText = val);
          },
          onClear: () {
            _delegateSearchCtrl.clear();
            setState(() => _delegateFilterText = '');
          },
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => admin.fetchDelegates(auth.accessToken, forceRefresh: true),
            color: const Color(0xFF4F46E5),
            child: admin.isLoadingDelegates && admin.delegates.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                : filteredDelegates.isEmpty
                    ? _buildEmptyState('No delegates found matching your search')
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        itemCount: filteredDelegates.length + (admin.delegatesPagination.hasNext && _delegateFilterText.isEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredDelegates.length) {
                            return _buildLoadMoreButton(
                              isLoading: admin.isLoadingMoreDelegates,
                              onPressed: () {
                                admin.fetchDelegates(auth.accessToken, loadMore: true);
                              },
                            );
                          }
                          final delegate = filteredDelegates[index];
                          return _buildDelegateCard(delegate);
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildDelegateCard(AdminDelegate delegate) {
    final initials = _getInitials(delegate.fullName);
    final location = [delegate.city, delegate.state].where((s) => s.isNotEmpty).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            showAdminDelegateDetailsModal(
              context,
              userId: delegate.userId,
              initialDelegate: delegate,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar, Name & Citizen Type Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            delegate.fullName.isNotEmpty ? delegate.fullName : 'Delegate',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (delegate.citizenType.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            _buildBadge('Citizen Type: ${delegate.citizenType}', const Color(0xFF0F766E), const Color(0xFFF0FDF4)),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Stacked Two-Row Details
                _buildStackedField(label: 'Designation', value: delegate.designation, icon: Icons.work_outline_rounded),
                _buildStackedField(label: 'Hospital / Organisation', value: delegate.organisationName, icon: Icons.business_rounded),
                _buildStackedField(label: 'Qualification', value: (delegate.qualification.isNotEmpty && delegate.qualification != 'NA') ? delegate.qualification : '', icon: Icons.school_outlined),
                _buildStackedField(label: 'Location', value: location, icon: Icons.location_on_outlined),
                _buildStackedField(label: 'Mobile', value: delegate.mobile, icon: Icons.phone_outlined),
                _buildStackedField(label: 'Email', value: delegate.email, icon: Icons.mail_outline_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 4: TOPICS LIST
  // ==========================================
  Widget _buildTopicFilterSegment(AuthProvider auth, AdminProvider admin) {
    final options = ['All', 'Slot Assigned', 'Slot Not Assigned'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: options.map((option) {
          final isSelected = _selectedTopicStatus == option;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTopicStatus = option;
                });
                final apiStatus = option == 'All'
                    ? null
                    : (option == 'Slot Assigned' ? 'confirmed' : 'approved');
                admin.fetchTopics(
                  auth.accessToken,
                  search: _topicSearchCtrl.text.isNotEmpty ? _topicSearchCtrl.text : null,
                  status: apiStatus,
                  forceRefresh: true,
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopicsTab(AuthProvider auth, AdminProvider admin) {
    final filteredTopics = admin.topics.where((topic) {
      if (_selectedTopicStatus != 'All') {
        final target = _selectedTopicStatus == 'Slot Assigned' ? 'confirmed' : 'approved';
        final s1 = topic.status.trim().toLowerCase();
        final s2 = topic.topicStatus.trim().toLowerCase();
        if (s1 != target && s2 != target && !s1.contains(target) && !s2.contains(target)) {
          return false;
        }
      }
      if (_topicFilterText.trim().isNotEmpty) {
        final q = _topicFilterText.trim().toLowerCase();
        final matchTitle = topic.title.toLowerCase().contains(q);
        final matchSpeaker = topic.speakerName.toLowerCase().contains(q);
        final matchCat = topic.categoryOfSubmission.toLowerCase().contains(q);
        if (!matchTitle && !matchSpeaker && !matchCat) return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        _buildSearchBar(
          controller: _topicSearchCtrl,
          hint: 'Search topics by title, speaker, category...',
          onChanged: (val) {
            setState(() => _topicFilterText = val);
          },
          onSubmitted: (val) {
            setState(() => _topicFilterText = val);
          },
          onClear: () {
            _topicSearchCtrl.clear();
            setState(() => _topicFilterText = '');
          },
        ),
        _buildTopicFilterSegment(auth, admin),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () {
              final apiStatus = _selectedTopicStatus == 'All'
                  ? null
                  : (_selectedTopicStatus == 'Slot Assigned' ? 'confirmed' : 'approved');
              return admin.fetchTopics(
                auth.accessToken,
                status: apiStatus,
                forceRefresh: true,
              );
            },
            color: const Color(0xFF4F46E5),
            child: admin.isLoadingTopics && admin.topics.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                : filteredTopics.isEmpty
                    ? _buildEmptyState('No topics found matching your search')
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        itemCount: filteredTopics.length + (admin.topicsPagination.hasNext && _topicFilterText.isEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredTopics.length) {
                            return _buildLoadMoreButton(
                              isLoading: admin.isLoadingMoreTopics,
                              onPressed: () {
                                admin.fetchTopics(auth.accessToken, loadMore: true);
                              },
                            );
                          }
                          final topic = filteredTopics[index];
                          return _buildTopicCard(topic, admin);
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicCard(AdminTopic topic, AdminProvider admin) {
    final bool isConfirmed = topic.status.toLowerCase() == 'confirmed';
    String displayStatus = topic.status;
    if (isConfirmed) {
      displayStatus = 'Slot Assigned';
    } else if (topic.status.toLowerCase() == 'approved') {
      displayStatus = 'Slot Not Assigned';
    }

    final scheduleInfo = admin.getTopicScheduleInfo(topic.topicId);
    final scheduleDate = topic.scheduleDate.isNotEmpty
        ? topic.scheduleDate
        : (scheduleInfo?['schedule_date'] ?? '');
    final scheduleDay = topic.scheduleDay.isNotEmpty
        ? topic.scheduleDay
        : (scheduleInfo?['schedule_day'] ?? '');
    final startTime = topic.startTime.isNotEmpty
        ? topic.startTime
        : (scheduleInfo?['start_time'] ?? '');
    final endTime = topic.endTime.isNotEmpty
        ? topic.endTime
        : (scheduleInfo?['end_time'] ?? '');
    final hallName = topic.hallLabel.isNotEmpty
        ? topic.hallLabel
        : (topic.hallName.isNotEmpty
            ? topic.hallName
            : (scheduleInfo?['hall_label'] ?? scheduleInfo?['hall_name'] ?? ''));

    final hasTimingInfo = isConfirmed || scheduleDate.isNotEmpty || startTime.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConfirmed ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
          width: isConfirmed ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            showAdminTopicDetailsModal(
              context,
              topicId: topic.topicId,
              initialTopic: topic,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Status Badge & View Details indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (topic.status.isNotEmpty)
                      _buildBadge(
                        displayStatus,
                        isConfirmed ? const Color(0xFF059669) : const Color(0xFFD97706),
                        isConfirmed ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                      )
                    else
                      const SizedBox.shrink(),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: Color(0xFF4F46E5),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Topic Title
                Text(
                  topic.title.isNotEmpty ? topic.title : 'Untitled Topic',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Stacked Details
                _buildStackedField(label: 'Speaker', value: topic.speakerName, icon: Icons.person_outline_rounded),
                _buildStackedField(label: 'Category', value: topic.categoryOfSubmission, icon: Icons.category_outlined),

                // Slot Assigned Date & Time Highlight Box
                if (hasTimingInfo && (scheduleDate.isNotEmpty || startTime.isNotEmpty || hallName.isNotEmpty)) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event_available_rounded, size: 14, color: Color(0xFF16A34A)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                [
                                  if (scheduleDate.isNotEmpty) scheduleDate,
                                  if (scheduleDay.isNotEmpty) 'Day $scheduleDay',
                                ].join('  •  '),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ),
                            if (startTime.isNotEmpty) ...[
                              const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF16A34A)),
                              const SizedBox(width: 4),
                              Text(
                                endTime.isNotEmpty ? '$startTime - $endTime' : startTime,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (hallName.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.meeting_room_rounded, size: 13, color: Color(0xFF16A34A)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  hallName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 5: WORKSHOPS LIST
  // ==========================================
  Widget _buildWorkshopsTab(AuthProvider auth, AdminProvider admin) {
    final filteredWorkshops = admin.workshops.where((ws) {
      if (_workshopFilterText.trim().isEmpty) return true;
      final q = _workshopFilterText.trim().toLowerCase();
      final matchName = ws.workshopName.toLowerCase().contains(q);
      final matchCode = ws.workshopCode.toLowerCase().contains(q);
      final matchVenue = ws.venueName.toLowerCase().contains(q);
      final matchCity = ws.city.toLowerCase().contains(q);
      final matchType = ws.workshopType.toLowerCase().contains(q);
      return matchName || matchCode || matchVenue || matchCity || matchType;
    }).toList();

    return Column(
      children: [
        _buildSearchBar(
          controller: _workshopSearchCtrl,
          hint: 'Search workshops by name, venue,code...',
          onChanged: (val) {
            setState(() => _workshopFilterText = val);
          },
          onSubmitted: (val) {
            setState(() => _workshopFilterText = val);
          },
          onClear: () {
            _workshopSearchCtrl.clear();
            setState(() => _workshopFilterText = '');
          },
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => admin.fetchWorkshops(auth.accessToken, forceRefresh: true),
            color: const Color(0xFF4F46E5),
            child: admin.isLoadingWorkshops && admin.workshops.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                : filteredWorkshops.isEmpty
                    ? _buildEmptyState('No workshops found matching your search')
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        itemCount: filteredWorkshops.length + (admin.workshopsPagination.hasNext && _workshopFilterText.isEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredWorkshops.length) {
                            return _buildLoadMoreButton(
                              isLoading: admin.isLoadingMoreWorkshops,
                              onPressed: () {
                                admin.fetchWorkshops(auth.accessToken, loadMore: true);
                              },
                            );
                          }
                          final workshop = filteredWorkshops[index];
                          return _buildWorkshopCard(workshop);
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkshopCard(AdminWorkshop ws) {
    final venueLocation = [ws.venueName, ws.city].where((s) => s.isNotEmpty).join(', ');
    final schedule = formatWorkshopSchedule(ws.workshopStart, ws.workshopEnd);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            showAdminWorkshopDetailsModal(
              context,
              workshopId: ws.workshopId,
              initialWorkshop: ws,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBadge(ws.workshopCode.isNotEmpty ? ws.workshopCode : 'WS', const Color(0xFF9333EA), const Color(0xFFFAF5FF)),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Participants',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9333EA),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: Color(0xFF9333EA),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ws.workshopName.isNotEmpty ? ws.workshopName : 'Untitled Workshop',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                _buildStackedField(label: 'Venue & Location', value: venueLocation, icon: Icons.location_city_rounded),
                _buildStackedField(label: 'Date & Schedule', value: schedule, icon: Icons.access_time_rounded),
                _buildStackedField(
                  label: 'Participants',
                  value: '${ws.speakersCount} Faculty / Speakers  •  ${ws.delegatesCount} Delegates',
                  icon: Icons.people_outline_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 6: EXHIBITORS LIST
  // ==========================================
  Widget _buildExhibitorCategoryFilter(AuthProvider auth, AdminProvider admin) {
    final categories = <String>['All'];
    for (final cat in admin.sponsorCategories) {
      if (cat.categoryName.isNotEmpty && !categories.contains(cat.categoryName)) {
        categories.add(cat.categoryName);
      }
    }
    for (final sp in admin.sponsors) {
      if (sp.sponsorCategory.isNotEmpty && !categories.contains(sp.sponsorCategory)) {
        categories.add(sp.sponsorCategory);
      }
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: categories.contains(_selectedExhibitorCategory) ? _selectedExhibitorCategory : 'All',
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            items: categories.map((cat) {
              return DropdownMenuItem<String>(
                value: cat,
                child: Row(
                  children: [
                    Icon(
                      cat == 'All' ? Icons.category_outlined : Icons.label_outline_rounded,
                      size: 15,
                      color: const Color(0xFFDB2777),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cat == 'All' ? 'All Categories (Exhibitors)' : cat,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (newVal) {
              if (newVal == null) return;
              setState(() {
                _selectedExhibitorCategory = newVal;
              });
              admin.fetchSponsors(
                auth.accessToken,
                search: _sponsorSearchCtrl.text.isNotEmpty ? _sponsorSearchCtrl.text : null,
                sponsorCategory: newVal == 'All' ? null : newVal,
                forceRefresh: true,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSponsorsTab(AuthProvider auth, AdminProvider admin) {
    final filteredSponsors = admin.sponsors.where((sp) {
      if (_selectedExhibitorCategory != 'All' && _selectedExhibitorCategory.isNotEmpty) {
        if (sp.sponsorCategory.toLowerCase() != _selectedExhibitorCategory.toLowerCase()) {
          return false;
        }
      }
      if (_sponsorFilterText.trim().isNotEmpty) {
        final q = _sponsorFilterText.trim().toLowerCase();
        final matchCompany = sp.companyName.toLowerCase().contains(q);
        final matchCategory = sp.sponsorCategory.toLowerCase().contains(q);
        final matchPerson = sp.contactPerson.toLowerCase().contains(q);
        final matchEmail = sp.email.toLowerCase().contains(q);
        final matchMobile = sp.mobile.toLowerCase().contains(q);
        if (!matchCompany && !matchCategory && !matchPerson && !matchEmail && !matchMobile) {
          return false;
        }
      }
      return true;
    }).toList();

    return Column(
      children: [
        _buildSearchBar(
          controller: _sponsorSearchCtrl,
          hint: 'Search exhibitors by company, contact',
          onChanged: (val) {
            setState(() => _sponsorFilterText = val);
          },
          onSubmitted: (val) {
            setState(() => _sponsorFilterText = val);
          },
          onClear: () {
            _sponsorSearchCtrl.clear();
            setState(() => _sponsorFilterText = '');
          },
        ),
        _buildExhibitorCategoryFilter(auth, admin),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => admin.fetchSponsors(
              auth.accessToken,
              sponsorCategory: _selectedExhibitorCategory == 'All' ? null : _selectedExhibitorCategory,
              forceRefresh: true,
            ),
            color: const Color(0xFFDB2777),
            child: admin.isLoadingSponsors && admin.sponsors.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFDB2777)))
                : filteredSponsors.isEmpty
                    ? _buildEmptyState('No exhibitors found matching your filter')
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        itemCount: filteredSponsors.length + (admin.sponsorsPagination.hasNext && _sponsorFilterText.isEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredSponsors.length) {
                            return _buildLoadMoreButton(
                              isLoading: admin.isLoadingMoreSponsors,
                              onPressed: () {
                                admin.fetchSponsors(
                                  auth.accessToken,
                                  sponsorCategory: _selectedExhibitorCategory == 'All' ? null : _selectedExhibitorCategory,
                                  loadMore: true,
                                );
                              },
                            );
                          }
                          final sponsor = filteredSponsors[index];
                          return _buildSponsorCard(sponsor);
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildSponsorCard(AdminSponsor sp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            showAdminExhibitorDetailsModal(
              context,
              exhibitorId: sp.sponsorId,
              initialExhibitor: sp,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF2F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        color: Color(0xFFDB2777),
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sp.companyName.isNotEmpty ? sp.companyName : 'Exhibitor',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (sp.sponsorCategory.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            _buildBadge(sp.sponsorCategory, const Color(0xFFDB2777), const Color(0xFFFDF2F8)),
                          ],
                        ],
                      ),
                    ),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFDB2777),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: Color(0xFFDB2777),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                _buildStackedField(label: 'Contact Person', value: sp.contactPerson, icon: Icons.person_outline_rounded),
                _buildStackedField(label: 'Mobile', value: sp.mobile, icon: Icons.phone_outlined),
                _buildStackedField(label: 'Email', value: sp.email, icon: Icons.mail_outline_rounded),
                if (sp.boothCount.isNotEmpty && sp.boothCount != '0')
                  _buildStackedField(label: 'Booths Allocated', value: '${sp.boothCount} Booth(s)', icon: Icons.meeting_room_outlined),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => _navigateToFootfallTab(sp.sponsorId),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFA7F3D0), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.query_stats_rounded, size: 13, color: Color(0xFF059669)),
                            SizedBox(width: 4),
                            Text(
                              'View Footfall',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 7: BOOTHS LIST (SLOTS-STYLE GRID UI)
  // ==========================================
  Widget _buildBoothFilterSegment() {
    final options = ['All', 'Allocated', 'Free'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: options.map((option) {
          final isSelected = _selectedBoothStatus == option;
          Color activeColor = const Color(0xFF4F46E5);
          if (option == 'Allocated') activeColor = const Color(0xFFD97706);
          if (option == 'Free') activeColor = const Color(0xFF65A30D);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedBoothStatus = option;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? activeColor : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBoothsTab(AuthProvider auth, AdminProvider admin) {
    final filteredBooths = admin.booths.where((booth) {
      final isAllocated = booth.isAssigned;

      if (_selectedBoothStatus == 'Allocated' && !isAllocated) return false;
      if (_selectedBoothStatus == 'Free' && isAllocated) return false;

      if (_boothFilterText.trim().isNotEmpty) {
        final q = _boothFilterText.trim().toLowerCase();
        final matchNumber = booth.boothNumber.toLowerCase().contains(q);
        final matchLabel = booth.boothLabel.toLowerCase().contains(q);
        final matchCompany = booth.companyName.toLowerCase().contains(q);
        final matchPerson = booth.contactPerson.toLowerCase().contains(q);
        final matchEmail = booth.email.toLowerCase().contains(q);
        final matchMobile = booth.mobile.toLowerCase().contains(q);
        if (!matchNumber && !matchLabel && !matchCompany && !matchPerson && !matchEmail && !matchMobile) {
          return false;
        }
      }
      return true;
    }).toList();

    final totalCount = filteredBooths.length;
    final allocatedCount = filteredBooths.where((b) => b.isAssigned).length;
    final freeCount = totalCount - allocatedCount;

    // Group booths by label / zone
    final Map<String, List<AdminBooth>> groupedBooths = {};
    for (final b in filteredBooths) {
      final groupKey = b.boothLabel.isNotEmpty ? b.boothLabel : 'Exhibition Hall';
      groupedBooths.putIfAbsent(groupKey, () => []).add(b);
    }

    return Column(
      children: [
        _buildSearchBar(
          controller: _boothSearchCtrl,
          hint: 'Search booths by number, label, exhibitor...',
          onChanged: (val) {
            setState(() => _boothFilterText = val);
          },
          onSubmitted: (val) {
            setState(() => _boothFilterText = val);
          },
          onClear: () {
            _boothSearchCtrl.clear();
            setState(() => _boothFilterText = '');
          },
        ),
        _buildBoothFilterSegment(),
        // Summary Counter Bar
        if (admin.booths.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
            child: Row(
              children: [
                Text(
                  '$totalCount TOTAL BOOTHS',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF65A30D),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$freeCount Free',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF4D8F14), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD97706),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$allocatedCount Allocated',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => admin.fetchBooths(auth.accessToken, forceRefresh: true),
            color: const Color(0xFF4F46E5),
            child: admin.isLoadingBooths && admin.booths.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                : filteredBooths.isEmpty
                    ? _buildEmptyState('No booths found matching your filters')
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        children: [
                          ...groupedBooths.entries.map((entry) {
                            final groupTitle = entry.key;
                            final boothsInGroup = entry.value;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFBFD),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFEEF2F6), width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.storefront_rounded,
                                        size: 17,
                                        color: Color(0xFF4F46E5),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          groupTitle,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4338CA),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${boothsInGroup.length} Booths',
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4F46E5),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                                  const SizedBox(height: 12),

                                  // Booths Grid Wrap
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final double itemWidth = constraints.maxWidth > 500
                                          ? (constraints.maxWidth - (8 * 3)) / 4
                                          : (constraints.maxWidth - (8 * 2)) / 3;

                                      return Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: boothsInGroup
                                            .map((b) => _buildBoothGridBox(b, itemWidth))
                                            .toList(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (admin.boothsPagination.hasNext && _boothFilterText.isEmpty)
                            _buildLoadMoreButton(
                              isLoading: admin.isLoadingMoreBooths,
                              onPressed: () {
                                admin.fetchBooths(auth.accessToken, loadMore: true);
                              },
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildBoothGridBox(AdminBooth booth, double itemWidth) {
    final isAllocated = booth.isAssigned;
    final boothTitle = booth.boothNumber.isNotEmpty
        ? booth.boothNumber
        : (booth.boothLabel.isNotEmpty ? booth.boothLabel : 'Booth');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showAdminBoothDetailsModal(
            context,
            boothId: booth.boothId,
            initialBooth: booth,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: itemWidth,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isAllocated ? const Color(0xFFFFFBEB) : const Color(0xFFF1FCE8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAllocated ? const Color(0xFFFDE68A) : const Color(0xFF84CC16),
              width: 1.1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                boothTitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isAllocated ? const Color(0xFF92400E) : const Color(0xFF2E6B08),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isAllocated && booth.companyName.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  booth.companyName,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF78350F),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 3),
              Text(
                isAllocated ? 'ALLOCATED' : 'FREE',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: isAllocated ? const Color(0xFFD97706) : const Color(0xFF4D8F14),
                  letterSpacing: 0.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 8: EXHIBITOR BOOTH FOOTFALL & PARTICIPANTS
  // ==========================================
  Widget _buildFootfallTab(AuthProvider auth, AdminProvider admin) {
    if (admin.sponsors.isEmpty && !admin.isLoadingSponsors) {
      return RefreshIndicator(
        onRefresh: () => admin.fetchSponsors(auth.accessToken, forceRefresh: true),
        color: const Color(0xFF059669),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Container(
            height: 400,
            alignment: Alignment.center,
            child: _buildEmptyState('No exhibitors found for footfall tracking.'),
          ),
        ),
      );
    }

    // Auto-select first sponsor if not set
    if ((_selectedFootfallSponsorId == null || _selectedFootfallSponsorId!.isEmpty) &&
        admin.sponsors.isNotEmpty) {
      _selectedFootfallSponsorId = admin.sponsors.first.sponsorId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadFootfallData();
      });
    }

    // Current selected sponsor
    AdminSponsor? currentSponsor;
    for (final sp in admin.sponsors) {
      if (sp.sponsorId == _selectedFootfallSponsorId) {
        currentSponsor = sp;
        break;
      }
    }
    currentSponsor ??= admin.sponsors.isNotEmpty ? admin.sponsors.first : null;

    final summary = _footfallStatsData?.summary ?? const AdminSponsorBoothSummary();
    final boothsList = _footfallStatsData?.booths ?? [];

    // Filter participants based on search text
    final filteredParticipants = _footfallParticipants.where((p) {
      if (_footfallFilterText.trim().isNotEmpty) {
        final q = _footfallFilterText.trim().toLowerCase();
        final matchName = p.name.toLowerCase().contains(q);
        final matchOrg = p.organisation.toLowerCase().contains(q);
        final matchDesig = p.designation.toLowerCase().contains(q);
        final matchCity = p.city.toLowerCase().contains(q);
        final matchMobile = p.mobile.toLowerCase().contains(q);
        final matchEmail = p.email.toLowerCase().contains(q);
        final matchRole = p.roleLabel.toLowerCase().contains(q) || p.role.toLowerCase().contains(q);
        final matchBooth = p.boothNumber.toLowerCase().contains(q) || p.boothLabel.toLowerCase().contains(q);
        if (!matchName && !matchOrg && !matchDesig && !matchCity && !matchMobile && !matchEmail && !matchRole && !matchBooth) {
          return false;
        }
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Sponsor selector & filter bar
        _buildFootfallHeaderBar(auth, admin, currentSponsor, boothsList),

        // Participant search bar
        _buildSearchBar(
          controller: _footfallSearchCtrl,
          hint: 'Search attendee by name, mobile, role...',
          onChanged: (val) {
            setState(() => _footfallFilterText = val);
          },
          onSubmitted: (val) {
            setState(() => _footfallFilterText = val);
          },
          onClear: () {
            _footfallSearchCtrl.clear();
            setState(() => _footfallFilterText = '');
          },
        ),

        // Main Footfall Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadFootfallData(reset: true),
            color: const Color(0xFF059669),
            child: _isLoadingFootfall && _footfallStatsData == null
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF059669)))
                : _footfallError != null && _footfallStatsData == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 40, color: Color(0xFFEF4444)),
                              const SizedBox(height: 12),
                              Text(
                                _footfallError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _loadFootfallData(reset: true),
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text('Try Again'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF059669),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      // 3 Summary Stats Cards
                      _buildFootfallStatsGrid(summary),
                      const SizedBox(height: 14),

                      // Booth Breakdown (if multiple or available)
                      if (boothsList.isNotEmpty) ...[
                        _buildBoothsFootfallBreakdown(boothsList),
                        const SizedBox(height: 14),
                      ],

                      // Attendees Header Bar
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.people_alt_rounded,
                              size: 14,
                              color: Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ATTENDEE VISITS (${filteredParticipants.length})',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                              color: Color(0xFF047857),
                            ),
                          ),
                          const Spacer(),
                          // Download Report Button
                          if (filteredParticipants.isNotEmpty) ...[
                            InkWell(
                              onTap: () {
                                final total = filteredParticipants.length;
                                final speakers = filteredParticipants
                                    .where((p) => p.role.toUpperCase() == 'SK' || p.roleLabel.toLowerCase().contains('speaker'))
                                    .length;
                                final delegates = total - speakers;

                                FootfallReportService.showDownloadReportModal(
                                  context: context,
                                  totalCount: total,
                                  speakersCount: speakers,
                                  delegatesCount: delegates,
                                  onDownload: (filter) async {
                                    await FootfallReportService.downloadAdminFootfallReport(
                                      context: context,
                                      participants: filteredParticipants,
                                      filter: filter,
                                      sponsorName: currentSponsor?.companyName,
                                    );
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFA7F3D0)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.file_download_outlined, size: 13, color: Color(0xFF059669)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Report',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF047857),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (_footfallPagination.totalRecords > 0)
                            Text(
                              'Total: ${_footfallPagination.totalRecords}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // List of Participants
                      if (filteredParticipants.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: _buildEmptyState(
                            _footfallFilterText.isNotEmpty
                                ? 'No attendee visits match your search'
                                : 'No attendee footfall logged yet for this filter.',
                          ),
                        )
                      else
                        ...filteredParticipants.map((p) => _buildFootfallParticipantCard(p)),

                      // Load More Button
                      if (_footfallPagination.hasNext && _footfallFilterText.isEmpty)
                        _buildLoadMoreButton(
                          isLoading: _isLoadingMoreParticipants,
                          onPressed: () => _loadFootfallData(loadMore: true),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFootfallHeaderBar(
    AuthProvider auth,
    AdminProvider admin,
    AdminSponsor? currentSponsor,
    List<AdminSponsorBoothStatItem> boothsList,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Column(
        children: [
          // Exhibitor Selector Card
          InkWell(
            onTap: () => _showSponsorPickerSheet(context, admin),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.business_rounded, color: Color(0xFF059669), size: 17),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SELECT EXHIBITOR',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          currentSponsor?.companyName.isNotEmpty == true
                              ? currentSponsor!.companyName
                              : 'Select an Exhibitor',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.unfold_more_rounded, color: Color(0xFF64748B), size: 19),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Sub-filters: Booths filter & Date picker
          Row(
            children: [
              // Booth Dropdown Filter
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedFootfallBoothId,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: 'All',
                          child: Text('All Booths'),
                        ),
                        ...boothsList.map((b) {
                          final label = b.boothLabel.isNotEmpty
                              ? '${b.boothLabel}${b.boothNumber.isNotEmpty ? " (${b.boothNumber})" : ""}'
                              : (b.boothNumber.isNotEmpty ? b.boothNumber : 'Booth ${b.boothId}');
                          return DropdownMenuItem<String>(
                            value: b.boothId,
                            child: Text(label, overflow: TextOverflow.ellipsis),
                          );
                        }),
                      ],
                      onChanged: (newBooth) {
                        if (newBooth == null) return;
                        setState(() {
                          _selectedFootfallBoothId = newBooth;
                        });
                        _loadFootfallData(reset: true);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Date Filter Button
              InkWell(
                onTap: () => _pickFootfallDate(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedFootfallDate != null ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedFootfallDate != null ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: _selectedFootfallDate != null ? const Color(0xFF059669) : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _selectedFootfallDate != null ? TimeFormatter.formatDate(_selectedFootfallDate!) : 'All Dates',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _selectedFootfallDate != null ? const Color(0xFF047857) : const Color(0xFF64748B),
                        ),
                      ),
                      if (_selectedFootfallDate != null) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFootfallDate = null;
                            });
                            _loadFootfallData(reset: true);
                          },
                          child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF059669)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickFootfallDate(BuildContext context) async {
    final DateTime initialDate = _selectedFootfallDate != null
        ? DateTime.tryParse(_selectedFootfallDate!) ?? DateTime.now()
        : DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2028, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF059669),
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _selectedFootfallDate = formatted;
      });
      _loadFootfallData(reset: true);
    }
  }

  void _showSponsorPickerSheet(BuildContext context, AdminProvider admin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = admin.sponsors.where((s) {
              if (searchQuery.trim().isEmpty) return true;
              final q = searchQuery.trim().toLowerCase();
              return s.companyName.toLowerCase().contains(q) ||
                  s.contactPerson.toLowerCase().contains(q) ||
                  s.sponsorCategory.toLowerCase().contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Exhibitor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: TextField(
                      onChanged: (val) {
                        setModalState(() => searchQuery = val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by company or category...',
                        hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final sp = filtered[index];
                        final isSelected = sp.sponsorId == _selectedFootfallSponsorId;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF059669) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.business_rounded,
                              size: 18,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                          title: Text(
                            sp.companyName,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? const Color(0xFF047857) : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: sp.sponsorCategory.isNotEmpty
                              ? Text(
                                  sp.sponsorCategory,
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                )
                              : null,
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20)
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _selectedFootfallSponsorId = sp.sponsorId;
                              _selectedFootfallBoothId = 'All';
                            });
                            _loadFootfallData(reset: true);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFootfallStatsGrid(AdminSponsorBoothSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _buildFootfallMetricCard(
            icon: Icons.storefront_rounded,
            iconColor: const Color(0xFF4F46E5),
            iconBg: const Color(0xFFEEF2FF),
            label: 'TOTAL BOOTHS',
            value: '${summary.totalBooths}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFootfallMetricCard(
            icon: Icons.remove_red_eye_rounded,
            iconColor: const Color(0xFF0284C7),
            iconBg: const Color(0xFFF0F9FF),
            label: 'TOTAL VISITS',
            value: '${summary.totalVisits}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFootfallMetricCard(
            icon: Icons.people_alt_rounded,
            iconColor: const Color(0xFF059669),
            iconBg: const Color(0xFFECFDF5),
            label: 'UNIQUE VISITORS',
            value: '${summary.uniqueVisitors}',
          ),
        ),
      ],
    );
  }

  Widget _buildFootfallMetricCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
              color: Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBoothsFootfallBreakdown(List<AdminSponsorBoothStatItem> booths) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.meeting_room_rounded, size: 14, color: Color(0xFF4F46E5)),
              SizedBox(width: 6),
              Text(
                'BOOTHS BREAKDOWN',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: booths.map((b) {
              final isSelected = _selectedFootfallBoothId == b.boothId;
              final primaryTitle = b.boothLabel.isNotEmpty
                  ? b.boothLabel
                  : (b.boothNumber.isNotEmpty ? b.boothNumber : 'Booth ${b.boothId}');
              final secondaryTitle = (b.boothLabel.isNotEmpty && b.boothNumber.isNotEmpty)
                  ? b.boothNumber
                  : '';

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedFootfallBoothId = isSelected ? 'All' : b.boothId;
                  });
                  _loadFootfallData(reset: true);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        primaryTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFF4338CA) : AppColors.textPrimary,
                        ),
                      ),
                      if (secondaryTitle.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          '($secondaryTitle)',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        ),
                      ],
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${b.totalVisits} visits',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFootfallParticipantCard(AdminFootfallParticipant p) {
    // Resolve booth label if missing from stats list
    String boothLabel = p.boothLabel;
    String boothNumber = p.boothNumber;
    if (boothLabel.isEmpty && _footfallStatsData != null) {
      for (final b in _footfallStatsData!.booths) {
        if ((p.boothId.isNotEmpty && b.boothId == p.boothId) ||
            (p.boothNumber.isNotEmpty && b.boothNumber.toLowerCase() == p.boothNumber.toLowerCase())) {
          if (b.boothLabel.isNotEmpty) {
            boothLabel = b.boothLabel;
          }
          if (boothNumber.isEmpty && b.boothNumber.isNotEmpty) {
            boothNumber = b.boothNumber;
          }
          break;
        }
      }
    }

    final enrichedParticipant = (p.boothLabel.isEmpty && boothLabel.isNotEmpty)
        ? AdminFootfallParticipant(
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
            boothNumber: boothNumber,
            boothLabel: boothLabel,
            visitedDate: p.visitedDate,
            visitedTime: p.visitedTime,
            visitCount: p.visitCount,
          )
        : p;

    final initials = p.name.trim().isNotEmpty
        ? (p.name.trim().split(RegExp(r'\s+')).length > 1
            ? '${p.name.trim().split(RegExp(r'\s+'))[0][0]}${p.name.trim().split(RegExp(r'\s+'))[1][0]}'.toUpperCase()
            : p.name.trim()[0].toUpperCase())
        : 'DR';

    final isSpeaker = p.role.toUpperCase() == 'SK' || p.roleLabel.toLowerCase().contains('speaker');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => showAdminFootfallParticipantDetailModal(context, participant: enrichedParticipant),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSpeaker
                              ? [const Color(0xFF7C3AED), const Color(0xFF9333EA)]
                              : [const Color(0xFF0D9488), const Color(0xFF059669)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  p.name.isNotEmpty ? p.name : 'Attendee',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSpeaker ? const Color(0xFFF3E8FF) : const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSpeaker ? const Color(0xFFD8B4FE) : const Color(0xFFA7F3D0),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  p.roleLabel.isNotEmpty ? p.roleLabel : (isSpeaker ? 'Speaker' : 'Delegate'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isSpeaker ? const Color(0xFF7E22CE) : const Color(0xFF047857),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (p.designation.isNotEmpty || p.organisation.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              [p.designation, p.organisation]
                                  .where((s) => s.isNotEmpty && s != 'NA')
                                  .join(' • '),
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),

                // Visit details footer
                Row(
                  children: [
                    if (boothLabel.isNotEmpty || boothNumber.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBAE6FD), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.meeting_room_outlined, size: 11, color: Color(0xFF0284C7)),
                            const SizedBox(width: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: boothLabel.isNotEmpty ? boothLabel : boothNumber,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ),
                                  if (boothLabel.isNotEmpty && boothNumber.isNotEmpty)
                                    TextSpan(
                                      text: ' ($boothNumber)',
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF0369A1),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (p.visitedDate.isNotEmpty || p.visitedTime.isNotEmpty) ...[
                      const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        '${TimeFormatter.formatDate(p.visitedDate)} ${TimeFormatter.formatTime(p.visitedTime)}',
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                    const Spacer(),
                    if (p.visitCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${p.visitCount} ${p.visitCount == 1 ? "visit" : "visits"}',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SHARED UTILITY WIDGETS
  // ==========================================

  Widget _buildSearchBar({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onSubmitted,
    required VoidCallback onClear,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF64748B)),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _buildStackedField({
    required String label,
    required String value,
    IconData? icon,
  }) {
    if (value.trim().isEmpty || value.trim() == 'NA' || value.trim() == 'null') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: const Color(0xFF64748B)),
                const SizedBox(width: 4),
              ],
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2.5),
          Text(
            value.trim(),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 26, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton({required bool isLoading, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF4F46E5)),
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFC7D2FE)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  'Load More Records',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
      ),
    );
  }
}
