import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/photo_provider.dart';
import '../../providers/abstract_provider.dart';
import '../../providers/sessions_provider.dart';
import '../speaker_abstract/abstract_detail_screen.dart';
import '../speaker_abstract/create_abstract_screen.dart';
import '../speaker_sessions/speaker_session_detail_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/water_droplets_background.dart';
import '../../utils/time_formatter.dart';

class SpeakerHomeTab extends StatefulWidget {
  final VoidCallback onNavigateToSessions;
  final VoidCallback onNavigateToAbstracts;

  const SpeakerHomeTab({
    super.key,
    required this.onNavigateToSessions,
    required this.onNavigateToAbstracts,
  });

  @override
  State<SpeakerHomeTab> createState() => _SpeakerHomeTabState();
}

class _SpeakerHomeTabState extends State<SpeakerHomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final abstractProvider = Provider.of<AbstractProvider>(context, listen: false);
    final sessionsProvider = Provider.of<SessionsProvider>(context, listen: false);
    await Future.wait([
      abstractProvider.fetchMyAbstracts(auth.accessToken),
      sessionsProvider.fetchMyConfirmedSessions(auth.accessToken),
    ]);
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'SK';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0].isNotEmpty && parts[1].isNotEmpty)
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'SK';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final photoProvider = Provider.of<PhotoProvider>(context);
    final abstractProvider = Provider.of<AbstractProvider>(context);
    final sessionsProvider = Provider.of<SessionsProvider>(context);
    final mySessions = sessionsProvider.mySessions;

    return WaterDropletsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: () async {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            await auth.refreshSessionToken();
            await _fetchData();
          },
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF312E81), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const NotificationsScreen(),
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
                                  child: Stack(
                                    children: [
                                      const Icon(
                                        Icons.notifications_none_outlined,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: Container(
                                          width: 8,
                                          height: 8,
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
                                  ).then((_) {
                                    if (mounted) {
                                      _fetchData();
                                    }
                                  });
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
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
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(35),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_outlined,
                              color: Color(0xFF10B981),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${mySessions.length} Sessions Confirmed',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Sessions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onNavigateToSessions,
                        child: Row(
                          children: const [
                            Text(
                              'View All',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 12,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (sessionsProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (mySessions.isEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.tileBorder, width: 1),
                    ),
                    child: const Center(
                      child: Text(
                        'No sessions confirmed yet',
                        style: TextStyle(color: AppColors.textLight, fontSize: 13),
                      ),
                    ),
                  )
                else ...[
                  for (int i = 0; i < mySessions.length && i < 2; i++) ...[
                    if (i > 0) const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () {
                        final s = mySessions[i];
                        final String tag = (s.keywords ?? 'Health Tech').split(',').first;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpeakerSessionDetailScreen(
                              title: s.title,
                              date: s.date,
                              time: s.time,
                              location: s.location,
                              tag: tag,
                              coordinatorName: 'Mr. Arjun Mehta',
                              coordinatorPhone: '+91 98765 12345',
                              coordinatorEmail: 'arjun.mehta@dfisicon.org',
                              description: s.description,
                            ),
                          ),
                        );
                      },
                      child: _buildSessionCard(
                        title: mySessions[i].title,
                        date: mySessions[i].date,
                        time: mySessions[i].time,
                        location: mySessions[i].location,
                      ),
                    ),
                  ]
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Abstract Submission',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CreateAbstractScreen()),
                          ).then((success) {
                            _fetchData();
                            if (success == true) {
                              widget.onNavigateToAbstracts();
                            }
                          });
                        },
                        child: Row(
                          children: const [
                            Text(
                              'Create New',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.add,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (abstractProvider.isLoadingList)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (abstractProvider.myAbstracts.isEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.tileBorder, width: 1),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.description_outlined, color: AppColors.textLight, size: 24),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Abstracts Submitted Yet',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Submit your research paper abstracts here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CreateAbstractScreen()),
                              ).then((success) {
                                _fetchData();
                                if (success == true) {
                                  widget.onNavigateToAbstracts();
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'Submit Abstract',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                else ...[
                  GestureDetector(
                    onTap: () {
                      final abs = abstractProvider.myAbstracts.first;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AbstractDetailScreen(
                            abstractId: abs['abstract_id'].toString(),
                            initialTitle: (abs['abstract_title'] ?? '').toString(),
                            initialStatus: (abs['review_status'] ?? 'Submitted').toString(),
                            initialTopic: (abs['summit_title'] ?? 'Test Summit').toString(),
                            initialDate: (abs['submitted_at'] ?? '').toString(),
                          ),
                        ),
                      ).then((success) {
                        _fetchData();
                        if (success == true) {
                          widget.onNavigateToAbstracts();
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(16),
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
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEECF9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.description_outlined,
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
                                        color: const Color(0xFFEEECF9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'ID: ${abstractProvider.myAbstracts.first['abstract_id']}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStatusBadge(abstractProvider.myAbstracts.first['review_status'] ?? 'Submitted'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  (abstractProvider.myAbstracts.first['abstract_title'] ?? '').toString(),
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
                                  '${abstractProvider.myAbstracts.first['summit_title'] ?? 'Test Summit'} · ${TimeFormatter.formatString(abstractProvider.myAbstracts.first['submitted_at']?.toString() ?? '')}',
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
                  ),
                ],
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeBgColor;
    Color badgeTextColor;
    IconData? badgeIcon;

    if (status == 'Confirmed') {
      badgeBgColor = const Color(0xFFECFDF5);
      badgeTextColor = const Color(0xFF10B981);
      badgeIcon = Icons.check;
    } else if (status == 'Accepted') {
      badgeBgColor = const Color(0xFFEFF6FF);
      badgeTextColor = const Color(0xFF3B82F6);
      badgeIcon = Icons.check_circle_outline;
    } else if (status == 'Submitted' || status == 'Under Review') {
      badgeBgColor = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFFF59E0B);
      badgeIcon = Icons.access_time;
    } else {
      badgeBgColor = const Color(0xFFFEE2E2);
      badgeTextColor = const Color(0xFFEF4444);
      badgeIcon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeBgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            badgeIcon,
            color: badgeTextColor,
            size: 10,
          ),
          const SizedBox(width: 2),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: badgeTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard({
    required String title,
    required String date,
    required String time,
    required String location,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Confirmed',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildSessionDetailItem(Icons.calendar_month_outlined, '$time ($date)'),
          const SizedBox(height: 10),
          _buildSessionDetailItem(Icons.location_on_outlined, location),
        ],
      ),
    );
  }

  Widget _buildSessionDetailItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
