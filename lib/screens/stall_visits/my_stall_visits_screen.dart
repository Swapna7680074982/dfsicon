import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../domain/utility_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/explore_provider.dart';
import '../../utils/time_formatter.dart';
import '../../widgets/water_droplets_background.dart';
import '../exhibitor/exhibitor_details_screen.dart';

class MyStallVisitsScreen extends StatefulWidget {
  const MyStallVisitsScreen({super.key});

  @override
  State<MyStallVisitsScreen> createState() => _MyStallVisitsScreenState();
}

class _MyStallVisitsScreenState extends State<MyStallVisitsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVisits(forceRefresh: false);
    });
  }

  Future<void> _loadVisits({bool forceRefresh = false}) async {
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final exploreProvider = Provider.of<ExploreProvider>(context, listen: false);

    final String summitId = homeProvider.summits.isNotEmpty
        ? homeProvider.summits.first['summit_id']?.toString() ?? '1'
        : '1';

    await Future.wait([
      homeProvider.fetchMyStallVisits(auth.accessToken, forceRefresh: forceRefresh),
      if (exploreProvider.exhibitors.isEmpty) ...[
        exploreProvider.fetchSponsors(summitId, auth.accessToken),
        exploreProvider.fetchSummitBooths(summitId, auth.accessToken),
      ],
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'EX';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0].isNotEmpty && parts[1].isNotEmpty)
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'EX';
  }

  void _navigateToExhibitor(DelegateStallVisit visit) {
    final exploreProvider = Provider.of<ExploreProvider>(context, listen: false);
    Exhibitor? matchedEx;
    try {
      matchedEx = exploreProvider.exhibitors.firstWhere(
        (ex) =>
            (visit.companyName.isNotEmpty && ex.name.toLowerCase() == visit.companyName.toLowerCase()) ||
            (visit.boothNumber.isNotEmpty && ex.boothCode.toLowerCase().contains(visit.boothNumber.toLowerCase())),
      );
    } catch (_) {}

    if (matchedEx != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExhibitorDetailsScreen(exhibitor: matchedEx!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final allVisits = homeProvider.myStallVisits;
    final isLoading = homeProvider.isFetchingStallVisits;

    final filteredVisits = allVisits.where((v) {
      final query = _searchQuery.toLowerCase().trim();
      if (query.isEmpty) return true;
      final name = v.companyName.toLowerCase();
      final label = v.boothLabel.toLowerCase();
      final number = v.boothNumber.toLowerCase();
      final contact = v.contactPerson.toLowerCase();
      final email = v.email.toLowerCase();
      final mobile = v.mobile.toLowerCase();
      return name.contains(query) ||
          label.contains(query) ||
          number.contains(query) ||
          contact.contains(query) ||
          email.contains(query) ||
          mobile.contains(query);
    }).toList();

    return WaterDropletsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A1E3D), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'My Booth Visits',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
              onPressed: () => _loadVisits(forceRefresh: true),
              tooltip: 'Refresh Visits',
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => _loadVisits(forceRefresh: true),
          color: AppColors.primary,
          child: Column(
            children: [
              // Search Bar Header
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.tileBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search visited booths, companies, contacts...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textLight),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textLight),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),

              // Content List
              Expanded(
                child: isLoading && allVisits.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    : filteredVisits.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.storefront_outlined,
                                      size: 36,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'No booths match "$_searchQuery"'
                                        : 'No booth visits recorded yet',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Try searching with a different keyword or booth number'
                                        : 'Visit exhibitor booths and get your delegate QR badge scanned to track your footfall!',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            physics: const BouncingScrollPhysics(),
                            itemCount: filteredVisits.length,
                            itemBuilder: (context, index) {
                              final v = filteredVisits[index];
                              final String stallTag = v.boothLabel.isNotEmpty
                                  ? (v.boothLabel.toUpperCase().startsWith('BOOTH')
                                      ? v.boothLabel
                                      : 'BOOTH ${v.boothLabel}')
                                  : (v.boothNumber.isNotEmpty ? v.boothNumber : 'Booth #${v.boothId}');
                              final String formattedTime = v.lastVisitedAt.isNotEmpty
                                  ? TimeFormatter.formatString(v.lastVisitedAt)
                                  : '';

                              final List<Map<String, dynamic>> cardThemes = [
                                {
                                  'avatarBg': const Color(0xFFEEF2FF),
                                  'avatarBorder': const Color(0xFFC7D2FE),
                                  'avatarText': const Color(0xFF4338CA),
                                  'boothBg': const Color(0xFFEEF2FF),
                                  'boothBorder': const Color(0xFFC7D2FE),
                                  'boothText': const Color(0xFF4338CA),
                                  'boothIcon': const Color(0xFF4F46E5),
                                  'chevronBg': const Color(0xFFEEF2FF),
                                  'chevronColor': const Color(0xFF4F46E5),
                                },
                                {
                                  'avatarBg': const Color(0xFFECFDF5),
                                  'avatarBorder': const Color(0xFFA7F3D0),
                                  'avatarText': const Color(0xFF047857),
                                  'boothBg': const Color(0xFFECFDF5),
                                  'boothBorder': const Color(0xFFA7F3D0),
                                  'boothText': const Color(0xFF047857),
                                  'boothIcon': const Color(0xFF059669),
                                  'chevronBg': const Color(0xFFECFDF5),
                                  'chevronColor': const Color(0xFF059669),
                                },
                                {
                                  'avatarBg': const Color(0xFFFAF5FF),
                                  'avatarBorder': const Color(0xFFE9D5FF),
                                  'avatarText': const Color(0xFF6D28D9),
                                  'boothBg': const Color(0xFFFAF5FF),
                                  'boothBorder': const Color(0xFFE9D5FF),
                                  'boothText': const Color(0xFF6D28D9),
                                  'boothIcon': const Color(0xFF7C3AED),
                                  'chevronBg': const Color(0xFFFAF5FF),
                                  'chevronColor': const Color(0xFF7C3AED),
                                },
                                {
                                  'avatarBg': const Color(0xFFFFFBEB),
                                  'avatarBorder': const Color(0xFFFDE68A),
                                  'avatarText': const Color(0xFFB45309),
                                  'boothBg': const Color(0xFFFFFBEB),
                                  'boothBorder': const Color(0xFFFDE68A),
                                  'boothText': const Color(0xFFB45309),
                                  'boothIcon': const Color(0xFFD97706),
                                  'chevronBg': const Color(0xFFFFFBEB),
                                  'chevronColor': const Color(0xFFD97706),
                                },
                                {
                                  'avatarBg': const Color(0xFFF0F9FF),
                                  'avatarBorder': const Color(0xFFBAE6FD),
                                  'avatarText': const Color(0xFF0369A1),
                                  'boothBg': const Color(0xFFF0F9FF),
                                  'boothBorder': const Color(0xFFBAE6FD),
                                  'boothText': const Color(0xFF0369A1),
                                  'boothIcon': const Color(0xFF0284C7),
                                  'chevronBg': const Color(0xFFF0F9FF),
                                  'chevronColor': const Color(0xFF0284C7),
                                },
                                {
                                  'avatarBg': const Color(0xFFFDF2F8),
                                  'avatarBorder': const Color(0xFFFBCFE8),
                                  'avatarText': const Color(0xFFBE185D),
                                  'boothBg': const Color(0xFFFDF2F8),
                                  'boothBorder': const Color(0xFFFBCFE8),
                                  'boothText': const Color(0xFFBE185D),
                                  'boothIcon': const Color(0xFFDB2777),
                                  'chevronBg': const Color(0xFFFDF2F8),
                                  'chevronColor': const Color(0xFFDB2777),
                                },
                              ];
                              final t = cardThemes[index % cardThemes.length];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => _navigateToExhibitor(v),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Logo / Initials Container
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: t['avatarBg'] as Color,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: t['avatarBorder'] as Color, width: 1.0),
                                            ),
                                            alignment: Alignment.center,
                                            child: v.fullLogoUrl.isNotEmpty
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(11),
                                                    child: Image.network(
                                                      v.fullLogoUrl,
                                                      width: 44,
                                                      height: 44,
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (_, __, ___) => Text(
                                                        _getInitials(v.companyName),
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w800,
                                                          color: t['avatarText'] as Color,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Text(
                                                    _getInitials(v.companyName),
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w800,
                                                      color: t['avatarText'] as Color,
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Details Column
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  v.companyName.isNotEmpty ? v.companyName : 'Exhibitor',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF0F172A),
                                                    letterSpacing: -0.2,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (v.contactPerson.isNotEmpty) ...[
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.person_outline_rounded,
                                                        size: 13,
                                                        color: Color(0xFF64748B),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          'Contact: ${v.contactPerson}${v.mobile.isNotEmpty ? " (${v.mobile})" : ""}',
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w500,
                                                            color: Color(0xFF475569),
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                                      decoration: BoxDecoration(
                                                        color: t['boothBg'] as Color,
                                                        borderRadius: BorderRadius.circular(6),
                                                        border: Border.all(color: t['boothBorder'] as Color),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.storefront_rounded,
                                                            size: 11,
                                                            color: t['boothIcon'] as Color,
                                                          ),
                                                          const SizedBox(width: 3.5),
                                                          Text(
                                                            stallTag,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.w600,
                                                              color: t['boothText'] as Color,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (v.boothNumber.isNotEmpty && v.boothNumber != v.boothLabel) ...[
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        '# ${v.boothNumber}',
                                                        style: const TextStyle(
                                                          fontSize: 10.5,
                                                          color: Color(0xFF94A3B8),
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                if (formattedTime.isNotEmpty) ...[
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.schedule_rounded,
                                                        size: 12,
                                                        color: Color(0xFF94A3B8),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          'Last visited: $formattedTime',
                                                          style: const TextStyle(
                                                            fontSize: 10.5,
                                                            color: Color(0xFF64748B),
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                if (v.email.isNotEmpty) ...[
                                                  const SizedBox(height: 3),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.mail_outline_rounded,
                                                        size: 12,
                                                        color: Color(0xFF94A3B8),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          v.email,
                                                          style: const TextStyle(
                                                            fontSize: 10.5,
                                                            color: Color(0xFF64748B),
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            margin: const EdgeInsets.only(top: 8),
                                            width: 26,
                                            height: 26,
                                            decoration: BoxDecoration(
                                              color: t['chevronBg'] as Color,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.chevron_right_rounded,
                                              size: 17,
                                              color: t['chevronColor'] as Color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
