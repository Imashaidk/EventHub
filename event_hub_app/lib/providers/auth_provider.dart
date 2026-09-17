import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;
  NotificationService? _notificationService;

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._apiService, this._storageService) {
    _loadPersistedUser();
  }

  void setNotificationService(NotificationService notif) {
    _notificationService = notif;
  }

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _loadPersistedUser() {
    _currentUser = _storageService.getSavedUser();
    _token = _storageService.getToken();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.login(email: email.trim(), password: password);
      if (res['success'] == true) {
        _token = res['token'];
        _currentUser = res['user'] as UserModel;
        await _storageService.saveAuthSession(_token!, _currentUser!);

        _notificationService?.addNotification(
          title: 'Welcome Back!',
          message: 'Logged in successfully as ${_currentUser!.name}.',
          type: NotificationType.general,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
        phone: phone?.trim(),
        role: role ?? 'user',
      );

      if (res['success'] == true) {
        _token = res['token'];
        _currentUser = res['user'] as UserModel;
        await _storageService.saveAuthSession(_token!, _currentUser!);

        _notificationService?.addNotification(
          title: 'Account Created!',
          message: 'Welcome to EventHub, ${_currentUser!.name}. Start discovering events!',
          type: NotificationType.general,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? avatar,
    String? role,
  }) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (bio != null) updates['bio'] = bio;
      if (avatar != null) updates['avatar'] = avatar;
      if (role != null) updates['role'] = role;

      final updated = await _apiService.updateProfile(_currentUser!.id, updates, _token);
      if (updated != null) {
        _currentUser = updated;
        await _storageService.saveAuthSession(_token ?? 'token', _currentUser!);
      } else {
        // Local update fallback
        _currentUser = _currentUser!.copyWith(
          name: name,
          phone: phone,
          bio: bio,
          avatar: avatar,
          role: role,
        );
        await _storageService.saveAuthSession(_token ?? 'token', _currentUser!);
      }

      _notificationService?.addNotification(
        title: 'Profile Updated',
        message: 'Your profile changes have been saved.',
        type: NotificationType.general,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final name = _currentUser?.name ?? 'User';
    _currentUser = null;
    _token = null;
    await _storageService.clearAuthSession();

    _notificationService?.addNotification(
      title: 'Logged Out',
      message: 'Goodbye $name, you have been safely logged out.',
      type: NotificationType.general,
    );

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
