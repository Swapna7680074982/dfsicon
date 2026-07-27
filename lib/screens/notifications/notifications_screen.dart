import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifications_provider.dart';

class NotificationsScreen extends StatefulWidget {
  final String? submittedAbstractTitle;

  const NotificationsScreen({super.key, this.submittedAbstractTitle});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationsProvider = Provider.of<NotificationsProvider>(context, listen: false);
    await notificationsProvider.fetchNotifications(authProvider.accessToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          Consumer<NotificationsProvider>(
            builder: (context, notifProvider, child) {
              if (notifProvider.unreadCount > 0) {
                return TextButton.icon(
                  onPressed: () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    notifProvider.markAsRead(authProvider.accessToken);
                  },
                  icon: const Icon(Icons.done_all, size: 18, color: AppColors.primary),
                  label: const Text(
                    'Mark all read',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.errorMessage != null && provider.notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: _loadNotifications,
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
                        const SizedBox(height: 12),
                        Text(
                          provider.errorMessage!,
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadNotifications,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final unreadList = provider.unreadNotifications;
          final readList = provider.readNotifications;
          final totalCount = provider.notifications.length;

          if (totalCount == 0) {
            return RefreshIndicator(
              onRefresh: _loadNotifications,
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none_outlined,
                            size: 40,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Notifications Yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'You will be notified here when updates arrive.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadNotifications,
            color: AppColors.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              children: [
                if (unreadList.isNotEmpty) ...[
                  Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    width: double.infinity,
                    child: Text(
                      '${unreadList.length} NEW NOTIFICATION${unreadList.length > 1 ? 'S' : ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  ...unreadList.map((item) => _buildNotificationModelTile(context, item, true)),
                ],
                if (readList.isNotEmpty) ...[
                  Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    width: double.infinity,
                    child: const Text(
                      'EARLIER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  ...readList.map((item) => _buildNotificationModelTile(context, item, false)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationModelTile(
    BuildContext context,
    NotificationModel item,
    bool isHighlight,
  ) {
    return InkWell(
      onTap: () {
        if (!item.isRead) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final notifProvider = Provider.of<NotificationsProvider>(context, listen: false);
          notifProvider.markAsRead(
            authProvider.accessToken,
            notificationId: item.notificationId,
          );
        }
      },
      child: Container(
        color: isHighlight ? const Color(0xFFF0F7FF) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE0DBFC),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                item.icon,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.timeAgo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: isHighlight ? const Color(0xFF475569) : AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead) ...[
              const SizedBox(width: 12),
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
