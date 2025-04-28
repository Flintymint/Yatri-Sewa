import 'dart:convert';
import 'package:drive/config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Added import for DateFormat

class TravellerTripRepository {
  static Future<List<Map<String, dynamic>>> fetchTrips({String? fromId, String? toId, DateTime? date}) async {
    final query = <String, String>{};
    if (fromId != null && fromId.isNotEmpty) query['fromId'] = fromId;
    if (toId != null && toId.isNotEmpty) query['toId'] = toId;
    if (date != null) query['date'] = DateFormat('yyyy-MM-dd').format(date);
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/trips').replace(queryParameters: query);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map && data['content'] is List) {
        return List<Map<String, dynamic>>.from(data['content']);
      }
    }
    return [];
  }

}
