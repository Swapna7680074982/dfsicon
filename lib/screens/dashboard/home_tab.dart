import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/photo_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/sessions_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/explore_provider.dart';
import '../../providers/workshops_provider.dart';
import '../session_details/session_details_screen.dart';
import '../exhibitor/exhibitor_details_screen.dart';
import '../exhibitor/exhibitors_list_screen.dart';
import '../../providers/exhibitor_provider.dart';
import '../../widgets/event_qr_modal.dart';
import '../../widgets/venue_media_widget.dart';
import '../../widgets/venue_layouts_widget.dart';
import '../profile/profile_screen.dart';
// import '../sightseeing/sightseeing_list_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../providers/notifications_provider.dart';
import '../workshops/workshops_list_screen.dart';
import '../workshops/workshop_details_screen.dart';
import '../calendar/event_calendar_screen.dart';
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

  String? _getSpeakerProfileImageUrl(String? path) {
    if (path == null || path.isEmpty || path == 'null' || path == 'NA') {
      return null;
    }
    String cleanPath = path.trim();
    if (cleanPath.contains('/./')) {
      cleanPath = cleanPath.replaceAll('/./', '/');
    }
    if (cleanPath.startsWith('http')) {
      return cleanPath;
    }
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
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.tileBorder, width: 1.5),
            ),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
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
    required bool isBookmarked,
    String? speakerProfileImage,
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
          if (imageUrl.trim().isNotEmpty)
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
                if (isBookmarked)
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
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
                    ),
                    if (imageUrl.trim().isEmpty && isBookmarked) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ],
                  ],
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
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      child: _getSpeakerProfileImageUrl(speakerProfileImage) != null
                          ? Image.network(
                              _getSpeakerProfileImageUrl(speakerProfileImage)!,
                              fit: BoxFit.cover,
                              width: 24,
                              height: 24,
                              errorBuilder: (c, o, s) => Text(
                                speakerInitials.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              speakerInitials.toUpperCase(),
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
                        // '$time • $hall',
                        time,
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

  static Map<String, Color> _getLightPalette(String name) {
    if (name.isEmpty) return _lightPalettes[0];
    final index = name.hashCode.abs() % _lightPalettes.length;
    return _lightPalettes[index];
  }

  Widget _buildExhibitorCard({
    required String initials,
    required Color color,
    required String title,
    required String subtitle,
    required String booth,
    String? imageUrl,
  }) {
    final palette = _getLightPalette(title);
    final hasLogo = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      width: 175,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.tileBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 92,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: hasLogo
                  ? const Color(0xFFF8FAFC)
                  : palette['bg'],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasLogo
                    ? Colors.grey.shade200
                    : palette['border']!,
                width: 1.2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: hasLogo
                ? Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Text(
                      initials.toUpperCase(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: palette['text'],
                      ),
                    ),
                  )
                : Text(
                    initials.toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: palette['text'],
                    ),
                  ),
          ),
          const SizedBox(height: 10),
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
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (booth.trim().isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      booth,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /*
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
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _parseColor(colorStart),
                        _parseColor(colorEnd),
                      ],
                    ),
                  ),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Center(
                            child: Icon(icon, color: Colors.white, size: 36),
                          ),
                        )
                      : Center(
                          child: Icon(icon, color: Colors.white, size: 36),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.4 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 11,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          distance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
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
  */

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
            for (int i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 4,
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
                      _buildShimmerBox(width: 36, height: 36, radius: 18),
                      const SizedBox(height: 8),
                      _buildShimmerBox(width: 30, height: 16),
                      const SizedBox(height: 6),
                      _buildShimmerBox(width: 45, height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 28),
        // Sessions heading skeleton
        _buildShimmerBox(width: 100, height: 22),
        const SizedBox(height: 12),
        // Sessions cards skeleton
        SizedBox(
          height: 260,
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
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, _) => Container(
              width: 175,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFDDE4F0), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(width: double.infinity, height: 92, radius: 16),
                    const SizedBox(height: 10),
                    _buildShimmerBox(width: 120, height: 14),
                    const SizedBox(height: 6),
                    _buildShimmerBox(width: 80, height: 11),
                  ],
                ),
              ),
            ),
          ),
        ),
        /*
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
        */
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

  void _onExhibitorClick(BuildContext context, HomeExhibitor homeExhibitor) async {
    final exploreProvider = Provider.of<ExploreProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    if (exploreProvider.exhibitors.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      final String summitId = homeProvider.summits.isNotEmpty
          ? homeProvider.summits.first['summit_id']?.toString() ?? '1'
          : '1';
      await Future.wait([
        exploreProvider.fetchSponsors(summitId, authProvider.accessToken),
        exploreProvider.fetchSummitBooths(summitId, authProvider.accessToken),
      ]);

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }

    final sponsorId = homeExhibitor.booth.replaceAll(RegExp(r'[^\d]'), '').trim();

    Exhibitor? matchedExhibitor;
    try {
      matchedExhibitor = exploreProvider.exhibitors.firstWhere(
        (ex) => ex.id == sponsorId || ex.name.toLowerCase() == homeExhibitor.title.toLowerCase(),
      );
    } catch (_) {}

    if (matchedExhibitor != null) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExhibitorDetailsScreen(exhibitor: matchedExhibitor!),
          ),
        );
      }
    } else {
      final fallbackEx = Exhibitor(
        id: sponsorId.isEmpty ? 'mc' : sponsorId,
        name: homeExhibitor.title,
        category: homeExhibitor.subtitle,
        boothCode: homeExhibitor.booth,
        boothZone: '',
        initials: homeExhibitor.initials,
        bg: homeExhibitor.color,
        description: '',
        products: const [],
        website: '',
        email: '',
        logoUrl: homeExhibitor.imageUrl,
      );
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExhibitorDetailsScreen(exhibitor: fallbackEx),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = Provider.of<PhotoProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final sessionsProvider = Provider.of<SessionsProvider>(context);
    final workshopsProvider = Provider.of<WorkshopsProvider>(context);
    final myWorkshops = workshopsProvider.workshops;

    return WaterDropletsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              final sessionsProv = Provider.of<SessionsProvider>(context, listen: false);
              final workshopsProv = Provider.of<WorkshopsProvider>(context, listen: false);
              await authProvider.refreshSessionToken();
              if (!context.mounted) return;
              await homeProvider.fetchSummits(authProvider.accessToken);
              if (!context.mounted) return;
              await sessionsProv.fetchConfirmedSessions(authProvider.accessToken, forceRefresh: true);
              if (!context.mounted) return;
              await workshopsProv.fetchMyWorkshops(authProvider.accessToken, forceRefresh: true);
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
                        colors: [Color(0xFF0A1E3D), Color(0xFF1E3A8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Consumer<NotificationsProvider>(
                          builder: (context, notifProvider, child) {
                            return GestureDetector(
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
                                    if (notifProvider.unreadCount > 0)
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
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => EventQrModal(
                                userName: authProvider.userName,
                                eventName: homeProvider.eventInfo.name,
                              ),
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.qr_code_2_outlined,
                              color: Colors.white,
                              size: 22,
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
                                : authProvider.hasValidProfileImage
                                    ? Image.network(
                                        authProvider.profileImage,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Center(
                                          child: Text(
                                            _getInitials(authProvider.userName),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
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
                                    if (homeProvider.eventInfo.location.trim().isNotEmpty) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withAlpha(16),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              color: AppColors.primary,
                                              size: 13,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                homeProvider.eventInfo.location,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primary,
                                                  height: 1.2,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    if (homeProvider.eventInfo.name.trim().isNotEmpty)
                                      Text(
                                        homeProvider.eventInfo.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    if (homeProvider.eventInfo.date.trim().isNotEmpty) ...[
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
                                    ],
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const EventCalendarScreen(
                                              role: CalendarRole.delegate,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.schedule_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      label: const Text(
                                        'MY SCHEDULE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        elevation: 2,
                                        shadowColor: AppColors.primary.withAlpha(60),
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
                              if (sessionsProvider.venueLayouts.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                VenueLayoutsWidget(
                                  layouts: sessionsProvider.venueLayouts,
                                  isLoading: sessionsProvider.isFetchingVenueLayouts,
                                ),
                              ],
                              if (sessionsProvider.venueMedia.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                VenueMediaWidget(
                                  mediaList: sessionsProvider.venueMedia,
                                  title: 'Venue photos',
                                ),
                              ],
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
                                  const SizedBox(width: 8),
                                  _buildStatCard(
                                    icon: homeProvider.stats[1].icon,
                                    iconColor: homeProvider.stats[1].iconColor,
                                    iconBgColor:
                                        homeProvider.stats[1].iconBgColor,
                                    value: homeProvider.stats[1].value,
                                    label: homeProvider.stats[1].label,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatCard(
                                    icon: homeProvider.stats[4].icon,
                                    iconColor: homeProvider.stats[4].iconColor,
                                    iconBgColor:
                                        homeProvider.stats[4].iconBgColor,
                                    value: homeProvider.stats[4].value,
                                    label: homeProvider.stats[4].label,
                                  ),
                                  const SizedBox(width: 8),
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
                                          'VIEW ALL',
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
                              if (sessionsProvider.isLoading &&
                                  sessionsProvider.sessions.isEmpty)
                                SizedBox(
                                  height: 260,
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
                                () {
                                  final bool hasAnySessionImage =
                                      sessionsProvider.sessions.any(
                                    (s) =>
                                        s.thumbnail != null &&
                                        s.thumbnail!.trim().isNotEmpty &&
                                        s.thumbnail != 'null' &&
                                        s.thumbnail != 'NA',
                                  );
                                  final double sessionListHeight =
                                      hasAnySessionImage ? 260 : 150;

                                  return SizedBox(
                                    height: sessionListHeight,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          sessionsProvider.sessions.length > 5
                                              ? 5
                                              : sessionsProvider.sessions.length,
                                      itemBuilder: (context, index) {
                                        final s =
                                            sessionsProvider.sessions[index];
                                        final colorIndex =
                                            index % _gradientPairs.length;
                                        final gradientStart =
                                            _gradientPairs[colorIndex][0];
                                        final gradientEnd =
                                            _gradientPairs[colorIndex][1];
                                        final imageUrl = (s.thumbnail != null &&
                                                s.thumbnail!.trim().isNotEmpty &&
                                                s.thumbnail != 'null' &&
                                                s.thumbnail != 'NA')
                                            ? _getThumbnailUrl(s.thumbnail!)
                                            : '';

                                        return Align(
                                          alignment: Alignment.topCenter,
                                          child: GestureDetector(
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
                                              isBookmarked: s.isBookmarked,
                                              speakerProfileImage:
                                                  s.speakerProfileImage,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }(),
                              const SizedBox(height: 28),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'My Workshops',
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
                                          builder: (context) => const WorkshopsListScreen(),
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
                                          'VIEW ALL',
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
                              if (workshopsProvider.isLoading && myWorkshops.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24.0),
                                    child: CircularProgressIndicator(color: AppColors.primary),
                                  ),
                                )
                              else if (myWorkshops.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: AppColors.tileBorder, width: 1.5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      workshopsProvider.errorMessage ?? 'No workshops registered yet',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                                    ),
                                  ),
                                )
                              else ...[
                                Builder(
                                  builder: (context) {
                                    final ws = myWorkshops.first;
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => WorkshopDetailsScreen(workshop: ws),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: AppColors.tileBorder, width: 1.5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(2),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 42,
                                              height: 42,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEFF6FF),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.assignment_outlined,
                                                color: AppColors.primary,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.primary.withAlpha(16),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          ws.workshopType,
                                                          style: const TextStyle(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            color: AppColors.primary,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    ws.workshopName,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Venue: ${ws.venueName} · ${ws.city}',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppColors.textLight,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              size: 14,
                                              color: AppColors.textLight,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                ),
                              ],
                              // Footfall & Visits Card from Exhibitor Provider
                              Consumer<ExhibitorProvider>(
                                builder: (context, exhibitor, _) {
                                  final auth = Provider.of<AuthProvider>(context, listen: false);
                                  if (exhibitor.countsData == null && !exhibitor.isLoadingCounts && auth.accessToken.isNotEmpty) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      exhibitor.fetchAllExhibitorData(auth.accessToken, summitId: '1');
                                    });
                                  }

                                  final totalVisits = exhibitor.summary.totalVisits;
                                  final uniqueVisitors = exhibitor.summary.uniqueVisitors;
                                  final recentVisits = exhibitor.participants;

                                  return Container(
                                    margin: const EdgeInsets.only(top: 24, bottom: 8),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF312E81), Color(0xFF4338CA), Color(0xFF6366F1)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4338CA).withValues(alpha: 0.28),
                                          blurRadius: 14,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.18),
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: const Icon(
                                                Icons.analytics_rounded,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Footfall & Visits Overview',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 0.2,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    'Live recorded footfall & visit statistics',
                                                    style: TextStyle(
                                                      color: Color(0xFFE0E7FF),
                                                      fontSize: 11.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        // 2 Metrics Chips
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.visibility_rounded, color: Color(0xFF34D399), size: 18),
                                                    const SizedBox(width: 8),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Text(
                                                          'Total Visits',
                                                          style: TextStyle(fontSize: 10.5, color: Color(0xFFC7D2FE), fontWeight: FontWeight.w600),
                                                        ),
                                                        Text(
                                                          '$totalVisits',
                                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.people_alt_rounded, color: Color(0xFF38BDF8), size: 18),
                                                    const SizedBox(width: 8),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Text(
                                                          'Unique Visitors',
                                                          style: TextStyle(fontSize: 10.5, color: Color(0xFFC7D2FE), fontWeight: FontWeight.w600),
                                                        ),
                                                        Text(
                                                          '$uniqueVisitors',
                                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (recentVisits.isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Recent Recorded Visits',
                                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFC7D2FE)),
                                          ),
                                          const SizedBox(height: 6),
                                          ...recentVisits.take(3).map((v) => Container(
                                            margin: const EdgeInsets.only(bottom: 6),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: (v.role == 'SK' || v.roleLabel.toLowerCase().contains('speaker'))
                                                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.3)
                                                        : const Color(0xFF10B981).withValues(alpha: 0.3),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    v.roleLabel.isNotEmpty ? v.roleLabel : (v.role.isNotEmpty ? v.role : 'Visitor'),
                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        v.name,
                                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      if (v.organisation.isNotEmpty || v.boothLabel.isNotEmpty || v.boothNumber.isNotEmpty)
                                                        Text(
                                                          '${v.organisation.isNotEmpty ? v.organisation : ''}${v.boothLabel.isNotEmpty ? ' · Booth ${v.boothLabel}' : (v.boothNumber.isNotEmpty ? ' · Booth ${v.boothNumber}' : '')}',
                                                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  v.visitedTime,
                                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFFC7D2FE)),
                                                ),
                                              ],
                                            ),
                                          )),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Sponsors & Exhibitors',
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
                                              const ExhibitorsListScreen(),
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
                                          'VIEW ALL',
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
                              const SizedBox(height: 14),
                              if (homeProvider.exhibitors.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: AppColors.tileBorder, width: 1.5),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'No exhibitors found',
                                      style: TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                SizedBox(
                                  height: 220,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: homeProvider.exhibitors.length,
                                    itemBuilder: (context, index) {
                                      final e = homeProvider.exhibitors[index];
                                      return GestureDetector(
                                        onTap: () {
                                          _onExhibitorClick(context, e);
                                        },
                                        child: _buildExhibitorCard(
                                          initials: e.initials,
                                          color: e.color,
                                          title: e.title,
                                          subtitle: e.subtitle,
                                          booth: e.booth,
                                          imageUrl: e.imageUrl,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              /*
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
                                          'VIEW ALL',
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
                              */
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
