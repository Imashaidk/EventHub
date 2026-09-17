import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/events_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/event_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/notification_sheet.dart';
import '../details/event_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsProv = context.watch<EventsProvider>();
    final auth = context.watch<AuthProvider>();
    final notifService = context.watch<NotificationService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final events = eventsProv.events;
    final featured = eventsProv.featuredEvents;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => eventsProv.loadEvents(),
          child: CustomScrollView(
            slivers: [
              // Top Bar with Greeting and Notification Bell
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.isAuthenticated ? 'Hello, ${auth.currentUser!.name}' : 'Welcome to EventHub',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Explore Events',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      // Notification Bell with Badge
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.surfaceDark : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_none_rounded, size: 24),
                              onPressed: () => _openNotifications(context),
                            ),
                          ),
                          if (notifService.unreadCount > 0)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.accent,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                child: Center(
                                  child: Text(
                                    '${notifService.unreadCount}',
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => eventsProv.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Search events by name, topic, or venue...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  eventsProv.setSearchQuery('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),

              // Featured Events Banner (if not searching)
              if (_searchController.text.isEmpty && featured.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
                        child: Text(
                          'Featured Highlights',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: featured.length,
                          itemBuilder: (context, index) {
                            final item = featured[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EventDetailsScreen(eventId: item.id),
                                  ),
                                );
                              },
                              child: Container(
                                width: 290,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: NetworkImage(item.image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.8),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accent,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'FEATURED',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 14,
                                      left: 14,
                                      right: 14,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${item.date} • ${item.location}',
                                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              // Category Selector Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 18, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Categories',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            // List / Grid toggle
                            IconButton(
                              icon: Icon(
                                eventsProv.isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                                size: 20,
                                color: AppTheme.primary,
                              ),
                              tooltip: eventsProv.isGridView ? 'List View' : 'Grid View',
                              onPressed: () => eventsProv.toggleViewMode(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 44,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: eventsProv.categories.length,
                          itemBuilder: (context, index) {
                            final cat = eventsProv.categories[index];
                            return CategoryChip(
                              label: cat,
                              isSelected: eventsProv.selectedCategory == cat,
                              onTap: () => eventsProv.setCategory(cat),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Events List or Grid
              if (eventsProv.isLoading && events.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (events.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 56, color: isDark ? Colors.white24 : Colors.grey),
                          const SizedBox(height: 14),
                          const Text(
                            'No Events Found',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try clearing your search query or selecting a different category.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _searchController.clear();
                              eventsProv.setSearchQuery('');
                              eventsProv.setCategory('All');
                            },
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (eventsProv.isGridView)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => EventCard(event: events[index], isGrid: true),
                      childCount: events.length,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => EventCard(event: events[index], isGrid: false),
                      childCount: events.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
