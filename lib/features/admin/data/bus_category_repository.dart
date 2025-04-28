import 'dart:convert';
import 'package:drive/config.dart';
import 'package:http/http.dart' as http;

class BusCategoryRepository {
  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/bus-categories');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }
}
