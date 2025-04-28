// Shows all trips assigned to the driver using /api/trips/my-trips
import 'package:flutter/material.dart';
import '../../data/driver_trips_repository.dart';

class MyDrivesPage extends StatefulWidget {
  const MyDrivesPage({super.key});

  @override
  State<MyDrivesPage> createState() => _MyDrivesPageState();
}

class _MyDrivesPageState extends State<MyDrivesPage> {
  List<Map<String, dynamic>> _drives = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDrives();
  }

  Future<void> _fetchDrives() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final drives = await DriverTripsRepository.fetchAllTrips();
      setState(() {
        _drives = drives;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _formatDate(dynamic isoString) {
    if (isoString == null) return '-';
    final dt = DateTime.tryParse(isoString.toString());
    if (dt == null) return '-';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  // Utility to format time string (HH:mm:ss) to 12-hour format with AM/PM
  String _formatTime12hr(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '-';
    final parts = timeStr.split(':');
    if (parts.length < 2) return timeStr;
    int hour = int.tryParse(parts[0]) ?? 0;
    int minute = int.tryParse(parts[1]) ?? 0;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $ampm';
  }

  Widget _buildStatusDot(dynamic status) {
    final s = (status ?? '').toString().toLowerCase();
    Color color;
    switch (s) {
      case 'scheduled':
        color = Colors.blue;
        break;
      case 'departed':
        color = Colors.orange;
        break;
      case 'teardown':
        color = Colors.red;
        break;
      case 'arrived':
        color = Colors.green;
        break;
      default:
        color = Colors.blue;
    }
    return Icon(Icons.circle, color: color, size: 16);
  }

  Widget _buildStatusText(dynamic status) {
    final s = (status ?? '').toString().toLowerCase();
    Color color;
    String text = s;
    switch (s) {
      case 'scheduled':
        color = Colors.blue;
        text = 'scheduled';
        break;
      case 'departed':
        color = Colors.orange;
        text = 'departed';
        break;
      case 'teardown':
        color = Colors.red;
        text = 'teardown';
        break;
      case 'arrived':
        color = Colors.green;
        text = 'arrived';
        break;
      default:
        color = Colors.blue;
        text = 'scheduled';
    }
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('My Drives'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator())),
            if (!_loading && _error != null)
              Expanded(
                child: Center(
                  child: Text(
                    _error!,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              ),
            if (!_loading && _error == null)
              Expanded(
                child:
                    _drives.isEmpty
                        ? const Center(child: Text('No drives available'))
                        : ListView.builder(
                          itemCount: _drives.length,
                          itemBuilder: (context, index) {
                            final trip = _drives[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: colorScheme.onSurface.withOpacity(0.2), width: 2),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${trip['from']?['displayName'] ?? '-'} → ${trip['to']?['displayName'] ?? '-'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Bus number: ${trip['bus']?['busNumber'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _buildStatusDot(trip['tripStatus']),
                                        const SizedBox(width: 6),
                                        _buildStatusText(trip['tripStatus']),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, color: Colors.green, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          _formatDate(trip['departureDate']),
                                          style: const TextStyle(fontSize: 16, color: Colors.white70),
                                        ),
                                        const SizedBox(width: 18),
                                        const Icon(Icons.access_time, color: Colors.green, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          _formatTime12hr(trip['departureTime']),
                                          style: const TextStyle(fontSize: 16, color: Colors.white70),
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
