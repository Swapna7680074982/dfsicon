import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/photo_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/sessions_provider.dart';
import '../../providers/auth_provider.dart';
import '../session_details/session_details_screen.dart';
import '../../widgets/event_qr_modal.dart';
import '../profile/profile_screen.dart';
import '../sightseeing/sightseeing_list_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../widgets/water_droplets_background.dart';
import '../../utils/time_formatter.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback onNavigateToSessions;

  const HomeTab({super.key, required this.onNavigateToSessions});

  static const List<List<String>> _gradientPairs = [
    ['0xFF4F46E5', '0xFF818CF8'], // Indigo
    ['0xFFDB2777', '0xFFF472B6'], // Pink
    ['0xFF059669', '0xFF34D399'], // Emerald
    ['0xFFD97706', '0xFFFBBF24'], // Amber
    ['0xFFDC2626', '0xFFFCA5A5'], // Red
    ['0xFF7C3AED', '0xFFA78BFA'], // Purple
  ];

  static const List<String> _fallbackImages = [
    'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1504868584819-f8e8b4b6d7e3?w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1516841273335-e39b37888115?w=400&fit=crop',
    'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=400&fit=crop',
    'https://images.unsplash.com/photo-1530026405186-ed1ea0ac7a63?w=400&fit=crop',
  ];

  String _getThumbnailUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    if (path.startsWith('http')) {
      return path;
    }
    String cleanPath = path;
    if (cleanPath.startsWith('./')) {
      cleanPath = cleanPath.substring(2);
    } else if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return 'https://services.heterohcl.com/dfs-icon/$cleanPath';
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.tileBorder, width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard({
    required String title,
    required String speaker,
    required String speakerInitials,
    required Color speakerBg,
    required String time,
    required String hall,
    required String gradientStart,
    required String gradientEnd,
    required String imageUrl,
  }) {
    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.tileBorder, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 110,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(int.parse(gradientStart)),
                              Color(int.parse(gradientEnd)),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(int.parse(gradientStart)),
                              Color(int.parse(gradientEnd)),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.biotech,
                            color: Colors.white.withAlpha(80),
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bookmark,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: speakerBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        speakerInitials,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        speaker,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$time • $hall',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExhibitorCard({
    required String initials,
    required Color color,
    required String title,
    required String subtitle,
    required String booth,
    String? imageUrl,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.tileBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: imageUrl != null ? Colors.white : color,
              borderRadius: BorderRadius.circular(12),
              border: imageUrl != null
                  ? Border.all(color: AppColors.tileBorder, width: 1)
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: color,
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 12,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 4),
              Text(
                booth,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSightseeCard({
    required String title,
    required String distance,
    required String cost,
    required String colorStart,
    required String colorEnd,
    required IconData icon,
    required String imageUrl,
  }) {
    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.tileBorder, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 90,
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(int.parse(colorStart)),
                        Color(int.parse(colorEnd)),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(int.parse(colorStart)),
                        Color(int.parse(colorEnd)),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: Colors.white.withAlpha(80),
                      size: 32,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      distance,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '•',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cost,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({double? width, double? height, double radius = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFDDE4F0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event card skeleton
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(240),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFDDE4F0), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerBox(width: 100, height: 20, radius: 30),
              const SizedBox(height: 16),
              _buildShimmerBox(width: 200, height: 28),
              const SizedBox(height: 8),
              _buildShimmerBox(width: 150, height: 16),
              const SizedBox(height: 24),
              _buildShimmerBox(width: double.infinity, height: 48, radius: 16),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Stats row skeleton
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFDDE4F0),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    _buildShimmerBox(width: 44, height: 44, radius: 22),
                    const SizedBox(height: 10),
                    _buildShimmerBox(width: 40, height: 18),
                    const SizedBox(height: 6),
                    _buildShimmerBox(width: 60, height: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFDDE4F0),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    _buildShimmerBox(width: 44, height: 44, radius: 22),
                    const SizedBox(height: 10),
                    _buildShimmerBox(width: 40, height: 18),
                    const SizedBox(height: 6),
                    _buildShimmerBox(width: 60, height: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFDDE4F0),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    _buildShimmerBox(width: 44, height: 44, radius: 22),
                    const SizedBox(height: 10),
                    _buildShimmerBox(width: 40, height: 18),
                    const SizedBox(height: 6),
                    _buildShimmerBox(width: 60, height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        // Sessions heading skeleton
        _buildShimmerBox(width: 100, height: 22),
        const SizedBox(height: 12),
        // Sessions cards skeleton
        SizedBox(
          height: 234,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, _) => Container(
              width: 210,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDDE4F0), width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(
                    width: double.infinity,
                    height: 110,
                    radius: 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmerBox(width: 160, height: 14),
                        const SizedBox(height: 6),
                        _buildShimmerBox(width: 120, height: 12),
                        const SizedBox(height: 12),
                        _buildShimmerBox(width: 100, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        // Exhibitors heading skeleton
        _buildShimmerBox(width: 140, height: 22),
        const SizedBox(height: 14),
        // Exhibitors skeleton
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, _) => Container(
              width: 130,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDDE4F0), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(width: 60, height: 60, radius: 14),
                    const SizedBox(height: 10),
                    _buildShimmerBox(width: 90, height: 14),
                    const SizedBox(height: 6),
                    _buildShimmerBox(width: 70, height: 11),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        // Sightseeing heading skeleton
        _buildShimmerBox(width: 120, height: 22),
        const SizedBox(height: 12),
        // Sightseeing skeleton
        SizedBox(
          height: 176,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, _) => Container(
              width: 180,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDDE4F0), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(
                    width: double.infinity,
                    height: 100,
                    radius: 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmerBox(width: 130, height: 14),
                        const SizedBox(height: 6),
                        _buildShimmerBox(width: 90, height: 11),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'DL';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0].isNotEmpty && parts[1].isNotEmpty)
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'DL';
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = Provider.of<PhotoProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final sessionsProvider = Provider.of<SessionsProvider>(context);

    return WaterDropletsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              final sessionsProv = Provider.of<SessionsProvider>(context, listen: false);
              await authProvider.refreshSessionToken();
              await homeProvider.fetchSummits(authProvider.accessToken);
              await sessionsProv.fetchConfirmedSessions(authProvider.accessToken);
            },
            color: AppColors.primary,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authProvider.userName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withAlpha(40),
                                width: 1.5,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.notifications_none,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                Positioned(
                                  top: 10,
                                  right: 11,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: photoProvider.hasPhoto
                                ? Image.file(
                                    File(photoProvider.imagePath!),
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Text(
                                      _getInitials(authProvider.userName),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: homeProvider.isLoading
                        ? _buildLoadingPlaceholder()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(240),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: AppColors.primary.withAlpha(24),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withAlpha(12),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withAlpha(16),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            color: AppColors.primary,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            homeProvider.eventInfo.location,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      homeProvider.eventInfo.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      TimeFormatter.formatString(
                                        homeProvider.eventInfo.date,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => EventQrModal(
                                            userName: authProvider.userName,
                                            eventName:
                                                homeProvider.eventInfo.name,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.qr_code_2_outlined,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'My QR Code',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        elevation: 2,
                                        shadowColor: AppColors.primary
                                            .withAlpha(60),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14.0,
                                        ),
                                        minimumSize: const Size(
                                          double.infinity,
                                          48,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatCard(
                                    icon: homeProvider.stats[0].icon,
                                    iconColor: homeProvider.stats[0].iconColor,
                                    iconBgColor:
                                        homeProvider.stats[0].iconBgColor,
                                    value: homeProvider.stats[0].value,
                                    label: homeProvider.stats[0].label,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildStatCard(
                                    icon: homeProvider.stats[1].icon,
                                    iconColor: homeProvider.stats[1].iconColor,
                                    iconBgColor:
                                        homeProvider.stats[1].iconBgColor,
                                    value: homeProvider.stats[1].value,
                                    label: homeProvider.stats[1].label,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildStatCard(
                                    icon: homeProvider.stats[2].icon,
                                    iconColor: homeProvider.stats[2].iconColor,
                                    iconBgColor:
                                        homeProvider.stats[2].iconBgColor,
                                    value: homeProvider.stats[2].value,
                                    label: homeProvider.stats[2].label,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Sessions',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: onNavigateToSessions,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                    ),
                                    child: Row(
                                      children: const [
                                        Text(
                                          'View All',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.chevron_right,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const SizedBox(height: 12),
                              if (sessionsProvider.isLoading &&
                                  sessionsProvider.sessions.isEmpty)
                                SizedBox(
                                  height: 234,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 3,
                                    itemBuilder: (context, _) => Container(
                                      width: 210,
                                      margin: const EdgeInsets.only(right: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFDDE4F0),
                                          width: 1.5,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildShimmerBox(
                                            width: double.infinity,
                                            height: 110,
                                            radius: 0,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildShimmerBox(
                                                  width: 160,
                                                  height: 14,
                                                ),
                                                const SizedBox(height: 6),
                                                _buildShimmerBox(
                                                  width: 120,
                                                  height: 12,
                                                ),
                                                const SizedBox(height: 12),
                                                _buildShimmerBox(
                                                  width: 100,
                                                  height: 12,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              else if (sessionsProvider.sessions.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 24.0),
                                    child: Text(
                                      'No confirmed sessions available',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                SizedBox(
                                  height: 234,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: sessionsProvider.sessions.length > 5
                                        ? 5
                                        : sessionsProvider.sessions.length,
                                    itemBuilder: (context, index) {
                                      final s =
                                          sessionsProvider.sessions[index];
                                      final colorIndex = index % _gradientPairs.length;
                                      final gradientStart =
                                          _gradientPairs[colorIndex][0];
                                      final gradientEnd =
                                          _gradientPairs[colorIndex][1];
                                      final imageUrl = (s.thumbnail != null &&
                                              s.thumbnail!.isNotEmpty)
                                          ? _getThumbnailUrl(s.thumbnail!)
                                          : _fallbackImages[index %
                                              _fallbackImages.length];

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SessionDetailsScreen(
                                                session: s,
                                              ),
                                            ),
                                          );
                                        },
                                        child: _buildSessionCard(
                                          title: s.title,
                                          speaker: s.speakerName,
                                          speakerInitials: s.speakerInitials,
                                          speakerBg: s.speakerBg,
                                          time: s.time,
                                          hall: s.location,
                                          gradientStart: gradientStart,
                                          gradientEnd: gradientEnd,
                                          imageUrl: imageUrl,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              const SizedBox(height: 28),
                              const Text(
                                'Sponsors & Exhibitors',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 160,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: homeProvider.exhibitors.length,
                                  itemBuilder: (context, index) {
                                    final e = homeProvider.exhibitors[index];
                                    return _buildExhibitorCard(
                                      initials: e.initials,
                                      color: e.color,
                                      title: e.title,
                                      subtitle: e.subtitle,
                                      booth: e.booth,
                                      imageUrl: e.imageUrl,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 28),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Sightseeing',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SightseeingListScreen(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                    ),
                                    child: Row(
                                      children: const [
                                        Text(
                                          'View All',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.chevron_right,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 176,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: homeProvider.sightseeSpots.length,
                                  itemBuilder: (context, index) {
                                    final s = homeProvider.sightseeSpots[index];
                                    return _buildSightseeCard(
                                      title: s.title,
                                      distance: s.distance,
                                      cost: s.cost,
                                      colorStart: s.colorStart,
                                      colorEnd: s.colorEnd,
                                      icon: s.icon,
                                      imageUrl: s.imageUrl,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
