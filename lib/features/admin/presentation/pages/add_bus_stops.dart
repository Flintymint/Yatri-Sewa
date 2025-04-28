import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:drive/features/admin/presentation/pages/manage_bus_stops.dart';
import 'package:drive/config.dart'; // Correct import for AppConfig
import 'package:logger/logger.dart';
import 'package:drive/features/auth/data/user_session.dart';

class AddBusStopsPage extends StatefulWidget {
  const AddBusStopsPage({super.key});

  @override
  State<AddBusStopsPage> createState() => _AddBusStopsPageState();
}

class _AddBusStopsPageState extends State<AddBusStopsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _suggestions = [];
  LatLng? _selectedLocation;
  bool _isLoading = false;
  String? _error;
  final Logger _logger = Logger();

  static const LatLng _nepalCenter = LatLng(28.3949, 84.1240);
  static const double _nepalMinLat = 26.347, _nepalMaxLat = 30.447;
  static const double _nepalMinLng = 80.058, _nepalMaxLng = 88.201;

  Future<void> _searchLocation(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent('$query, Nepal')}&format=json&addressdetails=1&limit=5&countrycodes=np',
      );
      final response = await http.get(url, headers: {'User-Agent': 'bus-app/1.0'});
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _suggestions = data;
        });
      } else {
        setState(() {
          _error = 'Error searching location';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectSuggestion(dynamic suggestion) {
    final lat = double.tryParse(suggestion['lat'] ?? '');
    final lon = double.tryParse(suggestion['lon'] ?? '');
    if (lat != null && lon != null) {
      setState(() {
        _selectedLocation = LatLng(lat, lon);
        _searchController.text = suggestion['display_name'] ?? '';
        _suggestions = [];
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng latlng) {
    // Only allow marker within Nepal bounds
    if (latlng.latitude >= _nepalMinLat && latlng.latitude <= _nepalMaxLat &&
        latlng.longitude >= _nepalMinLng && latlng.longitude <= _nepalMaxLng) {
      setState(() {
        _selectedLocation = latlng;
      });
    }
  }

  Future<void> _setBusStop() async {
    _logger.i('Set Bus Stop button pressed.');
    if (_selectedLocation == null) return;
    setState(() { _isLoading = true; });
    final url = Uri.parse('${AppConfig.backendBaseUrl}/api/bus-stops');
    final nowUtc = DateTime.now().toUtc();
    final isoString = nowUtc.toIso8601String();
    final msMatch = RegExp(r'^(.*?\.\d{3})').firstMatch(isoString);
    final msPart = msMatch != null ? msMatch.group(1)! : isoString;
    final createdAt = msPart.endsWith('Z') ? msPart : '${msPart}Z';
    final displayName = _searchController.text.split(',').first.trim();
    final busStop = {
      'latitude': _selectedLocation!.latitude,
      'longitude': _selectedLocation!.longitude,
      'displayName': displayName,
      'createdAt': createdAt,
    };
    final token = UserSession.token;
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    _logger.i('Current user info:');
    _logger.i('UserSession.token: ${UserSession.token}');
    _logger.i('UserSession.currentUser: ${UserSession.currentUser}');
    _logger.i('UserSession.role: ${UserSession.role}');
    _logger.i('Sending POST to: $url');
    _logger.i('Bus stop payload: $busStop');
    _logger.i('Headers: $headers');
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(busStop),
      );
      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bus stop set at: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}')),
        );
        setState(() {
          _selectedLocation = null;
          _searchController.clear();
        });
      } else {
        _logger.w('Failed to add bus stop: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add bus stop: ${response.body}'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } catch (e) {
      _logger.e('Error adding bus stop: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ManageBusStopsPage()),
            );
          },
        ),
        title: const Text('Add bus stops'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search location in Nepal...',
                                hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              onChanged: null,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                minimumSize: const Size(44, 44),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      final query = _searchController.text.trim();
                                      if (query.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please enter a location to search.')),
                                        );
                                        return;
                                      }
                                      _searchLocation(query);
                                    },
                              child: const Icon(Icons.search, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_suggestions.isNotEmpty)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                      ),
                      child: Material(
                        elevation: 4,
                        color: Theme.of(context).colorScheme.surface,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _suggestions.length,
                          itemBuilder: (context, idx) {
                            final s = _suggestions[idx];
                            return ListTile(
                              title: Text(s['display_name'] ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                              onTap: _isLoading ? null : () => _selectSuggestion(s),
                              hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            );
                          },
                        ),
                      ),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  Expanded(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _nepalCenter,
                        initialZoom: 7,
                        onTap: _isLoading ? null : _onMapTap,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.drive',
                        ),
                        if (_selectedLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _selectedLocation!,
                                width: 40,
                                height: 40,
                                child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.error, size: 40),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: _selectedLocation == null || _isLoading ? null : _setBusStop,
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Set bus stop'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
