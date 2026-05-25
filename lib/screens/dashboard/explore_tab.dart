import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/explore_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../exhibitor/exhibitors_list_screen.dart';
import '../sightseeing/sightseeing_list_screen.dart';
import '../exhibitor/exhibitor_details_screen.dart';
import '../help_desk/help_desk_screen.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSponsors();
    });
  }

  Future<void> _fetchSponsors() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final explore = Provider.of<ExploreProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final String summitId = homeProvider.summits.isNotEmpty
        ? homeProvider.summits.first['summit_id']?.toString() ?? ''
        : '';
    await explore.fetchSponsors(summitId, auth.accessToken);
  }

  @override
  Widget build(BuildContext context) {
    final expProvider = Provider.of<ExploreProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Explore',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                children: [
                  _buildCategoryCard(
                    context,
                    title: 'Exhibitors',
                    subtitle: '120+ companies & startups',
                    icon: Icons.business,
                    iconBg: const Color(0xFFEEECF9),
                    iconColor: AppColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ExhibitorsListScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryCard(
                    context,
                    title: 'Sightseeing',
                    subtitle: 'Explore the city nearby',
                    icon: Icons.map_outlined,
                    iconBg: const Color(0xFFECFDF5),
                    iconColor: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SightseeingListScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryCard(
                    context,
                    title: 'Help Desk',
                    subtitle: 'Support, FAQs & contacts',
                    icon: Icons.help_outline,
                    iconBg: const Color(0xFFFDF2F8),
                    iconColor: const Color(0xFFDB2777),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HelpDeskScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Exhibitors',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ExhibitorsListScreen()),
                      );
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemCount: expProvider.featuredExhibitors.length,
              itemBuilder: (context, index) {
                final ex = expProvider.featuredExhibitors[index];
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.tileBorder, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
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
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Text(
                                    ex.initials,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  ex.initials,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          ex.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ex.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                ex.boothCode,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.tileBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_outlined,
              size: 16,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
