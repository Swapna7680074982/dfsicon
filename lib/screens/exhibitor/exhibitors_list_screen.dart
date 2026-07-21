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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final explore = Provider.of<ExploreProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final String summitId = homeProvider.summits.isNotEmpty
        ? homeProvider.summits.first['summit_id']?.toString() ?? '1'
        : '1';
    
    if (force || explore.exhibitors.isEmpty) {
      await explore.fetchSponsors(summitId, auth.accessToken);
    }
    if (force || explore.summitBooths.isEmpty) {
      await explore.fetchSummitBooths(summitId, auth.accessToken);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          backgroundColor: AppColors.primary,
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Exhibitors',
            style: TextStyle(
              fontSize: 24,
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
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(235),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.tileBorder, width: 1),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: ex.logoUrl != null ? Colors.white : ex.bg,
                                    shape: BoxShape.circle,
                                    border: ex.logoUrl != null ? Border.all(color: AppColors.tileBorder, width: 1) : null,
                                  ),
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.antiAlias,
                                  child: ex.logoUrl != null
                                      ? Image.network(
                                          ex.logoUrl!,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Text(
                                            ex.initials,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          ex.initials,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                                title: Text(
                                  ex.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    '${ex.category}  •  ${ex.boothCode}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  size: 14,
                                  color: AppColors.textLight,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExhibitorDetailsScreen(exhibitor: ex),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        ],
                        const SizedBox(height: 24),
                        if (expProvider.summitBooths.isNotEmpty) ...[
                          const Text(
                            'Summit Exhibition Booths',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: expProvider.summitBooths.map((booth) {
                              return Container(
                                width: (MediaQuery.of(context).size.width - 50) / 2,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(240),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.primary.withAlpha(50), width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(10),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.storefront_rounded,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            booth.boothLabel,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Booth #${booth.boothNumber}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    if (booth.boothCapacity != '0' && booth.boothCapacity.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          'Capacity: ${booth.boothCapacity}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      ),
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
    ),);
  }
}
