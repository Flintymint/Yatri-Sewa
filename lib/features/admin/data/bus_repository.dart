import 'dart:convert';
import 'package:drive/config.dart';
import 'package:http/http.dart' as http;

class BusRepository {
  static Future<List<Map<String, dynamic>>> fetchBuses() async {
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/buses/search?available=true');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
    }
    return [];
  }
}
