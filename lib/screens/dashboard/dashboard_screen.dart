import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/explore_provider.dart';
import '../../providers/sessions_provider.dart';
import '../../providers/workshops_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/abstract_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/exhibitor_provider.dart';
import '../../main.dart';
import 'home_tab.dart';
import 'sessions_tab.dart';
import 'network_tab.dart';
import 'explore_tab.dart';
import '../gallery/gallery_tab.dart';
import '../speaker_home/speaker_home_tab.dart';
import '../speaker_abstract/speaker_abstract_tab.dart';
import '../speaker_sessions/speaker_sessions_tab.dart';
import '../admin/admin_dashboard_tab.dart';
import '../exhibitor/exhibitor_portal_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  DateTime? _lastBackPressTime;
  String? _lastRoleCode;

  @override
  void initState() {
    super.initState();
    MyApp.resetRedirectFlag();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _lastRoleCode = auth.isAdmin
          ? 'AD'
          : (auth.isSpeaker ? 'SK' : (auth.isExhibitor ? 'EX' : 'DL'));
      _loadDashboardData(auth, forceRefresh: false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = Provider.of<AuthProvider>(context);
    final currentRole = auth.isAdmin
        ? 'AD'
        : (auth.isSpeaker ? 'SK' : (auth.isExhibitor ? 'EX' : 'DL'));
    if (_lastRoleCode != null && _lastRoleCode != currentRole) {
      _lastRoleCode = currentRole;
      _currentIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDashboardData(auth, forceRefresh: true);
      });
    }
  }

  Future<void> _loadDashboardData(AuthProvider auth, {bool forceRefresh = false}) async {
    if (!mounted) return;
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final exploreProvider = Provider.of<ExploreProvider>(context, listen: false);
    final sessionsProvider = Provider.of<SessionsProvider>(context, listen: false);
    final workshopsProvider = Provider.of<WorkshopsProvider>(context, listen: false);
    final notificationsProvider = Provider.of<NotificationsProvider>(context, listen: false);
    final abstractProvider = Provider.of<AbstractProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final exhibitorProvider = Provider.of<ExhibitorProvider>(context, listen: false);

    try {
      auth.registerDeviceToken();

      if (auth.isAdmin) {
        await adminProvider.fetchAllAdminData(auth.accessToken, forceRefresh: forceRefresh);
        return;
      }

      if (auth.isExhibitor) {
        auth.fetchMyQr(forceRefresh: forceRefresh);
        notificationsProvider.fetchNotifications(auth.accessToken, clearPrevious: false);
        final String summitId = homeProvider.summits.isNotEmpty
            ? homeProvider.summits.first['summit_id']?.toString() ?? '1'
            : '1';
        await Future.wait([
          exhibitorProvider.fetchAllExhibitorData(auth.accessToken, summitId: summitId, forceRefresh: forceRefresh),
          sessionsProvider.fetchConfirmedSessions(auth.accessToken, forceRefresh: forceRefresh),
          exploreProvider.fetchInvitedSpeakers(auth.accessToken),
          adminProvider.fetchDelegates(auth.accessToken, forceRefresh: forceRefresh),
          exploreProvider.fetchSponsors(summitId, auth.accessToken),
          exploreProvider.fetchSummitBooths(summitId, auth.accessToken),
          sessionsProvider.fetchVenueAndHalls(summitId, auth.accessToken),
          sessionsProvider.fetchVenueLayouts(auth.accessToken, summitId: summitId),
        ]);
        return;
      }

      auth.fetchMyQr(forceRefresh: forceRefresh);
      notificationsProvider.fetchNotifications(auth.accessToken, clearPrevious: false);

      // Start fetching sessions and workshops immediately in parallel
      final sessionsFutures = [
        sessionsProvider.fetchConfirmedSessions(auth.accessToken, forceRefresh: forceRefresh),
        if (auth.isSpeaker) ...[
          sessionsProvider.fetchMyConfirmedSessions(auth.accessToken, forceRefresh: forceRefresh),
          abstractProvider.fetchMyTopics(auth.accessToken, forceRefresh: forceRefresh),
        ],
        workshopsProvider.fetchMyWorkshops(auth.accessToken, forceRefresh: forceRefresh),
      ];

      // Concurrently fetch summits and summit-dependent data
      final summitFuture = () async {
        try {
          await homeProvider.fetchSummits(auth.accessToken);
          if (!mounted) return;
          final String summitId = homeProvider.summits.isNotEmpty
              ? homeProvider.summits.first['summit_id']?.toString() ?? '1'
              : '1';

          if (auth.isSpeaker) {
            await Future.wait([
              sessionsProvider.fetchVenueAndHalls(summitId, auth.accessToken),
              sessionsProvider.fetchVenueLayouts(auth.accessToken, summitId: summitId),
            ]);
          } else {
            await Future.wait([
              exploreProvider.fetchSponsors(summitId, auth.accessToken),
              exploreProvider.fetchSummitBooths(summitId, auth.accessToken),
              sessionsProvider.fetchVenueAndHalls(summitId, auth.accessToken),
              sessionsProvider.fetchVenueLayouts(auth.accessToken, summitId: summitId),
            ]);
          }
        } catch (_) {}
      }();

      await Future.wait([...sessionsFutures, summitFuture]);
    } catch (_) {
      // Gracefully catch any network or mapping exceptions so screens do not error
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isAdmin = auth.isAdmin;
    final isSpeaker = auth.isSpeaker;
    final isExhibitor = auth.isExhibitor;

    if (isAdmin) {
      return const AdminDashboardTab();
    }

    if (isExhibitor) {
      return const ExhibitorPortalScreen();
    }

    final List<Widget> tabs = isSpeaker
        ? [
            SpeakerHomeTab(
              onNavigateToSessions: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
              onNavigateToAbstracts: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            const SpeakerAbstractTab(),
            const SpeakerSessionsTab(),
            const NetworkTab(),
            const GalleryTab(),
          ]
        : [
            HomeTab(
              onNavigateToSessions: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            const SessionsTab(),
            const NetworkTab(),
            const ExploreTab(),
            const GalleryTab(),
          ];

    final List<BottomNavigationBarItem> barItems = isSpeaker
        ? const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.home_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.home, size: 24),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.description_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.description, size: 24),
              ),
              label: 'Topics',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.calendar_month_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.calendar_month, size: 24),
              ),
              label: 'Sessions',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.people_outline, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.people, size: 24),
              ),
              label: 'Networking',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.photo_library_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.photo_library, size: 24),
              ),
              label: 'Gallery',
            ),
          ]
        : const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.home_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.home, size: 24),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.calendar_month_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.calendar_month, size: 24),
              ),
              label: 'Sessions',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.people_outline, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.people, size: 24),
              ),
              label: 'Network',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.explore_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.explore, size: 24),
              ),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.photo_library_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.photo_library, size: 24),
              ),
              label: 'Gallery',
            ),
          ];

    if (_currentIndex >= tabs.length) {
      _currentIndex = 0;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // If not on Home tab (index 0), navigate back to Home tab (like WhatsApp)
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return;
        }

        // If already on Home tab, require double tap within 2 seconds to exit
        final now = DateTime.now();
        if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Press back again to exit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: const Color(0xFF1E293B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }

        // Second press within 2s -> exit the application cleanly
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: tabs,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.1,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
            items: barItems,
          ),
        ),
      ),
    );
  }
}
