import 'dart:convert';
import 'package:drive/config.dart';
import 'package:http/http.dart' as http;

class TripRepository {
  static Future<Map<String, dynamic>?> fetchTrips({
    int page = 0,
    int size = 10,
    String? fromId,
    String? toId,
    String? busId,
    String? tripStatus,
    String? busDriverId,
    String? email,
    bool? bookedByUser,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (fromId != null && fromId.isNotEmpty) query['fromId'] = fromId;
    if (toId != null && toId.isNotEmpty) query['toId'] = toId;
    if (busId != null && busId.isNotEmpty) query['busId'] = busId;
    if (tripStatus != null && tripStatus.isNotEmpty) query['tripStatus'] = tripStatus;
    if (busDriverId != null && busDriverId.isNotEmpty) query['busDriverId'] = busDriverId;
    if (email != null && email.isNotEmpty) query['email'] = email;
    if (bookedByUser != null) query['bookedByUser'] = bookedByUser.toString();

    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/trips').replace(queryParameters: query);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> createTrip({
    required double price,
    String? tripStatus,
    required DateTime departureDateTime,
    required int busId,
    required String busDriverId,
    required String fromId,
    required String toId,
    required String jwtToken,
  }) async {
    final dateStr = '${departureDateTime.year.toString().padLeft(4, '0')}-${departureDateTime.month.toString().padLeft(2, '0')}-${departureDateTime.day.toString().padLeft(2, '0')}';
    final timeStr = '${departureDateTime.hour.toString().padLeft(2, '0')}:${departureDateTime.minute.toString().padLeft(2, '0')}:00';
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/trips');
    final bodyMap = {
      'price': price,
      'departureDate': dateStr,
      'departureTime': timeStr,
      'bus': { 'id': busId },
      'busDriver': { 'id': busDriverId },
      'from': { 'id': fromId },
      'to': { 'id': toId },
    };
    if (tripStatus != null) {
      bodyMap['tripStatus'] = tripStatus;
    }
    final body = json.encode(bodyMap);
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to create trip: ${response.body}');
    }
  }
}
