import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/sessions_provider.dart';
import '../session_details/session_details_screen.dart';

class SessionsTab extends StatefulWidget {
  const SessionsTab({super.key});

  @override
  State<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends State<SessionsTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionsProvider = Provider.of<SessionsProvider>(context);
    final filteredSessions = sessionsProvider.filteredSessions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Sessions',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.tileBorder,
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.textLight, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                sessionsProvider.setSearchQuery(value);
                              },
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search sessions or speakers...',
                                hintStyle: TextStyle(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w400,
                                ),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Filter by Date calendar opened')),
                      );
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.tileBorder,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'All Sessions',
                      isSelected: !sessionsProvider.showOnlyBookmarked,
                      count: sessionsProvider.sessions.length,
                      onTap: () => sessionsProvider.setShowOnlyBookmarked(false),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Bookmarked',
                      isSelected: sessionsProvider.showOnlyBookmarked,
                      count: sessionsProvider.sessions.where((s) => s.isBookmarked).length,
                      icon: Icons.bookmark,
                      onTap: () => sessionsProvider.setShowOnlyBookmarked(true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filteredSessions.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                sessionsProvider.showOnlyBookmarked
                                    ? Icons.bookmark_border_rounded
                                    : Icons.search_off_rounded,
                                size: 48,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                sessionsProvider.showOnlyBookmarked
                                    ? 'No bookmarked sessions yet'
                                    : 'No sessions found matching "${sessionsProvider.searchQuery}"',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (sessionsProvider.showOnlyBookmarked) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Tap the bookmark icon on any session to save it here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredSessions.length,
                        itemBuilder: (context, index) {
                          final session = filteredSessions[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SessionDetailsScreen(session: session),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(18.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.tileBorder,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          session.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      GestureDetector(
                                        onTap: () {
                                          sessionsProvider.toggleBookmark(session.id);
                                        },
                                        child: Icon(
                                          session.isBookmarked
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                          color: session.isBookmarked
                                              ? AppColors.primary
                                              : AppColors.textLight,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: session.speakerBg,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          session.speakerInitials,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              session.speakerName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              session.speakerTitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Container(
                                    height: 1,
                                    color: AppColors.tileBorder,
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: AppColors.textLight),
                                      const SizedBox(width: 4),
                                      Text(
                                        session.time.split(' – ').first,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textLight),
                                      const SizedBox(width: 4),
                                      Text(
                                        session.location,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        height: 36,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            sessionsProvider.toggleAdded(session.id);
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: session.isAdded
                                                ? AppColors.primary
                                                : Colors.white,
                                            foregroundColor: session.isAdded
                                                ? Colors.white
                                                : AppColors.primary,
                                            side: BorderSide(
                                              color: AppColors.primary,
                                              width: 1.5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 14),
                                          ),
                                          child: Row(
                                            children: [
                                              if (session.isAdded) ...[
                                                const Icon(Icons.check, size: 12, color: Colors.white),
                                                const SizedBox(width: 4),
                                              ],
                                              Text(
                                                session.isAdded ? 'Added' : '+ Add',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: session.isAdded
                                                      ? Colors.white
                                                      : AppColors.primary,
                                                ),
                                              ),
                                            ],
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required int count,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(20) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.tileBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.primary : AppColors.textLight,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(30)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
