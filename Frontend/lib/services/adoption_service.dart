import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class AdoptionService {
  static Future<bool> createAdoption(Map<String, dynamic> payload, {String? token}) async {
    final uri = Uri.parse('$kApiBaseUrl/api/adoptions');
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    final resp = await http.post(uri, headers: headers, body: jsonEncode(payload));
    return resp.statusCode == 200 || resp.statusCode == 201;
  }
}
