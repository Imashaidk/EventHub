import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/events_provider.dart';
import 'providers/bookings_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Storage
  final storageService = await StorageService.init();
  final apiService = ApiService();
  final notificationService = NotificationService(storageService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(storageService)),
        ChangeNotifierProvider(create: (_) => notificationService),
        ChangeNotifierProvider(
          create: (_) {
            final auth = AuthProvider(apiService, storageService);
            auth.setNotificationService(notificationService);
            return auth;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final events = EventsProvider(apiService, storageService);
            events.setNotificationService(notificationService);
            return events;
          },
        ),
        ChangeNotifierProvider(
          create: (ctx) {
            final bookings = BookingsProvider(apiService);
            final events = ctx.read<EventsProvider>();
            bookings.setDependencies(notificationService, events);

            // If user session is already active, load their bookings
            final user = storageService.getSavedUser();
            final token = storageService.getToken();
            if (user != null) {
              bookings.loadUserBookings(user.id, token);
            }
            return bookings;
          },
        ),
      ],
      child: const EventHubApp(),
    ),
  );
}

class EventHubApp extends StatelessWidget {
  const EventHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'EventHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProv.themeMode,
      home: const MainNavigationScreen(),
    );
  }
}
