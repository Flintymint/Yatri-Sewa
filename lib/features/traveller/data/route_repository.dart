import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteRepository {
  static const String _apiKey = '5b3ce3597851110001cf6248241270a900fb4495b3d140a5f7ee9859';
  static const String _baseUrl = 'https://api.openrouteservice.org/v2/directions/driving-car';

  static Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    final url = Uri.parse('$_baseUrl?api_key=$_apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['features'][0]['geometry']['coordinates'] as List;
      return coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
    }
    throw Exception('Failed to fetch route');
  }
}
