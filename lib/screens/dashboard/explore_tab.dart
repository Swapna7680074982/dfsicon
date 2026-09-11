import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/explore_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/sessions_provider.dart';
import '../exhibitor/exhibitors_list_screen.dart';
import '../workshops/workshops_list_screen.dart';
import '../explore/invited_speakers_screen.dart';
import '../../widgets/water_droplets_background.dart';

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
      _fetchData();
    });
  }

  Future<void> _fetchData({bool force = false}) async {
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final explore = Provider.of<ExploreProvider>(context, listen: false);
    final sessions = Provider.of<SessionsProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final String summitId = homeProvider.summits.isNotEmpty
        ? homeProvider.summits.first['summit_id']?.toString() ?? ''
        : '';

    final futures = <Future>[];
    if (force || explore.exhibitors.isEmpty) {
      futures.add(explore.fetchSponsors(summitId, auth.accessToken));
    }
    if (force || explore.summitBooths.isEmpty) {
      futures.add(explore.fetchSummitBooths(summitId, auth.accessToken));
    }
    if (force || sessions.venueInfo == null) {
      futures.add(sessions.fetchVenueAndHalls(summitId, auth.accessToken));
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          elevation: 2,
          automaticallyImplyLeading: false,
          title: const Text(
            'Explore',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            await auth.refreshSessionToken();
            if (!mounted) return;
            await _fetchData(force: true);
          },
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryCard(
                  context,
                  title: 'EXHIBITORS',
                  subtitle: '120+ Healthcare brands, startups & booths',
                  badgeText: '120+ Stalls',
                  icon: Icons.storefront_rounded,
                  iconBg: const Color(0xFFEEECF9),
                  iconColor: AppColors.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExhibitorsListScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _buildCategoryCard(
                  context,
                  title: 'MY WORKSHOPS',
                  subtitle: 'Hands-on clinical masterclasses & workshops',
                  badgeText: 'Registered',
                  icon: Icons.assignment_turned_in_rounded,
                  iconBg: const Color(0xFFEEF2FF),
                  iconColor: const Color(0xFF4F46E5),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WorkshopsListScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _buildCategoryCard(
                  context,
                  title: 'INVITED SPEAKERS',
                  subtitle: 'Keynote speakers, faculty & session chairs',
                  badgeText: 'Faculty',
                  icon: Icons.record_voice_over_rounded,
                  iconBg: const Color(0xFFEFF6FF),
                  iconColor: Colors.blueAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InvitedSpeakersScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildVenueGuideCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.tileBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: iconColor.withAlpha(25),
          highlightColor: iconColor.withAlpha(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: iconColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVenueGuideCard(BuildContext context) {
    return Consumer<SessionsProvider>(
      builder: (context, sessions, child) {
        final venue = sessions.venueInfo;
        final String venueName = (venue != null && venue.venueName.trim().isNotEmpty)
            ? venue.venueName.trim()
            : 'Hilton Garden Inn Bengaluru, Embassy Manyata Business Park';
        final String venueAddress = (venue != null && venue.address.trim().isNotEmpty)
            ? venue.address.trim()
            : 'Block A, Hotel Building, 2, Outer Ring Rd, MS Ramaiah North City, Manayata Tech Park, Nagawara, Bengaluru, Karnataka 560045';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A1E3D), Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A1E3D).withAlpha(40),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SUMMIT VENUE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF93C5FD),
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          venueName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                venueAddress,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFE2E8F0),
                  height: 1.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


