import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? _user;
  String? _token;
  AuthStatus _status = AuthStatus.uninitialized;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  String? get token => _token;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _tryAutoLogin();
  }

  // Check secure storage on app startup for an existing token
  Future<void> _tryAutoLogin() async {
    _status = AuthStatus.loading;
    notifyListeners();

    _token = await _storage.read(key: 'auth_token');

    if (_token != null) {
      final fetchedUser = await _authService.getMe(_token!);
      if (fetchedUser != null) {
        _user = fetchedUser;
        _status = AuthStatus.authenticated;
      } else {
        // Token expired or invalid
        await logout();
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  // Register user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
    );

    if (result['success'] == true) {
      _token = result['token'];
      _user = result['user'];
      await _storage.write(key: 'auth_token', value: _token);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Registration failed';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(
      email: email,
      password: password,
    );

    if (result['success'] == true) {
      _token = result['token'];
      _user = result['user'];
      await _storage.write(key: 'auth_token', value: _token);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Invalid credentials';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    if (_token != null) {
      await _authService.logout(_token!);
    }

    _user = null;
    _token = null;
    await _storage.delete(key: 'auth_token');
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
