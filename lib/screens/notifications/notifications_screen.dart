import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class NotificationsScreen extends StatefulWidget {
  final String? submittedAbstractTitle;

  const NotificationsScreen({super.key, this.submittedAbstractTitle});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationItem> _newNotifications;
  late List<NotificationItem> _oldNotifications;

  @override
  void initState() {
    super.initState();

    _newNotifications = [
      if (widget.submittedAbstractTitle != null)
        NotificationItem(
          title: 'Abstract Submitted',
          message: 'Successfully submitted your abstract "${widget.submittedAbstractTitle}" for review.',
          time: 'Just now',
          icon: Icons.description_outlined,
          iconBg: const Color(0xFFE0F2FE),
          iconColor: const Color(0xFF0284C7),
          isNew: true,
        ),
      NotificationItem(
        title: 'Session Starting Soon',
        message: '"AI-Powered Diagnostics" starts in 15 minutes. Room: Hall A.',
        time: '8 min ago',
        icon: Icons.notifications_none_outlined,
        iconBg: const Color(0xFFE0DBFC),
        iconColor: AppColors.primary,
        isNew: true,
      ),
      NotificationItem(
        title: 'New Connection Request',
        message: 'Dr. Marcus Johnson wants to connect with you.',
        time: '25 min ago',
        icon: Icons.people_outline,
        iconBg: const Color(0xFFFCE7F3),
        iconColor: const Color(0xFFDB2777),
        isNew: true,
      ),
      NotificationItem(
        title: 'New Message',
        message: 'Dr. Sarah Chen: "Looking forward to our discussion! \u{1F60A}"',
        time: '42 min ago',
        icon: Icons.chat_bubble_outline,
        iconBg: const Color(0xFFF5F3FF),
        iconColor: const Color(0xFF7C3AED),
        isNew: true,
      ),
    ];

    _oldNotifications = [
      NotificationItem(
        title: 'Session Bookmarked',
        message: 'Successfully added "Value-Based Care" to your calendar.',
        time: '1 hr ago',
        icon: Icons.notifications_none_outlined,
        iconBg: const Color(0xFFE0DBFC),
        iconColor: AppColors.primary,
        isNew: false,
      ),
      NotificationItem(
        title: 'Exhibitor Demo Confirmed',
        message: 'MedCore Health confirmed your demo at Booth A-12 at 3:00 PM.',
        time: '2 hrs ago',
        icon: Icons.business_outlined,
        iconBg: const Color(0xFFD1FAE5),
        iconColor: const Color(0xFF059669),
        isNew: false,
      ),
      NotificationItem(
        title: 'Event Schedule Updated',
        message: 'The afternoon keynote has been moved to Hall A. Please check updated schedule.',
        time: '3 hrs ago',
        icon: Icons.settings_outlined,
        iconBg: const Color(0xFFF1F5F9),
        iconColor: const Color(0xFF475569),
        isNew: false,
      ),
      NotificationItem(
        title: 'Group Invite',
        message: 'You were added to "AI in Medicine Enthusiasts" by Dr. Emily Rodriguez.',
        time: 'Yesterday',
        icon: Icons.people_outline,
        iconBg: const Color(0xFFF5F3FF),
        iconColor: const Color(0xFF7C3AED),
        isNew: false,
      ),
      NotificationItem(
        title: 'Welcome to TechSummit 2026',
        message: 'Check in is now open. Collect your badge at the main entrance.',
        time: 'Yesterday',
        icon: Icons.settings_outlined,
        iconBg: const Color(0xFFF1F5F9),
        iconColor: const Color(0xFF475569),
        isNew: false,
      ),
    ];
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
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          if (_newNotifications.isNotEmpty) ...[
            Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              width: double.infinity,
              child: Text(
                '${_newNotifications.length} NEW NOTIFICATIONS',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
            ),
            ..._newNotifications.map((item) => _buildNotificationTile(item, true)),
          ],
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            width: double.infinity,
            child: const Text(
              'OLD',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
          ),
          ..._oldNotifications.map((item) => _buildNotificationTile(item, false)),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(NotificationItem item, bool isHighlight) {
    return Container(
      color: isHighlight ? const Color(0xFFF0F7FF) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.iconBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              item.icon,
              color: item.iconColor,
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.time,
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
                  item.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: isHighlight ? const Color(0xFF475569) : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (item.isNew) ...[
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
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool isNew;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.isNew,
  });
}
