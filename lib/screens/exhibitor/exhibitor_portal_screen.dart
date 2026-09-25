import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/sessions_provider.dart';
import '../../providers/home_provider.dart';
import '../calendar/event_calendar_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_detail_sheets.dart';

class ExhibitorPortalScreen extends StatefulWidget {
  final int initialTabIndex;

  const ExhibitorPortalScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<ExhibitorPortalScreen> createState() => _ExhibitorPortalScreenState();
}

class _ExhibitorPortalScreenState extends State<ExhibitorPortalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Search Controllers
  final TextEditingController _speakerSearchCtrl = TextEditingController();
  final TextEditingController _delegateSearchCtrl = TextEditingController();
  final TextEditingController _sponsorSearchCtrl = TextEditingController();

  Timer? _debounceTimer;
  String _speakerFilterText = '';
  String _delegateFilterText = '';
  String _sponsorFilterText = '';
  String _selectedExhibitorCategory = 'All';

  int _lastTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 3),
    );
    _lastTabIndex = _tabController.index;
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllExhibitorData();
    });
  }

  void _handleTabChange() {
    if (_tabController.index != _lastTabIndex) {
      _lastTabIndex = _tabController.index;
      _clearAllSearches();
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
    if (_sponsorSearchCtrl.text.isNotEmpty || _sponsorFilterText.isNotEmpty) {
      _sponsorSearchCtrl.clear();
      _sponsorFilterText = '';
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
    _sponsorSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAllExhibitorData({bool forceRefresh = false}) async {
    if (!mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final admin = Provider.of<AdminProvider>(context, listen: false);
    final sessions = Provider.of<SessionsProvider>(context, listen: false);
    final home = Provider.of<HomeProvider>(context, listen: false);

    final token = auth.accessToken;
    if (token.isEmpty) return;

    try {
      final futures = <Future>[];

      // Fetch Summits
      if (home.summits.isEmpty || forceRefresh) {
        futures.add(home.fetchSummits(token));
      }

      // Fetch Sessions Agenda
      futures.add(sessions.fetchConfirmedSessions(token, forceRefresh: forceRefresh));

      // Fetch Speakers (Admin API)
      futures.add(admin.fetchSpeakers(token, forceRefresh: forceRefresh));

      // Fetch Delegates (Admin API)
      futures.add(admin.fetchDelegates(token, forceRefresh: forceRefresh));

      // Fetch Sponsors & Categories (Admin API)
      futures.add(admin.fetchSponsors(token, forceRefresh: forceRefresh));
      futures.add(admin.fetchSponsorCategories(token, forceRefresh: forceRefresh));

      final String summitId = home.summits.isNotEmpty
          ? home.summits.first['summit_id']?.toString() ?? '1'
          : '1';

      futures.add(sessions.fetchVenueAndHalls(summitId, token));
      futures.add(sessions.fetchVenueLayouts(token, summitId: summitId));

      await Future.wait(futures);
    } catch (e) {
      debugPrint('⚠️ [ExhibitorPortal] Error loading data: $e');
    }
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'EX';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'EX';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final admin = Provider.of<AdminProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset(
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
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF2F8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFBCFE8), width: 0.8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storefront_rounded,
                  size: 13,
                  color: Color(0xFFDB2777),
                ),
                SizedBox(width: 4),
                Text(
                  'EXHIBITOR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDB2777),
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
                  color: const Color(0xFFDB2777).withValues(alpha: 0.1),
                  border: Border.all(
                    color: const Color(0xFFFBCFE8),
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
                            _getInitials(auth.userName),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDB2777),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        _getInitials(auth.userName),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDB2777),
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
              tabs: const [
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Full Agenda'),
                    ],
                  ),
                ),
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.record_voice_over_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Speakers'),
                    ],
                  ),
                ),
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_alt_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Delegates'),
                    ],
                  ),
                ),
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.storefront_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Exhibitors'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Full Agenda (Master Schedule Calendar View)
          const EventCalendarScreen(
            role: CalendarRole.exhibitor,
            hideAppBar: true,
          ),

          // 2. Speakers Tab (Admin UI)
          _buildSpeakersTab(auth, admin),

          // 3. Delegates Tab (Admin UI)
          _buildDelegatesTab(auth, admin),

          // 4. Exhibitors Tab (Admin UI)
          _buildSponsorsTab(auth, admin),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: SPEAKERS LIST (ADMIN UI)
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

                // Stacked Details
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
  // TAB 3: DELEGATES LIST (ADMIN UI)
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

                // Stacked Details
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
  // TAB 4: EXHIBITORS LIST (ADMIN UI)
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SHARED UTILITY WIDGETS (ADMIN STYLE)
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
