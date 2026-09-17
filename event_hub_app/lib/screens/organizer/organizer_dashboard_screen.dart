import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/events_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'event_form_screen.dart';
import 'event_attendees_screen.dart';

class OrganizerDashboardScreen extends StatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  State<OrganizerDashboardScreen> createState() => _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user != null) {
      context.read<EventsProvider>().loadOrganizerEvents(user.id);
    }
  }

  void _confirmDelete(BuildContext context, EventModel event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: AppTheme.error),
            SizedBox(width: 8),
            Text('Remove Event?'),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete "${event.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final token = context.read<AuthProvider>().token;
              final success = await context.read<EventsProvider>().deleteEvent(
                    event.id,
                    token,
                  );
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event removed successfully')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final eventsProv = context.watch<EventsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter events belonging to organizer or show all if demo
    final myEvents = eventsProv.events.where((e) {
      if (auth.currentUser?.role == 'organizer') {
        return e.organizerId == auth.currentUser?.id || e.organizerId == 'usr_org1';
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              eventsProv.loadEvents();
              _loadEvents();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventFormScreen()),
          );
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Create Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: myEvents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy_rounded, size: 60, color: isDark ? Colors.white24 : Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No events published yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Tap "Create Event" to publish your first event listing.'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: myEvents.length,
              itemBuilder: (context, index) {
                final event = myEvents[index];
                final sold = event.totalSeats - event.availableSeats;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image & Title Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: Image.network(
                                  event.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppTheme.primary.withValues(alpha: 0.1),
                                    child: const Icon(Icons.event, color: AppTheme.primary),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      event.category,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    event.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${event.date} • ${event.location}',
                                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey[700]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Stats bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _infoColumn('Price', event.price == 0 ? 'Free' : '\$${event.price.toStringAsFixed(0)}'),
                              _infoColumn('Tickets Sold', '$sold / ${event.totalSeats}'),
                              _infoColumn('Remaining', '${event.availableSeats}',
                                  color: event.availableSeats > 0 ? AppTheme.success : AppTheme.error),
                            ],
                          ),
                        ),
                        const Divider(height: 20),

                        // Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // View Bookings
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EventAttendeesScreen(event: event),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.people_alt_rounded, size: 16),
                              label: const Text('Bookings', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Edit
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primary),
                              tooltip: 'Edit Event',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EventFormScreen(eventToEdit: event),
                                  ),
                                );
                              },
                            ),
                            // Delete
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppTheme.error),
                              tooltip: 'Delete Event',
                              onPressed: () => _confirmDelete(context, event),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _infoColumn(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
