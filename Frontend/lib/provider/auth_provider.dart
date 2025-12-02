import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;

  Future<void> loadFromStorage() async {
    final sp = await SharedPreferences.getInstance();
    final t = sp.getString('auth_token');
    if (t != null) {
      _token = t;
      // Try to fetch current user from backend
      final data = await AuthService.me(_token!);
      if (data != null && data['user'] != null) {
        _user = Map<String, dynamic>.from(data['user']);
      }
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    final res = await AuthService.login(email, password);
    if (res != null && res['token'] != null) {
      _token = res['token'];
      _user = res['user'];
      final sp = await SharedPreferences.getInstance();
      await sp.setString('auth_token', _token!);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    final res = await AuthService.register(name, email, password);
    if (res != null && res['token'] != null) {
      _token = res['token'];
      _user = res['user'];
      final sp = await SharedPreferences.getInstance();
      await sp.setString('auth_token', _token!);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final sp = await SharedPreferences.getInstance();
    await sp.remove('auth_token');
    notifyListeners();
  }
}
