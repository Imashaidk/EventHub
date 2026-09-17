import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import 'storage_service.dart';

class NotificationService extends ChangeNotifier {
  final StorageService _storageService;
  List<NotificationModel> _notifications = [];

  NotificationService(this._storageService) {
    _loadNotifications();
  }

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _loadNotifications() {
    _notifications = _storageService.getNotifications();
    if (_notifications.isEmpty) {
      // Seed default welcome notifications
      _notifications = [
        NotificationModel(
          id: 'notif_welcome',
          title: 'Welcome to EventHub!',
          message: 'Discover upcoming live concerts, tech summits, and local sports events in your area.',
          type: NotificationType.general,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
      ];
      _storageService.saveNotifications(_notifications);
    }
    notifyListeners();
  }

  Future<NotificationModel> addNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? relatedId,
  }) async {
    final notif = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      relatedId: relatedId,
    );

    _notifications.insert(0, notif);
    await _storageService.saveNotifications(_notifications);
    notifyListeners();
    return notif;
  }

  void showNotificationBanner(BuildContext context, NotificationModel notif) {
    IconData iconData;
    Color iconColor;

    switch (notif.type) {
      case NotificationType.bookingConfirmed:
        iconData = Icons.check_circle_rounded;
        iconColor = const Color(0xFF10B981);
        break;
      case NotificationType.bookingCancelled:
        iconData = Icons.cancel_rounded;
        iconColor = const Color(0xFFEF4444);
        break;
      case NotificationType.eventReminder:
        iconData = Icons.alarm_rounded;
        iconColor = const Color(0xFFF59E0B);
        break;
      case NotificationType.eventUpdate:
        iconData = Icons.notifications_active_rounded;
        iconColor = const Color(0xFF6366F1);
        break;
      default:
        iconData = Icons.info_rounded;
        iconColor = const Color(0xFF3B82F6);
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1E1B4B),
        elevation: 6,
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notif.message,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> markAsRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      await _storageService.saveNotifications(_notifications);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (var n in _notifications) {
      n.isRead = true;
    }
    await _storageService.saveNotifications(_notifications);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _notifications.clear();
    await _storageService.saveNotifications(_notifications);
    notifyListeners();
  }
}
