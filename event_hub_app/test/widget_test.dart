import 'package:flutter_test/flutter_test.dart';
import 'package:event_hub_app/models/event_model.dart';
import 'package:event_hub_app/models/booking_model.dart';
import 'package:event_hub_app/models/user_model.dart';

void main() {
  group('EventHub Model Serialization Tests', () {
    test('EventModel fromJson and toJson serialization', () {
      final json = {
        'id': 'evt_999',
        'title': 'Flutter Developer Summit',
        'description': 'Annual gathering of Flutter devs',
        'category': 'Technology',
        'date': '2026-11-10',
        'time': '10:00 AM',
        'location': 'Tech Park, San Jose',
        'price': 49.99,
        'availableSeats': 100,
        'totalSeats': 100,
        'organizerId': 'usr_org1',
        'organizerName': 'Google Developers',
        'image': 'https://example.com/img.jpg',
        'featured': true,
        'tags': ['flutter', 'dart'],
      };

      final event = EventModel.fromJson(json);
      expect(event.id, 'evt_999');
      expect(event.title, 'Flutter Developer Summit');
      expect(event.price, 49.99);
      expect(event.availableSeats, 100);
      expect(event.isSoldOut, false);

      final outJson = event.toJson();
      expect(outJson['title'], 'Flutter Developer Summit');
      expect(outJson['price'], 49.99);
    });

    test('BookingModel cancellation and status', () {
      final booking = BookingModel(
        id: 'bk_123',
        eventId: 'evt_1',
        eventTitle: 'Music Fest',
        eventDate: '2026-10-20',
        eventTime: '07:00 PM',
        eventLocation: 'City Arena',
        userId: 'usr_1',
        userName: 'Alex',
        userEmail: 'alex@test.com',
        ticketsCount: 2,
        ticketPrice: 50.0,
        totalPrice: 100.0,
        status: 'confirmed',
        bookingReference: 'EH-12345-AA',
      );

      expect(booking.isConfirmed, true);
      expect(booking.isCancelled, false);

      final cancelled = booking.copyWith(status: 'cancelled');
      expect(cancelled.isConfirmed, false);
      expect(cancelled.isCancelled, true);
    });

    test('UserModel role validation', () {
      final user = UserModel(
        id: 'usr_1',
        name: 'Alex Morgan',
        email: 'alex@eventhub.com',
        role: 'user',
      );
      expect(user.isOrganizer, false);

      final organizer = UserModel(
        id: 'usr_org1',
        name: 'Summit Host',
        email: 'org@eventhub.com',
        role: 'organizer',
      );
      expect(organizer.isOrganizer, true);
    });
  });
}
