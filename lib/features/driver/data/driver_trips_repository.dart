import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config.dart';
import '../../auth/data/user_session.dart';

class DriverTripsRepository {
  static Future<List<Map<String, dynamic>>> fetchCurrentTrips() async {
    final token = UserSession.token;
    if (token == null) {
      throw Exception('Not authenticated');
    }
    final url = Uri.parse('${AppConfig.backendBaseUrl}/api/trips/my-trips/current');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Unexpected response format');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please log in again.');
    } else if (response.statusCode == 403) {
      throw Exception('Forbidden: You do not have permission.');
    } else {
      throw Exception('Failed to fetch current trips: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAllTrips() async {
    final token = UserSession.token;
    if (token == null) {
      throw Exception('Not authenticated');
    }
    final url = Uri.parse('${AppConfig.backendBaseUrl}/api/trips/my-trips');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Unexpected response format');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please log in again.');
    } else if (response.statusCode == 403) {
      throw Exception('Forbidden: You do not have permission.');
    } else {
      throw Exception('Failed to fetch all trips: ${response.statusCode}');
    }
  }

  static Future<bool> updateTripStatus({
    required int tripId,
    required String status,
    String? reason,
  }) async {
    final token = UserSession.token;
    if (token == null) {
      throw Exception('Not authenticated');
    }
    final url = Uri.parse('${AppConfig.backendBaseUrl}/api/trips/$tripId/driver-update');
    final body = <String, dynamic>{'tripStatus': status};
    if (status == 'teardown' && reason != null && reason.trim().isNotEmpty) {
      body['reason'] = reason.trim();
    }
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update trip status: ${response.statusCode}\n${response.body}');
    }
  }
}
