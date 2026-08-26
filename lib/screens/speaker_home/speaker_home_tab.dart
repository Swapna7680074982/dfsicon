import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/photo_provider.dart';
import '../../providers/abstract_provider.dart';
import '../../providers/sessions_provider.dart';
import '../../providers/workshops_provider.dart';
import '../../widgets/venue_media_widget.dart';
import '../../widgets/venue_layouts_widget.dart';
import '../../widgets/event_qr_modal.dart';
import '../speaker_abstract/abstract_detail_screen.dart';
import '../speaker_sessions/speaker_session_detail_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../providers/notifications_provider.dart';
import '../profile/profile_screen.dart';
import '../workshops/workshops_list_screen.dart';
import '../workshops/workshop_details_screen.dart';
import '../explore/invited_speakers_screen.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(forceRefresh: false);
    });
  }

  Future<void> _fetchData({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final abstractProvider = Provider.of<AbstractProvider>(context, listen: false);
    final sessionsProvider = Provider.of<SessionsProvider>(context, listen: false);
    final workshopsProvider = Provider.of<WorkshopsProvider>(context, listen: false);

    try {
      await homeProvider.fetchSummits(auth.accessToken);
      final String summitId = homeProvider.summits.isNotEmpty
          ? homeProvider.summits.first['summit_id']?.toString() ?? '1'
          : '1';

      await Future.wait([
        sessionsProvider.fetchVenueAndHalls(summitId, auth.accessToken),
        sessionsProvider.fetchVenueLayouts(auth.accessToken, summitId: summitId),
        auth.fetchMyQr(forceRefresh: forceRefresh),
        abstractProvider.fetchMyTopics(auth.accessToken, forceRefresh: forceRefresh),
        sessionsProvider.fetchMyConfirmedSessions(auth.accessToken, forceRefresh: forceRefresh),
        workshopsProvider.fetchMyWorkshops(auth.accessToken, forceRefresh: forceRefresh),
      ]);
    } catch (e) {
      // Handle error gracefully
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
    final homeProvider = Provider.of<HomeProvider>(context);
    final photoProvider = Provider.of<PhotoProvider>(context);
    final abstractProvider = Provider.of<AbstractProvider>(context);
    final sessionsProvider = Provider.of<SessionsProvider>(context);
    final workshopsProvider = Provider.of<WorkshopsProvider>(context);
    final mySessions = sessionsProvider.mySessions;
    final myTopics = abstractProvider.myTopics;
    final myWorkshops = workshopsProvider.workshops;

    return WaterDropletsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: () async {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            await auth.refreshSessionToken();
            await _fetchData(forceRefresh: true);
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Consumer<NotificationsProvider>(
                                builder: (context, notifProvider, child) {
                                  return GestureDetector(
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
                                          if (notifProvider.unreadCount > 0)
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
                              '${mySessions.length} sessions confirmed',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Container(
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
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => EventQrModal(
                                userName: authProvider.userName,
                                eventName: homeProvider.eventInfo.name,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.qr_code_2_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'MY QR CODE',
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
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InvitedSpeakersScreen(),
                              ),
                            );
                          },
                          child: Container(
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
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.people_outline,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Invited Speakers',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'View summit speakers & keynotes',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textLight,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_isLoading) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80.0),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                ] else ...[
                  if (sessionsProvider.venueLayouts.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: VenueLayoutsWidget(
                        layouts: sessionsProvider.venueLayouts,
                        isLoading: sessionsProvider.isFetchingVenueLayouts,
                      ),
                    ),
                  ],
                  if (sessionsProvider.venueMedia.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: VenueMediaWidget(
                        mediaList: sessionsProvider.venueMedia,
                        title: 'Venue photos',
                      ),
                    ),
                  ],

                  // 1. MY SESSIONS SECTION
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
                                'VIEW ALL',
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
                  if (mySessions.isEmpty)
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
                              coordinatorName: s.coordinatorName ?? '',
                              coordinatorPhone: s.coordinatorPhone ?? '',
                              coordinatorEmail: s.coordinatorEmail ?? '',
                              description: s.description,
                              topicId: s.topicId,
                              assignmentId: s.assignmentId,
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

                // 2. MY TOPICS SECTION
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Topics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onNavigateToAbstracts,
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
                if (myTopics.isEmpty)
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
                        'No topics submitted yet',
                        style: TextStyle(color: AppColors.textLight, fontSize: 13),
                      ),
                    ),
                  )
                else ...[
                  GestureDetector(
                    onTap: () {
                      final abs = myTopics.first;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AbstractDetailScreen(
                            abstractId: abs['topic_id'].toString(),
                            initialTitle: (abs['title'] ?? '').toString(),
                            initialStatus: (abs['status'] ?? 'Approved').toString(),
                            initialTopic: (abs['category_of_submission'] ?? 'Oral Presentation').toString(),
                            initialDate: (abs['created_on'] ?? '').toString(),
                          ),
                        ),
                      ).then((_) {
                        _fetchData();
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
                            child: Builder(
                              builder: (context) {
                                final topicMap = myTopics.first;
                                final statusStr = (topicMap['status'] ?? '').toString();
                                final hallLoc = _getHallLocationString(topicMap, sessionsProvider);
                                final hasHall = statusStr == 'Confirmed' || hallLoc.isNotEmpty;

                                return Column(
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
                                            'ID: ${topicMap['topic_id']}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildStatusBadge(topicMap['status'] ?? 'Approved'),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      (topicMap['title'] ?? '').toString(),
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
                                      '${(topicMap['category_of_submission'] ?? 'Oral Presentation').toString()} · ${TimeFormatter.formatString(topicMap['created_on']?.toString() ?? '')}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                    if (hasHall) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.meeting_room_outlined,
                                            size: 14,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              hallLoc.isNotEmpty
                                                  ? (hallLoc.toLowerCase().startsWith('hall') ? hallLoc : 'Hall: $hallLoc')
                                                  : 'Hall: Confirmed & Assigned',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                );
                              },
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

                // 3. MY WORKSHOPS SECTION
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Workshops',
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
                            MaterialPageRoute(
                              builder: (context) => const WorkshopsListScreen(),
                            ),
                          );
                        },
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
                if (myWorkshops.isEmpty)
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
                        'No workshops registered yet',
                        style: TextStyle(color: AppColors.textLight, fontSize: 13),
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
                                        ws.workshopType.toUpperCase(),
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
                                  ws.workshopName.toUpperCase(),
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
                                  'VENUE: ${ws.venueName.toUpperCase()} · ${ws.city.toUpperCase()}',
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
          ],
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getHallLocationString(Map<String, dynamic> topicData, SessionsProvider? sessionsProv) {
    final sessDetails = (topicData['session_details'] is Map)
        ? topicData['session_details'] as Map<String, dynamic>
        : null;
    final hallMap = (topicData['hall'] is Map) ? topicData['hall'] as Map<String, dynamic> : null;

    final String hallLabel = sessDetails?['hall_label']?.toString() ??
        topicData['hall_label']?.toString() ??
        hallMap?['hall_label']?.toString() ??
        '';

    final String hallName = sessDetails?['hall_name']?.toString() ??
        topicData['hall_name']?.toString() ??
        hallMap?['hall_name']?.toString() ??
        (topicData['hall'] is String ? topicData['hall'].toString() : null) ??
        '';

    final String displayHall = hallLabel.trim().isNotEmpty ? hallLabel.trim() : hallName.trim();
    final String venueName = sessDetails?['venue_name']?.toString() ?? topicData['venue_name']?.toString() ?? '';

    if (displayHall.isNotEmpty && venueName.isNotEmpty) {
      return '$displayHall, $venueName';
    } else if (displayHall.isNotEmpty) {
      return displayHall;
    } else if (venueName.isNotEmpty) {
      return venueName;
    }

    if (sessionsProv != null) {
      final topicIdStr = topicData['topic_id']?.toString() ?? topicData['abstract_id']?.toString() ?? '';
      if (topicIdStr.isNotEmpty) {
        try {
          final match = sessionsProv.mySessions.firstWhere(
            (s) => s.topicId == topicIdStr || s.id.toString() == topicIdStr,
          );
          if (match.location.isNotEmpty) {
            return match.location;
          }
        } catch (_) {}
      }
    }

    return '';
  }

  Widget _buildStatusBadge(String status) {
    Color badgeBgColor;
    Color badgeTextColor;
    IconData? badgeIcon;

    if (status == 'Confirmed') {
      badgeBgColor = const Color(0xFFECFDF5);
      badgeTextColor = const Color(0xFF10B981);
      badgeIcon = Icons.check;
    } else {
      badgeBgColor = const Color(0xFFEFF6FF);
      badgeTextColor = const Color(0xFF3B82F6);
      badgeIcon = Icons.check_circle_outline;
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
          if (time.isNotEmpty || date.isNotEmpty) ...[
            const SizedBox(height: 18),
            _buildSessionDetailItem(
              Icons.calendar_month_outlined,
              time.isNotEmpty && date.isNotEmpty ? '$time ($date)' : '$time$date',
            ),
          ],
          if (location.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildSessionDetailItem(Icons.location_on_outlined, location),
          ],
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
