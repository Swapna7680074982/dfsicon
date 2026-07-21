import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/explore_provider.dart';
import '../../providers/sessions_provider.dart';
import '../../providers/workshops_provider.dart';
import '../../main.dart';
import 'home_tab.dart';
import 'sessions_tab.dart';
import 'network_tab.dart';
import 'explore_tab.dart';
import '../gallery/gallery_tab.dart';
import '../speaker_home/speaker_home_tab.dart';
import '../speaker_abstract/speaker_abstract_tab.dart';
import '../speaker_sessions/speaker_sessions_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    MyApp.resetRedirectFlag();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final exploreProvider = Provider.of<ExploreProvider>(context, listen: false);
      final sessionsProvider = Provider.of<SessionsProvider>(context, listen: false);
      final workshopsProvider = Provider.of<WorkshopsProvider>(context, listen: false);
      
      if (auth.isSpeaker) {
        await homeProvider.fetchSummits(auth.accessToken);
        final String summitId = homeProvider.summits.isNotEmpty
            ? homeProvider.summits.first['summit_id']?.toString() ?? '1'
            : '1';
        sessionsProvider.fetchVenueAndHalls(summitId, auth.accessToken);
        sessionsProvider.fetchMyConfirmedSessions(auth.accessToken);
      } else {
        // Delegate flow
        await homeProvider.fetchSummits(auth.accessToken);
        final String summitId = homeProvider.summits.isNotEmpty
            ? homeProvider.summits.first['summit_id']?.toString() ?? '1'
            : '1';
        exploreProvider.fetchSponsors(summitId, auth.accessToken);
        sessionsProvider.fetchVenueAndHalls(summitId, auth.accessToken);
        sessionsProvider.fetchConfirmedSessions(auth.accessToken);
        workshopsProvider.fetchMyWorkshops(auth.accessToken);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isSpeaker = auth.isSpeaker;

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
              label: 'My Sessions',
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

    return Scaffold(
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
    );
  }
}
