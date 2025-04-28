import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:drive/config.dart';
import 'package:drive/features/auth/data/user_session.dart';

class ManageBusStopsPage extends StatefulWidget {
  const ManageBusStopsPage({super.key});

  @override
  State<ManageBusStopsPage> createState() => _ManageBusStopsPageState();
}

class _ManageBusStopsPageState extends State<ManageBusStopsPage> {
  List<dynamic> _busStops = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBusStops();
  }

  Future<void> _fetchBusStops() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final url = Uri.parse('${AppConfig.backendBaseUrl}/api/bus-stops');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _busStops = data is List ? data : [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch bus stops';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBusStop(dynamic busStopId) async {
    setState(() { _isLoading = true; });
    final token = UserSession.token;
    final headers = {
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final url = Uri.parse('${AppConfig.backendBaseUrl}/api/bus-stops/$busStopId');
    final response = await http.delete(url, headers: headers);
    if (response.statusCode == 204) {
      // Success, refresh list
      _fetchBusStops();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bus stop deleted'), backgroundColor: Colors.green)
      );
    } else {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete bus stop'), backgroundColor: Theme.of(context).colorScheme.error)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Manage Bus stops', textAlign: TextAlign.center),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: colorScheme.error)))
              : _busStops.isEmpty
                  ? Center(child: Text('No bus stops found', style: TextStyle(color: colorScheme.onSurface)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _busStops.length,
                      itemBuilder: (context, index) {
                        final stop = _busStops[index];
                        return Card(
                          color: colorScheme.surface,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.primary,
                              child: Icon(Icons.location_on, color: colorScheme.onPrimary),
                            ),
                            title: Text(
                              stop['displayName'] ?? 'Unnamed Stop',
                              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                            ),
                            subtitle: Text(
                              'Lat: ${stop['latitude']?.toStringAsFixed(5) ?? '-'} | Lng: ${stop['longitude']?.toStringAsFixed(5) ?? '-'}',
                              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: colorScheme.error),
                              tooltip: 'Delete',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Bus Stop'),
                                    content: Text('Are you sure you want to delete "${stop['displayName']}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: colorScheme.error),
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _deleteBusStop(stop['id']);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushReplacementNamed('/manage-bus-stops');
        },
        icon: Icon(Icons.add, color: colorScheme.onPrimary),
        label: Text('Add Bus Stops', style: TextStyle(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}
