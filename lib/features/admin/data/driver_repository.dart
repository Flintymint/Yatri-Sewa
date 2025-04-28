import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config.dart';

class DriverRepository {
  static Future<List<Map<String, dynamic>>> fetchAvailableDrivers({
    required String fromId,
    required String toId,
    required DateTime departureDate,
    required String jwtToken,
  }) async {
    final dateStr = '${departureDate.year.toString().padLeft(4, '0')}-${departureDate.month.toString().padLeft(2, '0')}-${departureDate.day.toString().padLeft(2, '0')}';
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/auth/drivers/available')
      .replace(queryParameters: {
        'fromId': fromId,
        'toId': toId,
        'departureDate': dateStr,
      });
    
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $jwtToken',
    });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
    }
    return [];
  }
}
