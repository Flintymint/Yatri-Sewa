import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';
import '../../../config.dart';

class AuthRepository {
  static const String _baseUrl = '${AppConfig.backendBaseUrl}/api/auth';

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/login');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({'email': email, 'password': password});
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          UserSession.setToken(data['token']);
          return data;
        } else {
        }
      } else {
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
          'role': role,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; // Success
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Registration failed';
      }
    } catch (e) {
        return 'Registration failed';
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = UserSession.token;
      if (token == null) return null;
      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
