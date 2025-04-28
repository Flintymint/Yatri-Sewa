// Renamed from my_drives_page.dart to current_drives_page.dart
import 'package:flutter/material.dart';
import '../../data/driver_trips_repository.dart';
import 'package:drive/features/admin/data/bus_stop_repository.dart';
import 'package:intl/intl.dart';

class CurrentDrivesPage extends StatefulWidget {
  const CurrentDrivesPage({super.key});

  @override
  State<CurrentDrivesPage> createState() => _CurrentDrivesPageState();
}

class _CurrentDrivesPageState extends State<CurrentDrivesPage> {
  List<Map<String, dynamic>> _drives = [];
  bool _loading = true;
  String? _error;
  String? _selectedFromId;
  String? _selectedToId;
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _busStops = [];

  @override
  void initState() {
    super.initState();
    _fetchBusStops();
    _fetchDrives();
  }

  Future<void> _fetchBusStops() async {
    final stops = await BusStopRepository.fetchBusStops();
    setState(() {
      _busStops = stops;
    });
  }

  Future<void> _fetchDrives() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final drives = await DriverTripsRepository.fetchCurrentTrips();
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Current Drives'),
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
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFromId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'From'),
                    items: _busStops.map<DropdownMenuItem<String>>((stop) {
                      return DropdownMenuItem<String>(
                        value: stop['id'] as String?,
                        child: Text(stop['displayName'] ?? '-'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedFromId = val;
                        // Optionally reset To if same as From
                        if (_selectedToId == val) _selectedToId = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedToId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'To'),
                    items: _busStops.where((stop) => stop['id'] != _selectedFromId).map<DropdownMenuItem<String>>((stop) {
                      return DropdownMenuItem<String>(
                        value: stop['id'] as String?,
                        child: Text(stop['displayName'] ?? '-'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedToId = val;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear filters',
                  onPressed: () {
                    setState(() {
                      _selectedFromId = null;
                      _selectedToId = null;
                      _selectedDate = null;
                    });
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
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Pick a date',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      child: Text(
                        _selectedDate == null ? '' : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator())),
            if (!_loading && _error != null)
              Expanded(
                child: Center(
                  child: Text(_error!, style: TextStyle(color: colorScheme.error)),
                ),
              ),
            if (!_loading && _error == null)
              Expanded(
                child: _drives.isEmpty
                    ? const Center(child: Text('No drives available'))
                    : ListView.builder(
                        itemCount: _drives.length,
                        itemBuilder: (context, index) {
                          final trip = _drives[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            color: colorScheme.surfaceContainerHighest,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${trip['from']?['displayName'] ?? '-'} → ${trip['to']?['displayName'] ?? '-'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Bus number: ${trip['bus']?['busNumber'] ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
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
                                        style: const TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                      const SizedBox(width: 18),
                                      const Icon(Icons.access_time, color: Colors.green, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatTime12hr(trip['departureTime']),
                                        style: const TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Trip status dropdown
                                      _TripStatusDropdown(
                                        tripId: trip['id'],
                                        currentStatus: trip['tripStatus'],
                                        onStatusUpdated: _fetchDrives,
                                      ),
                                      // Complete button
                                      ElevatedButton(
                                        onPressed: (trip['tripStatus']?.toLowerCase() == 'departed')
                                            ? () async {
                                                try {
                                                  await DriverTripsRepository.updateTripStatus(
                                                    tripId: trip['id'],
                                                    status: 'arrived',
                                                  );
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Trip marked as arrived')),
                                                  );
                                                  _fetchDrives();
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Error: $e')),
                                                  );
                                                }
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Complete', style: TextStyle(fontWeight: FontWeight.bold)),
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

  String _formatDate(dynamic isoString) {
    if (isoString == null) return '-';
    final dt = DateTime.tryParse(isoString.toString());
    if (dt == null) return '-';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

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
}

class _TripStatusDropdown extends StatefulWidget {
  final int tripId;
  final String? currentStatus;
  final VoidCallback onStatusUpdated;
  const _TripStatusDropdown({
    required this.tripId,
    required this.currentStatus,
    required this.onStatusUpdated,
    Key? key,
  }) : super(key: key);

  @override
  State<_TripStatusDropdown> createState() => _TripStatusDropdownState();
}

class _TripStatusDropdownState extends State<_TripStatusDropdown> {
  String? _selectedStatus;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  void _onChanged(String? newStatus) async {
    if (newStatus == null || newStatus == _selectedStatus) return;
    if (newStatus == 'teardown') {
      final reason = await showDialog<String>(
        context: context,
        builder: (ctx) {
          String text = '';
          return AlertDialog(
            title: const Text('Teardown Reason'),
            content: TextField(
              autofocus: true,
              minLines: 2,
              maxLines: 4,
              onChanged: (v) => text = v,
              decoration: const InputDecoration(
                hintText: 'Enter reason for teardown',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (text.trim().isEmpty) return;
                  Navigator.pop(ctx, text.trim());
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
      if (reason == null || reason.trim().isEmpty) return;
      setState(() => _loading = true);
      try {
        await DriverTripsRepository.updateTripStatus(
          tripId: widget.tripId,
          status: 'teardown',
          reason: reason,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip status updated to teardown')),
        );
        setState(() {
          _selectedStatus = 'teardown';
        });
        widget.onStatusUpdated();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _loading = false);
      }
    } else {
      setState(() => _loading = true);
      try {
        await DriverTripsRepository.updateTripStatus(
          tripId: widget.tripId,
          status: newStatus,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trip status updated to $newStatus')),
        );
        setState(() {
          _selectedStatus = newStatus;
        });
        widget.onStatusUpdated();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: _loading
          ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
          : DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'scheduled', child: Text('scheduled')),
                DropdownMenuItem(value: 'departed', child: Text('departed')),
                DropdownMenuItem(value: 'teardown', child: Text('teardown')),
              ],
              onChanged: _onChanged,
              isExpanded: true,
              hint: const Text('trip status'),
            ),
    );
  }
}
