import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/explore_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import 'exhibitor_details_screen.dart';
import '../../widgets/water_droplets_background.dart';

class ExhibitorsListScreen extends StatefulWidget {
  const ExhibitorsListScreen({super.key});

  @override
  State<ExhibitorsListScreen> createState() => _ExhibitorsListScreenState();
}

class _ExhibitorsListScreenState extends State<ExhibitorsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData({bool force = false}) async {
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final explore = Provider.of<ExploreProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final String summitId = homeProvider.summits.isNotEmpty
        ? homeProvider.summits.first['summit_id']?.toString() ?? '1'
        : '1';
    
    final futures = <Future>[];
    if (force || explore.exhibitors.isEmpty) {
      futures.add(explore.fetchSponsors(summitId, auth.accessToken));
    }
    if (force || explore.summitBooths.isEmpty) {
      futures.add(explore.fetchSummitBooths(summitId, auth.accessToken));
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static final List<Map<String, Color>> _lightPalettes = [
    {
      'bg': Color(0xFFF1F5F9), // Light Slate
      'border': Color(0xFFCBD5E1),
      'text': Color(0xFF334155),
    },
    {
      'bg': Color(0xFFEEF2FF), // Light Indigo
      'border': Color(0xFFC7D2FE),
      'text': Color(0xFF4338CA),
    },
    {
      'bg': Color(0xFFF5F3FF), // Light Purple
      'border': Color(0xFFDDD6FE),
      'text': Color(0xFF6D28D9),
    },
    {
      'bg': Color(0xFFECFDF5), // Light Emerald
      'border': Color(0xFFA7F3D0),
      'text': Color(0xFF047857),
    },
    {
      'bg': Color(0xFFFFFBEB), // Light Amber
      'border': Color(0xFFFDE68A),
      'text': Color(0xFFB45309),
    },
    {
      'bg': Color(0xFFFFF1F2), // Light Rose
      'border': Color(0xFFFECDD3),
      'text': Color(0xFFBE123C),
    },
    {
      'bg': Color(0xFFF0FDF4), // Light Green
      'border': Color(0xFFBBF7D0),
      'text': Color(0xFF15803D),
    },
    {
      'bg': Color(0xFFF0F9FF), // Light Sky
      'border': Color(0xFFBAE6FD),
      'text': Color(0xFF0284C7),
    },
    {
      'bg': Color(0xFFFAF5FF), // Light Violet
      'border': Color(0xFFE9D5FF),
      'text': Color(0xFF7E22CE),
    },
  ];

  Map<String, Color> _getLightPalette(String name) {
    if (name.isEmpty) return _lightPalettes[0];
    final index = name.hashCode.abs() % _lightPalettes.length;
    return _lightPalettes[index];
  }

  @override
  Widget build(BuildContext context) {
    final expProvider = Provider.of<ExploreProvider>(context);

    final filteredExhibitors = expProvider.exhibitors.where((ex) {
      final query = _searchQuery.toLowerCase();
      return ex.name.toLowerCase().contains(query) ||
          ex.category.toLowerCase().contains(query) ||
          ex.boothCode.toLowerCase().contains(query);
    }).toList();

    return WaterDropletsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF061033), Color(0xFF0B1953), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Exhibitors',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white.withAlpha(180),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.textLight, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search exhibitors...',
                          hintStyle: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  await auth.refreshSessionToken();
                  if (!mounted) return;
                  await _fetchData(force: true);
                },
                color: AppColors.primary,
                backgroundColor: Colors.white,
                child: expProvider.isLoading
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 3,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Loading exhibitors...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.all(20),
                        children: [
                          if (filteredExhibitors.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.business_center_outlined,
                                      size: 48,
                                      color: AppColors.textLight,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No exhibitors match "$_searchQuery"',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else ...[
                            const Text(
                              'Exhibitors & Sponsors',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...filteredExhibitors.map((ex) {
                              final palette = _getLightPalette(ex.name);
                              final hasLogo = ex.logoUrl != null && ex.logoUrl!.isNotEmpty;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExhibitorDetailsScreen(exhibitor: ex),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(color: AppColors.tileBorder, width: 1.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(6),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 72,
                                        height: 72,
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: hasLogo
                                              ? const Color(0xFFF8FAFC)
                                              : palette['bg'],
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: hasLogo
                                                ? Colors.grey.shade200
                                                : palette['border']!,
                                            width: 1.2,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        clipBehavior: Clip.antiAlias,
                                        child: hasLogo
                                            ? Image.network(
                                                ex.logoUrl!,
                                                width: 72,
                                                height: 72,
                                                fit: BoxFit.contain,
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return const Center(
                                                    child: SizedBox(
                                                      width: 18,
                                                      height: 18,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error, stackTrace) => Text(
                                                  ex.initials,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: palette['text'],
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                ex.initials,
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: palette['text'],
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ex.name,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            if (ex.category.isNotEmpty) ...[
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary.withAlpha(15),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  ex.category.toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                            ],
                                            if (ex.boothCode.isNotEmpty || ex.boothZone.isNotEmpty)
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.storefront_outlined,
                                                    size: 13,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      ex.boothZone.isNotEmpty && ex.boothCode.isNotEmpty
                                                          ? 'Stall: ${ex.boothZone}  •  ${ex.boothCode}'
                                                          : (ex.boothZone.isNotEmpty
                                                              ? 'Stall: ${ex.boothZone}'
                                                              : ex.boothCode),
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: AppColors.textSecondary,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.grey.shade200, width: 1),
                                        ),
                                        child: const Icon(
                                          Icons.chevron_right,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                          const SizedBox(height: 24),
                          if (expProvider.isLoadingBooths) ...[
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(230),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.tileBorder, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Loading Summit Exhibition Booths...',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ] else if (expProvider.summitBooths.isNotEmpty) ...[
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF0B1953), Color(0xFF1E3A8A)],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.storefront_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Summit Exhibition Booths',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF0B1953), Color(0xFF1E3A8A)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${expProvider.summitBooths.length} Booths',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: expProvider.summitBooths.map((booth) {
                                final cleanBoothNum = booth.boothNumber.replaceAll('#', '').trim();
                                final displayBoothNum = cleanBoothNum.isNotEmpty ? '$cleanBoothNum' : 'Booth';

                                return Container(
                                  width: (MediaQuery.of(context).size.width - 50) / 2,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.primary.withAlpha(35), width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(10),
                                        blurRadius: 8,
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
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withAlpha(15),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            alignment: Alignment.center,
                                            child: booth.logo != null && booth.logo!.isNotEmpty
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Image.network(
                                                      booth.logo!,
                                                      width: 28,
                                                      height: 28,
                                                      fit: BoxFit.contain,
                                                      loadingBuilder: (context, child, loadingProgress) {
                                                        if (loadingProgress == null) return child;
                                                        return const Center(
                                                          child: SizedBox(
                                                            width: 12,
                                                            height: 12,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 1.5,
                                                              color: AppColors.primary,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder: (c, o, s) => const Icon(
                                                        Icons.storefront_rounded,
                                                        size: 20,
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.storefront_rounded,
                                                    size: 20,
                                                    color: AppColors.primary,
                                                  ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              booth.boothLabel,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                                height: 1.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        displayBoothNum,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      if (booth.companyName != null && booth.companyName!.trim().isNotEmpty) ...[
                                        const SizedBox(height: 5),
                                        Text(
                                          booth.companyName!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      if (booth.boothCapacity != '0' && booth.boothCapacity.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.groups_outlined,
                                              size: 12,
                                              color: AppColors.textLight,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Capacity: ${booth.boothCapacity}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
