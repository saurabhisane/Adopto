import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class PetService {
  static Future<List<Map<String, dynamic>>?> fetchPets({String? category}) async {
    var uri = Uri.parse('$kApiBaseUrl/api/pets');
    if (category != null && category.isNotEmpty && category != 'All') {
      uri = uri.replace(queryParameters: {'category': category});
    }
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return null;
  }

  static Future<bool> createPet(Map<String, dynamic> payload, {String? token}) async {
    final uri = Uri.parse('$kApiBaseUrl/api/pets');
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final resp = await http.post(uri, headers: headers, body: jsonEncode(payload));
    return resp.statusCode == 200 || resp.statusCode == 201;
  }
}
