import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:drive/config.dart';

class BusStopRepository {
  static Future<List<Map<String, dynamic>>> fetchBusStops() async {
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/bus-stops');
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
