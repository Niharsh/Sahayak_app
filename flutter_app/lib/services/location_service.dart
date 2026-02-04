import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api.dart';

class LocationService {
  Future<List<String>> search(String q) async {
    final resp = await http.get(Uri.parse('$BASE_URL/locations/search?q=${Uri.encodeComponent(q)}'));
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      // expected array of strings
      return List<String>.from(data);
    }
    return [];
  }
}
