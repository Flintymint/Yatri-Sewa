import 'dart:convert';
import 'package:drive/config.dart';
import 'package:http/http.dart' as http;
import 'package:drive/features/auth/data/user_session.dart';

class BookingRepository {
  static Future<Map<String, dynamic>?> bookSeat({required int tripId, required String seatLabel}) async {
    final token = UserSession.token;
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/bookings/book');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'tripId': tripId,
        'seatLabel': seatLabel,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to book seat: \\n${response.statusCode} ${response.body}');
    }
  }

  static Future<List<String>> fetchReservedSeats(int tripId) async {
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/bookings/reserved-seats?tripId=$tripId');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return List<String>.from(data);
      }
    }
    return [];
  }
}
