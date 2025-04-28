import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../auth/data/user_session.dart';
import '../../../../config.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({Key? key}) : super(key: key);

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  late Future<List<Map<String, dynamic>>> _futureBookings;

  @override
  void initState() {
    super.initState();
    _futureBookings = fetchBookings();
  }

  Future<List<Map<String, dynamic>>> fetchBookings() async {
    final token = UserSession.token;
    final response = await http.get(
      Uri.parse('${AppConfig.backendBaseUrl}/api/bookings/my'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> bookings = json.decode(response.body);
      return bookings.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          final bookings = snapshot.data!;
          // Group bookings by trip id
          final Map<String, Map<String, dynamic>> grouped = {};
          for (final booking in bookings) {
            final trip = booking['trip'] ?? {};
            final tripId = (trip['id'] ?? '').toString();
            if (!grouped.containsKey(tripId)) {
              grouped[tripId] = {
                'trip': trip,
                'seats': <String>[],
                'bookings': <Map<String, dynamic>>[],
              };
            }
            grouped[tripId]!['seats'].add(booking['seatLabel'] ?? '-');
            grouped[tripId]!['bookings'].add(booking);
          }

          return ListView.separated(
            itemCount: grouped.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final tripGroup = grouped.values.elementAt(index);
              final trip = tripGroup['trip'] ?? {};
              final seats = (tripGroup['seats'] as List<String>).join(', ');
              final busNumber = trip['bus']?['busNumber'] ?? '-';
              final route = "${trip['from']?['displayName'] ?? trip['from']?['name'] ?? ''} → ${trip['to']?['displayName'] ?? trip['to']?['name'] ?? ''}";
              final date = trip['departureDate'] ?? trip['date'] ?? '';
              final time = trip['departureTime'] ?? trip['time'] ?? '';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorScheme.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.08),
                      blurRadius: 7,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.directions_bus, size: 20, color: colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Bus number: $busNumber',
                            style: TextStyle(
                              fontSize: 15,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18, color: colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 15,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time, size: 18, color: colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 15,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Seats: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: colorScheme.primary,
                              ),
                            ),
                            TextSpan(
                              text: seats,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
