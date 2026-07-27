import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dfsicon/domain/api_service.dart';
import 'package:dfsicon/utils/custom_logger.dart';
import '../main.dart';

class NotificationModel {
  final String notificationId;
  final String userId;
  final String? templateKey;
  final String title;
  final String body;
  final String? relatedType;
  final String? relatedId;
  final bool isRead;
  final String sendStatus;
  final String createdBy;
  final String createdAt;
  final String sentAt;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    this.templateKey,
    required this.title,
    required this.body,
    this.relatedType,
    this.relatedId,
    required this.isRead,
    required this.sendStatus,
    required this.createdBy,
    required this.createdAt,
    required this.sentAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawIsRead = json['is_read'];
    final bool parsedIsRead = rawIsRead == '1' || rawIsRead == 1 || rawIsRead == true;

    return NotificationModel(
      notificationId: json['notification_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      templateKey: json['template_key']?.toString(),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      relatedType: json['related_type']?.toString(),
      relatedId: json['related_id']?.toString(),
      isRead: parsedIsRead,
      sendStatus: json['send_status']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      sentAt: json['sent_at']?.toString() ?? '',
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      notificationId: notificationId,
      userId: userId,
      templateKey: templateKey,
      title: title,
      body: body,
      relatedType: relatedType,
      relatedId: relatedId,
      isRead: isRead ?? this.isRead,
      sendStatus: sendStatus,
      createdBy: createdBy,
      createdAt: createdAt,
      sentAt: sentAt,
    );
  }

  String get timeAgo {
    if (createdAt.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(createdAt.replaceAll(' ', 'T'));
      final Duration diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hr${diff.inHours > 1 ? 's' : ''} ago';
      if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return createdAt;
    }
  }

  IconData get icon {
    final lowerTitle = title.toLowerCase();
    final lowerType = (relatedType ?? '').toLowerCase();
    if (lowerTitle.contains('abstract') || lowerType.contains('abstract')) {
      return Icons.description_outlined;
    }
    if (lowerTitle.contains('session') || lowerType.contains('session')) {
      return Icons.notifications_none_outlined;
    }
    if (lowerTitle.contains('connection') || lowerTitle.contains('invite') || lowerType.contains('user')) {
      return Icons.people_outline;
    }
    if (lowerTitle.contains('message') || lowerType.contains('chat')) {
      return Icons.chat_bubble_outline;
    }
    if (lowerTitle.contains('exhibitor') || lowerTitle.contains('booth')) {
      return Icons.business_outlined;
    }
    return Icons.notifications_none_outlined;
  }
}

class NotificationsProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();

  void clear() {
    _notifications = [];
    _unreadCount = 0;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchNotifications(String accessToken, {bool clearPrevious = true}) async {
    if (accessToken.isEmpty) {
      _errorMessage = 'No access token found';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    if (clearPrevious) {
      _notifications = [];
      _unreadCount = 0;
    }
    notifyListeners();

    try {
      final response = await ApiService.fetchMyNotifications(accessToken: accessToken);

      if (response.statusCode == 401) {
        CustomLogger.logError('Notifications API: Unauthorized (401)', '401 Unauthorized');
        MyApp.redirectToLogin();
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['status'] == true) {
          dynamic dataObj = body['data'];
          if (dataObj is Map<String, dynamic> && dataObj.containsKey('data')) {
            dataObj = dataObj['data'];
          }

          List<NotificationModel> loadedList = [];
          if (dataObj is Map<String, dynamic>) {
            final rawNotifications = dataObj['notifications'];
            if (rawNotifications is List) {
              loadedList = rawNotifications
                  .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
                  .toList();
            }

            final rawUnread = dataObj['unread_count'];
            if (rawUnread != null) {
              _unreadCount = int.tryParse(rawUnread.toString()) ?? 0;
            } else {
              _unreadCount = loadedList.where((n) => !n.isRead).length;
            }
          } else if (dataObj is List) {
            loadedList = dataObj
                .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
                .toList();
            _unreadCount = loadedList.where((n) => !n.isRead).length;
          }

          _notifications = loadedList;
          _isLoading = false;
          notifyListeners();
          return;
        } else {
          _errorMessage = body['message'] ?? 'Failed to fetch notifications';
        }
      } else {
        _errorMessage = 'Server error (${response.statusCode})';
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch Notifications Error', e, stack);
      _errorMessage = 'Failed to load notifications';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markAsRead(String accessToken, {String? notificationId}) async {
    if (accessToken.isEmpty) return false;

    // Optimistic UI update
    if (notificationId != null && notificationId.isNotEmpty) {
      final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        if (_unreadCount > 0) _unreadCount--;
        notifyListeners();
      }
    } else {
      // Mark all as read
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    }

    try {
      final response = await ApiService.markNotificationRead(
        accessToken: accessToken,
        notificationId: notificationId,
      );

      if (response.statusCode == 401) {
        CustomLogger.logError('Mark Notification Read API: Unauthorized (401)', '401 Unauthorized');
        MyApp.redirectToLogin();
        return false;
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['status'] == true) {
          return true;
        }
      }
    } catch (e, stack) {
      CustomLogger.logError('Mark Notification Read Error', e, stack);
    }
    return false;
  }
}
