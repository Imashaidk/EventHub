import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'events_provider.dart';

class BookingsProvider extends ChangeNotifier {
  final ApiService _apiService;
  NotificationService? _notificationService;
  EventsProvider? _eventsProvider;

  List<BookingModel> _userBookings = [];
  List<BookingModel> _eventBookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  BookingsProvider(this._apiService);

  void setDependencies(NotificationService notif, EventsProvider events) {
    _notificationService = notif;
    _eventsProvider = events;
  }

  List<BookingModel> get userBookings => _userBookings;
  List<BookingModel> get eventBookings => _eventBookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<BookingModel> get activeBookings =>
      _userBookings.where((b) => b.isConfirmed).toList();

  List<BookingModel> get cancelledBookings =>
      _userBookings.where((b) => b.isCancelled).toList();

  Future<void> loadUserBookings(String userId, [String? token]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userBookings = await _apiService.getUserBookings(userId, token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEventBookings(String eventId, [String? token]) async {
    _isLoading = true;
    notifyListeners();

    try {
      _eventBookings = await _apiService.getEventBookings(eventId, token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<BookingModel?> createBooking({
    required String eventId,
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
    required int ticketsCount,
    String? notes,
    String? token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.createBooking(
        eventId: eventId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        userPhone: userPhone,
        ticketsCount: ticketsCount,
        notes: notes,
        token: token,
      );

      if (res['success'] == true) {
        final booking = res['booking'] as BookingModel;
        _userBookings.insert(0, booking);

        // Deduct seats in EventsProvider
        _eventsProvider?.updateEventSeats(eventId, -ticketsCount);

        // Trigger notification
        _notificationService?.addNotification(
          title: 'Booking Confirmed! 🎉',
          message: 'Your booking for "${booking.eventTitle}" ($ticketsCount ticket${ticketsCount > 1 ? 's' : ''}) is confirmed. Ref: ${booking.bookingReference}',
          type: NotificationType.bookingConfirmed,
          relatedId: booking.id,
        );

        _isLoading = false;
        notifyListeners();
        return booking;
      } else {
        _errorMessage = res['message'] ?? 'Booking failed';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> cancelBooking(String bookingId, [String? token]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final idx = _userBookings.indexWhere((b) => b.id == bookingId);
      final booking = idx != -1 ? _userBookings[idx] : null;

      final success = await _apiService.cancelBooking(bookingId, token);
      if (success) {
        if (idx != -1 && booking != null) {
          _userBookings[idx] = booking.copyWith(
            status: 'cancelled',
            cancelledAt: DateTime.now(),
          );

          // Restore seats in EventsProvider
          _eventsProvider?.updateEventSeats(booking.eventId, booking.ticketsCount);

          // Trigger cancellation notification
          _notificationService?.addNotification(
            title: 'Booking Cancelled',
            message: 'Your booking for "${booking.eventTitle}" was cancelled.',
            type: NotificationType.bookingCancelled,
            relatedId: booking.id,
          );
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
