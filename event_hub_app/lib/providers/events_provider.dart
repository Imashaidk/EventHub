import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class EventsProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;
  NotificationService? _notificationService;

  List<EventModel> _events = [];
  List<EventModel> _organizerEvents = [];
  Set<String> _favoriteIds = {};
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  // Grid or List view toggle for advanced UI
  bool _isGridView = false;

  final List<String> _categories = [
    'All',
    'Technology',
    'Music',
    'Food & Drinks',
    'Sports',
    'Arts & Culture',
    'Business',
  ];

  EventsProvider(this._apiService, this._storageService) {
    _favoriteIds = _storageService.getFavoriteEventIds();
    loadEvents();
  }

  void setNotificationService(NotificationService notif) {
    _notificationService = notif;
  }

  List<EventModel> get events => _events;
  List<EventModel> get organizerEvents => _organizerEvents;
  Set<String> get favoriteIds => _favoriteIds;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isGridView => _isGridView;

  List<EventModel> get favoriteEvents {
    return _events.where((e) => _favoriteIds.contains(e.id)).toList();
  }

  List<EventModel> get featuredEvents {
    return _events.where((e) => e.featured).toList();
  }

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _apiService.getEvents(
        category: _selectedCategory,
        search: _searchQuery,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setCategory(String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    await loadEvents();
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    await loadEvents();
  }

  bool isFavorite(String eventId) {
    return _favoriteIds.contains(eventId);
  }

  Future<void> toggleFavorite(String eventId) async {
    await _storageService.toggleFavorite(eventId);
    _favoriteIds = _storageService.getFavoriteEventIds();
    notifyListeners();
  }

  // ----------------------------------------------------
  // ORGANIZER CRUD
  // ----------------------------------------------------
  Future<void> loadOrganizerEvents(String organizerId) async {
    try {
      _organizerEvents = await _apiService.getEvents(organizerId: organizerId);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> addEvent(EventModel event, String? token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final created = await _apiService.createEvent(event, token);
      if (created != null) {
        _events.insert(0, created);
        _organizerEvents.insert(0, created);

        _notificationService?.addNotification(
          title: 'Event Published',
          message: '"${created.title}" is now published and open for bookings!',
          type: NotificationType.eventUpdate,
          relatedId: created.id,
        );

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

  Future<bool> updateEvent(String id, Map<String, dynamic> updates, String? token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _apiService.updateEvent(id, updates, token);
      if (updated != null) {
        final idx = _events.indexWhere((e) => e.id == id);
        if (idx != -1) _events[idx] = updated;

        final orgIdx = _organizerEvents.indexWhere((e) => e.id == id);
        if (orgIdx != -1) _organizerEvents[orgIdx] = updated;

        _notificationService?.addNotification(
          title: 'Event Updated',
          message: 'Details for "${updated.title}" have been updated.',
          type: NotificationType.eventUpdate,
          relatedId: updated.id,
        );

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

  Future<bool> deleteEvent(String id, String? token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final eventToDelete = _events.firstWhere((e) => e.id == id, orElse: () => _organizerEvents.first);
      final success = await _apiService.deleteEvent(id, token);
      if (success) {
        _events.removeWhere((e) => e.id == id);
        _organizerEvents.removeWhere((e) => e.id == id);

        _notificationService?.addNotification(
          title: 'Event Removed',
          message: '"${eventToDelete.title}" was removed successfully.',
          type: NotificationType.eventUpdate,
        );

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

  // Update seats locally after booking/cancellation
  void updateEventSeats(String eventId, int seatChange) {
    final idx = _events.indexWhere((e) => e.id == eventId);
    if (idx != -1) {
      final current = _events[idx];
      final newSeats = (current.availableSeats + seatChange).clamp(0, current.totalSeats);
      _events[idx] = current.copyWith(availableSeats: newSeats);
      notifyListeners();
    }
  }
}
