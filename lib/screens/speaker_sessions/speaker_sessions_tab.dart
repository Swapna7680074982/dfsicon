import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'speaker_session_detail_screen.dart';

class SpeakerSessionsTab extends StatefulWidget {
  const SpeakerSessionsTab({super.key});

  @override
  State<SpeakerSessionsTab> createState() => _SpeakerSessionsTabState();
}

class _SpeakerSessionsTabState extends State<SpeakerSessionsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _allSessions = [
    {
      'title': 'Digital Pathology Workflows',
      'date': 'March 16, 2026',
      'time': '02:00 - 03:30 PM',
      'location': 'Hall B - Conference Room',
      'tag': 'Digital Health',
      'coordinatorName': 'Mr. Arjun Mehta',
      'coordinatorPhone': '+91 98765 12345',
      'coordinatorEmail': 'arjun.mehta@dfisicon.org',
    },
    {
      'title': 'AI in Clinical Diagnostics',
      'date': 'March 15, 2026',
      'time': '09:00 - 10:30 AM',
      'location': 'Hall A - Auditorium',
      'tag': 'AI & Machine Learning',
      'coordinatorName': 'Ms. Priya Nair',
      'coordinatorPhone': '+91 98765 43210',
      'coordinatorEmail': 'priya.nair@dfisicon.org',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allSessions.where((s) {
      final title = s['title']!.toLowerCase();
      final tag = s['tag']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || tag.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Sessions',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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
                        hintText: 'Search sessions',
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
                      initialDate: DateTime(2026, 3, 15),
                      firstDate: DateTime(2026, 3, 1),
                      lastDate: DateTime(2026, 3, 31),
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
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No sessions found',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final s = filtered[index];
                      return _buildSessionCard(context, s);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, Map<String, String> s) {
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
          Row(
            children: [
              const Icon(Icons.local_offer_outlined, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                s['tag']!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            s['title']!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          _buildSessionDetailItem(Icons.calendar_month_outlined, s['date']!),
          const SizedBox(height: 10),
          _buildSessionDetailItem(Icons.access_time_outlined, s['time']!),
          const SizedBox(height: 10),
          _buildSessionDetailItem(Icons.location_on_outlined, s['location']!),
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
                    'Coord: ${s['coordinatorName']!}',
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
                        title: s['title']!,
                        date: s['date']!,
                        time: s['time']!,
                        location: s['location']!,
                        tag: s['tag']!,
                        coordinatorName: s['coordinatorName']!,
                        coordinatorPhone: s['coordinatorPhone']!,
                        coordinatorEmail: s['coordinatorEmail']!,
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
