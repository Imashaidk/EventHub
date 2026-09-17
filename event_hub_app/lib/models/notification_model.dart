enum NotificationType {
  bookingConfirmed,
  bookingCancelled,
  eventReminder,
  eventUpdate,
  general
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  bool isRead;
  final String? relatedId; // eventId or bookingId

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.relatedId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    NotificationType parseType(String? t) {
      switch (t) {
        case 'bookingConfirmed':
          return NotificationType.bookingConfirmed;
        case 'bookingCancelled':
          return NotificationType.bookingCancelled;
        case 'eventReminder':
          return NotificationType.eventReminder;
        case 'eventUpdate':
          return NotificationType.eventUpdate;
        default:
          return NotificationType.general;
      }
    }

    return NotificationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: parseType(json['type'] as String?),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      relatedId: json['relatedId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'relatedId': relatedId,
    };
  }
}
