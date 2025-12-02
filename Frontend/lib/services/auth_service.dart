import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants.dart';

class AuthService {
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('$kApiBaseUrl/api/auth/login');
    final resp = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email, 'password': password}));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    // helpful debugging info
    try {
      final body = resp.body;
      // ignore: avoid_print
      print('AuthService.login failed: ${resp.statusCode} $body');
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> register(String name, String email, String password) async {
    final url = Uri.parse('$kApiBaseUrl/api/auth/register');
    final resp = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    try {
      final body = resp.body;
      // ignore: avoid_print
      print('AuthService.register failed: ${resp.statusCode} $body');
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> me(String token) async {
    final url = Uri.parse('$kApiBaseUrl/api/auth/me');
    final resp = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    try {
      final body = resp.body;
      // ignore: avoid_print
      print('AuthService.me failed: ${resp.statusCode} $body');
    } catch (_) {}
    return null;
  }
}
