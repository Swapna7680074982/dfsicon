import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sessions_provider.dart';
import 'speaker_session_detail_screen.dart';
import '../../widgets/water_droplets_background.dart';

class SpeakerSessionsTab extends StatefulWidget {
  const SpeakerSessionsTab({super.key});

  @override
  State<SpeakerSessionsTab> createState() => _SpeakerSessionsTabState();
}

class _SpeakerSessionsTabState extends State<SpeakerSessionsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSessions(forceRefresh: false);
    });
  }

  Future<void> _fetchSessions({bool forceRefresh = false}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final sessions = Provider.of<SessionsProvider>(context, listen: false);
    await sessions.fetchMyConfirmedSessions(auth.accessToken, forceRefresh: forceRefresh);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionsProvider = Provider.of<SessionsProvider>(context);
    final mySessions = sessionsProvider.mySessions;

    final filtered = mySessions.where((s) {
      final title = s.title.toLowerCase();
      final tag = (s.keywords ?? 'Health Tech').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || tag.contains(query);
    }).toList();

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
            'My Sessions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'SEARCH SESSIONS',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: AppColors.textLight,
                          ),
                          prefixIcon: Icon(Icons.search, color: AppColors.textLight),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2026, 1, 1),
                        lastDate: DateTime(2026, 12, 31),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                onSurface: AppColors.textPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sessions filtered by date: ${date.day}/${date.month}/${date.year}'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'Scheduled Sessions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchSessions(forceRefresh: true),
                color: AppColors.primary,
                backgroundColor: Colors.white,
                child: sessionsProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    : filtered.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.4,
                                child: const Center(
                                  child: Text(
                                    'No sessions found',
                                    style: TextStyle(color: AppColors.textLight),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final s = filtered[index];
                              return _buildSessionCard(context, s);
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, SessionItem s) {
    final String tag = (s.keywords ?? 'Health Tech').split(',').first;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          if (tag.trim().isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.local_offer_outlined, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Text(
                s.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
          if (s.time.isNotEmpty || s.date.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildSessionDetailItem(
              Icons.calendar_month_outlined,
              s.time.isNotEmpty && s.date.isNotEmpty
                  ? '${s.time} (${s.date})'
                  : '${s.time}${s.date}',
            ),
          ],
          if (s.location.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildSessionDetailItem(Icons.location_on_outlined, s.location),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.tileBorder),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: AppColors.textLight),
                  const SizedBox(width: 6),
                  Text(
                    'Coord: Mr. Arjun Mehta',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
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
                        topicId: s.topicId,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: const [
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 10,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
