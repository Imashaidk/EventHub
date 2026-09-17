import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/bookings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class EventAttendeesScreen extends StatefulWidget {
  final EventModel event;

  const EventAttendeesScreen({super.key, required this.event});

  @override
  State<EventAttendeesScreen> createState() => _EventAttendeesScreenState();
}

class _EventAttendeesScreenState extends State<EventAttendeesScreen> {
  @override
  void initState() {
    super.initState();
    final token = context.read<AuthProvider>().token;
    context.read<BookingsProvider>().loadEventBookings(widget.event.id, token);
  }

  @override
  Widget build(BuildContext context) {
    final bookingsProv = context.watch<BookingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final attendees = bookingsProv.eventBookings;

    final totalTicketsBooked = attendees
        .where((b) => b.isConfirmed)
        .fold<int>(0, (sum, b) => sum + b.ticketsCount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Attendees'),
      ),
      body: Column(
        children: [
          // Event Summary Header Card
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.event.date} • ${widget.event.time}',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey[700]),
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('Capacity', '${widget.event.totalSeats} seats'),
                    _statItem('Booked', '$totalTicketsBooked seats', color: AppTheme.primary),
                    _statItem('Available', '${widget.event.availableSeats} seats',
                        color: widget.event.availableSeats > 0 ? AppTheme.success : AppTheme.error),
                  ],
                ),
              ],
            ),
          ),

          // Attendees List
          Expanded(
            child: bookingsProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : attendees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline_rounded, size: 48, color: isDark ? Colors.white24 : Colors.grey),
                            const SizedBox(height: 12),
                            const Text('No bookings recorded for this event yet.', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: attendees.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final booking = attendees[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.cardDark : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                                  child: Text(
                                    booking.userName.isNotEmpty ? booking.userName[0].toUpperCase() : 'U',
                                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        booking.userName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        booking.userEmail,
                                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey[700]),
                                      ),
                                      if (booking.userPhone.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          booking.userPhone,
                                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey[500]),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: booking.isConfirmed
                                            ? AppTheme.success.withValues(alpha: 0.15)
                                            : AppTheme.error.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${booking.ticketsCount} Ticket${booking.ticketsCount > 1 ? 's' : ''}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: booking.isConfirmed ? AppTheme.success : AppTheme.error,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      booking.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: booking.isConfirmed ? AppTheme.success : AppTheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
        ),
      ],
    );
  }
}
