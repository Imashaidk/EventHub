import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookings_provider.dart';
import '../providers/events_provider.dart';
import 'home/home_screen.dart';
import 'favorites/favorites_screen.dart';
import 'bookings/my_bookings_screen.dart';
import 'organizer/organizer_dashboard_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    FavoritesScreen(),
    MyBookingsScreen(),
    OrganizerDashboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bookingsProv = context.watch<BookingsProvider>();
    final eventsProv = context.watch<EventsProvider>();
    final activeBookingsCount = bookingsProv.activeBookings.length;
    final favCount = eventsProv.favoriteIds.length;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore_rounded),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: favCount > 0,
              label: Text('$favCount'),
              child: const Icon(Icons.favorite_border_rounded),
            ),
            activeIcon: Badge(
              isLabelVisible: favCount > 0,
              label: Text('$favCount'),
              child: const Icon(Icons.favorite_rounded),
            ),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: activeBookingsCount > 0,
              label: Text('$activeBookingsCount'),
              child: const Icon(Icons.confirmation_number_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: activeBookingsCount > 0,
              label: Text('$activeBookingsCount'),
              child: const Icon(Icons.confirmation_number_rounded),
            ),
            label: 'Bookings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.business_center_outlined),
            activeIcon: Icon(Icons.business_center_rounded),
            label: 'Organizer',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
