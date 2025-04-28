import 'dart:convert';
import 'package:drive/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:drive/features/traveller/presentation/pages/trip_map_page.dart';

class CheckTripStatusPage extends StatefulWidget {
  const CheckTripStatusPage({Key? key}) : super(key: key);

  @override
  State<CheckTripStatusPage> createState() => _CheckTripStatusPageState();
}

class _CheckTripStatusPageState extends State<CheckTripStatusPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;
  String? _error;
  List<dynamic> _trips = [];

  Future<void> _fetchTrips() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() { _error = 'Please enter an email.'; });
      return;
    }
    setState(() { _loading = true; _error = null; _trips = []; });
    try {
      final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/bookings/by-email?email=$email');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() { _trips = data is List ? data : []; });
      } else {
        setState(() { _error = 'No trips found or error occurred.'; });
      }
    } catch (e) {
      setState(() { _error = 'Error: ${e.toString()}'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Check Trip Status'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Enter user email',
                      labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      fillColor: colorScheme.surface,
                      filled: true,
                    ),
                    onSubmitted: (_) => _fetchTrips(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _fetchTrips,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Search'),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: colorScheme.error)),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: _trips.isEmpty
                  ? Center(child: Text('No trips found.', style: TextStyle(color: colorScheme.onSurface)))
                  : ListView.builder(
                      itemCount: _trips.length,
                      itemBuilder: (context, index) {
                        final trip = _trips[index];
                        final from = trip['from']?['displayName'] ?? '-';
                        final to = trip['to']?['displayName'] ?? '-';
                        final status = trip['tripStatus'] ?? '-';
                        final busNumber = trip['bus']?['busNumber'] ?? '-';
                        final date = trip['departureDate'] ?? '-';
                        final time = trip['departureTime'] ?? '-';
                        final fare = trip['price'] ?? '-';
                        return Card(
                          color: colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: colorScheme.onSurface.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '$from → $to',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.circle, color: Colors.blue, size: 12),
                                    const SizedBox(width: 6),
                                    Text(
                                      status,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Bus number: $busNumber',
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, color: Colors.green, size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      date,
                                      style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withOpacity(0.8)),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(Icons.access_time, color: Colors.green, size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      time,
                                      style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withOpacity(0.8)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text('Rs. $fare', style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
                                    const Spacer(),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.green,
                                        side: const BorderSide(color: Colors.green),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        backgroundColor: colorScheme.surface,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => TripMapPage(trip: trip),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.map, size: 18),
                                      label: const Text('View in Map'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
