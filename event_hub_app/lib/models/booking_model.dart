class BookingModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String eventImage;
  final String eventDate;
  final String eventTime;
  final String eventLocation;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final int ticketsCount;
  final double ticketPrice;
  final double totalPrice;
  final String status; // 'confirmed', 'cancelled'
  final String bookingReference;
  final String notes;
  final DateTime? createdAt;
  final DateTime? cancelledAt;

  BookingModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    this.eventImage = '',
    required this.eventDate,
    required this.eventTime,
    required this.eventLocation,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone = '',
    required this.ticketsCount,
    required this.ticketPrice,
    required this.totalPrice,
    this.status = 'confirmed',
    required this.bookingReference,
    this.notes = '',
    this.createdAt,
    this.cancelledAt,
  });

  bool get isCancelled => status == 'cancelled';
  bool get isConfirmed => status == 'confirmed';

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String? ?? '',
      eventId: json['eventId'] as String? ?? '',
      eventTitle: json['eventTitle'] as String? ?? '',
      eventImage: json['eventImage'] as String? ?? '',
      eventDate: json['eventDate'] as String? ?? '',
      eventTime: json['eventTime'] as String? ?? '',
      eventLocation: json['eventLocation'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userEmail: json['userEmail'] as String? ?? '',
      userPhone: json['userPhone'] as String? ?? '',
      ticketsCount: (json['ticketsCount'] as num?)?.toInt() ?? 1,
      ticketPrice: (json['ticketPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'confirmed',
      bookingReference: json['bookingReference'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.tryParse(json['cancelledAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventImage': eventImage,
      'eventDate': eventDate,
      'eventTime': eventTime,
      'eventLocation': eventLocation,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'ticketsCount': ticketsCount,
      'ticketPrice': ticketPrice,
      'totalPrice': totalPrice,
      'status': status,
      'bookingReference': bookingReference,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? eventId,
    String? eventTitle,
    String? eventImage,
    String? eventDate,
    String? eventTime,
    String? eventLocation,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    int? ticketsCount,
    double? ticketPrice,
    double? totalPrice,
    String? status,
    String? bookingReference,
    String? notes,
    DateTime? createdAt,
    DateTime? cancelledAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      eventImage: eventImage ?? this.eventImage,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      eventLocation: eventLocation ?? this.eventLocation,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      ticketsCount: ticketsCount ?? this.ticketsCount,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      bookingReference: bookingReference ?? this.bookingReference,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
}
