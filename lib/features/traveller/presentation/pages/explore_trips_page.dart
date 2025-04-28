import 'package:flutter/material.dart';
import 'package:drive/features/admin/data/bus_stop_repository.dart';
import 'package:drive/features/traveller/data/trip_repository.dart';
import 'package:intl/intl.dart';
import 'package:drive/features/auth/data/user_session.dart';
import 'package:drive/features/traveller/presentation/pages/trip_map_page.dart';
import 'package:drive/features/traveller/presentation/pages/select_seats_page.dart';

class ExploreTripsPage extends StatefulWidget {
  const ExploreTripsPage({super.key});

  @override
  State<ExploreTripsPage> createState() => _ExploreTripsPageState();
}

class _ExploreTripsPageState extends State<ExploreTripsPage> {
  String? _selectedFromId;
  String? _selectedToId;
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _busStops = [];
  List<Map<String, dynamic>> _trips = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBusStops();
    _fetchTrips();
  }

  Future<void> _fetchBusStops() async {
    final stops = await BusStopRepository.fetchBusStops();
    setState(() {
      _busStops = stops;
    });
  }

  Future<void> _fetchTrips() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final trips = await TravellerTripRepository.fetchTrips(
        fromId: _selectedFromId,
        toId: _selectedToId,
        date: _selectedDate,
      );
      setState(() {
        _trips = trips;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _getRoute(Map<String, dynamic> trip) {
    final from = trip['from']?['displayName'] ?? trip['from']?['name'] ?? '';
    final to = trip['to']?['displayName'] ?? trip['to']?['name'] ?? '';
    if (from.isNotEmpty && to.isNotEmpty) {
      return '$from → $to';
    }
    return '';
  }

  String _getBusNumber(Map<String, dynamic> trip) {
    return trip['bus']?['busNumber'] ?? trip['busNumber'] ?? '';
  }

  String _getDate(Map<String, dynamic> trip) {
    return trip['departureDate'] ?? trip['date'] ?? '';
  }

  String _getTime(Map<String, dynamic> trip) {
    final timeStr = trip['departureTime'] ?? trip['time'] ?? '';
    if (timeStr.isEmpty) return '';
    try {
      // Handles both HH:mm:ss and HH:mm formats
      final t =
          timeStr.length > 5
              ? DateFormat('HH:mm:ss').parse(timeStr)
              : DateFormat('HH:mm').parse(timeStr);
      return DateFormat('h:mm a').format(t);
    } catch (_) {
      return timeStr;
    }
  }

  String _getTripStatus(Map<String, dynamic> trip) {
    return (trip['tripStatus'] ?? '').toString();
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
        title: const Text('Explore Trips'),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value:
                        _busStops.any((stop) => stop['id'] == _selectedFromId)
                            ? _selectedFromId
                            : null,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                    ),
                    items:
                        _busStops
                            .where((stop) => stop['id'] != _selectedToId)
                            .map<DropdownMenuItem<String>>(
                              (stop) => DropdownMenuItem<String>(
                                value: stop['id'] as String,
                                child: Builder(
                                  builder: (context) {
                                    return Text(
                                      stop['displayName'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList(),
                    onChanged:
                        _busStops.isEmpty
                            ? null
                            : (val) {
                              setState(() {
                                _selectedFromId = val;
                              });
                              _fetchTrips();
                            },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value:
                        _busStops.any((stop) => stop['id'] == _selectedToId)
                            ? _selectedToId
                            : null,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                    ),
                    items:
                        _busStops
                            .where((stop) => stop['id'] != _selectedFromId)
                            .map<DropdownMenuItem<String>>(
                              (stop) => DropdownMenuItem<String>(
                                value: stop['id'] as String,
                                child: Builder(
                                  builder: (context) {
                                    return Text(
                                      stop['displayName'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList(),
                    onChanged:
                        _busStops.isEmpty
                            ? null
                            : (val) {
                              setState(() {
                                _selectedToId = val;
                              });
                              _fetchTrips();
                            },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.clear, color: colorScheme.primary),
                  tooltip: 'Clear filters',
                  onPressed: () {
                    setState(() {
                      _selectedFromId = null;
                      _selectedToId = null;
                      _selectedDate = null;
                    });
                    _fetchTrips();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                        _fetchTrips();
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Pick a date',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      child: Text(
                        _selectedDate == null
                            ? ''
                            : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                      : _trips.isEmpty
                      ? const Center(child: Text('No trips found'))
                      : ListView.separated(
                        itemCount: _trips.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final trip = _trips[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: colorScheme.onSurface.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            elevation: 0,
                            color: colorScheme.surfaceVariant,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getRoute(trip),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      _buildStatusDot(_getTripStatus(trip)),
                                      const SizedBox(width: 6),
                                      _buildStatusText(_getTripStatus(trip)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Bus number: ${_getBusNumber(trip)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _getDate(trip),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 18),
                                      const Icon(
                                        Icons.access_time,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _getTime(trip),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Text(
                                        'Rs. ${trip['price'] ?? ''}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (_getTripStatus(trip) == 'scheduled' && UserSession.isAuthenticated)
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: colorScheme.primary,
                                            foregroundColor: colorScheme.onPrimary,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => SelectSeatsPage(trip: trip),
                                              ),
                                            );
                                          },
                                          child: const Text('Select Seats'),
                                        )
                                      else
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: colorScheme.primary,
                                            side: BorderSide(color: colorScheme.primary),
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
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15),
    );
  }
}
