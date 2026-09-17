import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import '../theme/app_theme.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return Icons.check_circle_rounded;
      case NotificationType.bookingCancelled:
        return Icons.cancel_rounded;
      case NotificationType.eventReminder:
        return Icons.alarm_rounded;
      case NotificationType.eventUpdate:
        return Icons.notifications_active_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _getColor(NotificationType type) {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return AppTheme.success;
      case NotificationType.bookingCancelled:
        return AppTheme.error;
      case NotificationType.eventReminder:
        return AppTheme.warning;
      case NotificationType.eventUpdate:
        return AppTheme.primary;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifService = context.watch<NotificationService>();
    final notifications = notifService.notifications;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (notifService.unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${notifService.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  if (notifications.isNotEmpty) ...[
                    TextButton(
                      onPressed: () => notifService.markAllAsRead(),
                      child: const Text('Mark Read', style: TextStyle(fontSize: 12)),
                    ),
                    TextButton(
                      onPressed: () => notifService.clearAll(),
                      child: const Text('Clear', style: TextStyle(fontSize: 12, color: AppTheme.error)),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const Divider(),
          // List
          if (notifications.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 48,
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  final color = _getColor(notif.type);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getIcon(notif.type), color: color, size: 20),
                    ),
                    title: Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          notif.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${notif.timestamp.hour}:${notif.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    trailing: notif.isRead
                        ? null
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                    onTap: () => notifService.markAsRead(notif.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
