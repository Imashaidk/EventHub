import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';
  static const String _keyFavorites = 'favorite_event_ids';
  static const String _keyDarkMode = 'user_pref_dark_mode';
  static const String _keyNotifications = 'user_notifications';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Auth & Session
  Future<void> saveAuthSession(String token, UserModel user) async {
    await _prefs.setString(_keyToken, token);
    await _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  UserModel? getSavedUser() {
    final userJson = _prefs.getString(_keyUser);
    if (userJson == null) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAuthSession() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUser);
  }

  // Favorites
  Set<String> getFavoriteEventIds() {
    final list = _prefs.getStringList(_keyFavorites) ?? [];
    return list.toSet();
  }

  Future<void> toggleFavorite(String eventId) async {
    final favs = getFavoriteEventIds();
    if (favs.contains(eventId)) {
      favs.remove(eventId);
    } else {
      favs.add(eventId);
    }
    await _prefs.setStringList(_keyFavorites, favs.toList());
  }

  bool isFavorite(String eventId) {
    return getFavoriteEventIds().contains(eventId);
  }

  // User Preferences
  bool isDarkMode() {
    return _prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(_keyDarkMode, isDark);
  }

  // Notifications Storage
  List<NotificationModel> getNotifications() {
    final list = _prefs.getStringList(_keyNotifications) ?? [];
    return list.map((item) {
      try {
        return NotificationModel.fromJson(jsonDecode(item));
      } catch (_) {
        return null;
      }
    }).whereType<NotificationModel>().toList();
  }

  Future<void> saveNotifications(List<NotificationModel> notifications) async {
    final list = notifications.map((n) => jsonEncode(n.toJson())).toList();
    await _prefs.setStringList(_keyNotifications, list);
  }
}
