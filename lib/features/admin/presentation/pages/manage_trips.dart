import 'package:drive/config.dart';
import 'package:flutter/material.dart';
import 'package:drive/features/admin/data/trip_repository.dart';
import 'package:drive/features/admin/data/bus_stop_repository.dart';
import 'package:drive/features/admin/data/driver_repository.dart';
import 'package:drive/features/admin/data/bus_repository.dart';
import 'package:drive/features/auth/data/user_session.dart';
import 'package:http/http.dart' as http;

class ManageTripsPage extends StatefulWidget {
  const ManageTripsPage({super.key});

  @override
  State<ManageTripsPage> createState() => _ManageTripsPageState();
}

class _ManageTripsPageState extends State<ManageTripsPage> {
  String? _selectedFromId;
  String? _selectedToId;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _trips = [];
  List<Map<String, dynamic>> _busStops = [];
  bool _isLoading = false;
  String? _errorMessage;

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
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await TripRepository.fetchTrips(
      fromId: _selectedFromId,
      toId: _selectedToId,
      // Add search, page, etc. as needed
    );
    setState(() {
      _isLoading = false;
      if (result != null && result['content'] is List) {
        _trips = List<Map<String, dynamic>>.from(result['content']);
      } else {
        _errorMessage = 'Failed to load trips.';
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: const Text('Manage trips'),
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
                    value: _selectedFromId,
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
                                      style: const TextStyle(color: Colors.white),
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() => _selectedFromId = val);
                      _fetchTrips();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedToId,
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
                                      style: const TextStyle(color: Colors.white),
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() => _selectedToId = val);
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
                      _searchController.clear();
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
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Trips by Bus number',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                    ),
                    onSubmitted: (_) => _fetchTrips(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                  onPressed: _fetchTrips,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Trips list
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(child: Text(_errorMessage!))
                      : _trips.isEmpty
                      ? const Center(child: Text('No trips available'))
                      : ListView.builder(
                        itemCount: _trips.length,
                        itemBuilder: (context, index) {
                          final trip = _trips[index];
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 8,
                                          children: [
                                            Text(
                                              '${trip['from']?['displayName'] ?? '-'}  →  ${trip['to']?['displayName'] ?? '-'}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 12), // Add gap between route and bus number
                                            Builder(
                                              builder: (context) {
                                                final status = (trip['tripStatus'] ?? 'scheduled').toString().toLowerCase();
                                                Color dotColor;
                                                Color textColor;
                                                String statusText;
                                                switch (status) {
                                                  case 'scheduled':
                                                    dotColor = Colors.blue;
                                                    textColor = Colors.blue;
                                                    statusText = 'scheduled';
                                                    break;
                                                  case 'departed':
                                                    dotColor = Colors.orange;
                                                    textColor = Colors.orange;
                                                    statusText = 'departed';
                                                    break;
                                                  case 'teardown':
                                                    dotColor = Colors.red;
                                                    textColor = Colors.red;
                                                    statusText = 'teardown';
                                                    break;
                                                  case 'arrived':
                                                    dotColor = Colors.green;
                                                    textColor = Colors.green;
                                                    statusText = 'arrived';
                                                    break;
                                                  default:
                                                    dotColor = Colors.blue;
                                                    textColor = Colors.blue;
                                                    statusText = 'scheduled';
                                                }
                                                return Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.circle,
                                                      color: dotColor,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      statusText,
                                                      style: TextStyle(
                                                        color: textColor,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Bus number: ${trip['bus']?['busNumber'] ?? ''}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today, size: 18),
                                            const SizedBox(width: 6),
                                            Text(
                                              _formatDate(trip['departureDate']),
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(width: 18),
                                            const Icon(Icons.access_time, size: 18),
                                            const SizedBox(width: 6),
                                            Text(
                                              _formatTime12(trip['departureTime']),
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: colorScheme.error,
                                      size: 32,
                                    ),
                                    tooltip: 'Delete trip',
                                    onPressed: () async {
                                      final status = (trip['tripStatus'] ?? 'scheduled').toString().toLowerCase();
                                      if (status != 'scheduled') {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('You can only delete trips with status "scheduled".'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete Trip'),
                                          content: const Text('Are you sure you want to delete this trip?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.of(ctx).pop(true),
                                              style: ElevatedButton.styleFrom(backgroundColor: colorScheme.error),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await _deleteTrip(trip['id']);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      () => showDialog(
                        context: context,
                        builder:
                            (context) => AddTripDialog(busStops: _busStops),
                      ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add trips'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }

  String _formatTime12(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '-';
    try {
      // Accepts formats like '13:05:00' or '13:05'
      final parts = timeStr.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      final ampm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12 == 0 ? 12 : hour % 12;
      final minuteStr = minute.toString().padLeft(2, '0');
      return '$hour:$minuteStr $ampm';
    } catch (e) {
      return timeStr;
    }
  }

  Future<void> _deleteTrip(dynamic tripId) async {
    setState(() { _isLoading = true; });
    final token = UserSession.token;
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/trips/$tripId');
    final response = await http.delete(uri, headers: headers);
    if (response.statusCode == 200 || response.statusCode == 204) {
      await _fetchTrips();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip deleted'), backgroundColor: Colors.green),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete trip'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }
}

class AddTripDialog extends StatefulWidget {
  final List<Map<String, dynamic>> busStops;
  const AddTripDialog({super.key, required this.busStops});

  @override
  State<AddTripDialog> createState() => _AddTripDialogState();
}

class _AddTripDialogState extends State<AddTripDialog> {
  String? _from;
  String? _to;
  String? _driver;
  String? _bus;
  DateTime? _date;
  TimeOfDay? _time;
  List<Map<String, dynamic>> _availableDrivers = [];
  List<Map<String, dynamic>> _availableBuses = [];
  bool _isLoadingDrivers = false;
  bool _isLoadingBuses = false;
  double? _price;
  final TextEditingController _priceController = TextEditingController();

  String get _jwtToken => UserSession.token ?? '';

  Future<void> _fetchAvailableDrivers() async {
    if (_from == null || _to == null || _date == null || _time == null) return;
    setState(() => _isLoadingDrivers = true);
    final dt = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    final drivers = await DriverRepository.fetchAvailableDrivers(
      fromId: _from!,
      toId: _to!,
      departureDate: dt,
      jwtToken: _jwtToken, // <-- Pass JWT token here
    );
    setState(() {
      _availableDrivers = drivers;
      _isLoadingDrivers = false;
    });
  }

  Future<void> _fetchAvailableBuses() async {
    setState(() => _isLoadingBuses = true);
    final buses = await BusRepository.fetchBuses();
    setState(() {
      _availableBuses = buses;
      _isLoadingBuses = false;
    });
  }

  void _onFieldChanged() {
    if (_from != null && _to != null && _date != null && _time != null) {
      _fetchAvailableDrivers();
    } else {
      setState(() {
        _availableDrivers = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAvailableBuses();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Trip'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _from,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'From'),
                    items:
                        widget.busStops
                            .where((stop) => stop['id'] != _to)
                            .map<DropdownMenuItem<String>>(
                              (stop) => DropdownMenuItem<String>(
                                value: stop['id'] as String,
                                child: Builder(
                                  builder: (context) {
                                    return Text(
                                      stop['displayName'] ?? '',
                                      style: const TextStyle(color: Colors.white),
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() => _from = val);
                      _onFieldChanged();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _to,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'To'),
                    items:
                        widget.busStops
                            .where((stop) => stop['id'] != _from)
                            .map<DropdownMenuItem<String>>(
                              (stop) => DropdownMenuItem<String>(
                                value: stop['id'] as String,
                                child: Builder(
                                  builder: (context) {
                                    return Text(
                                      stop['displayName'] ?? '',
                                      style: const TextStyle(color: Colors.white),
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() => _to = val);
                      _onFieldChanged();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Date and Time'),
              controller: TextEditingController(
                text:
                    _date == null || _time == null
                        ? ''
                        : '${_date!.toLocal().toString().split(' ')[0]} ${_time!.format(context)}',
              ),
              onTap: () async {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final date = await showDatePicker(
                  context: context,
                  initialDate: _date ?? today,
                  firstDate: today,
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  TimeOfDay? time;
                  final isToday =
                      date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;
                  do {
                    time = await showTimePicker(
                      context: context,
                      initialTime: _time ?? TimeOfDay.now(),
                    );
                    if (time == null) break;
                    if (isToday) {
                      final pickedDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      if (pickedDateTime.isBefore(now)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select a future time for today.',
                            ),
                          ),
                        );
                        time = null;
                      }
                    }
                  } while (isToday && time == null);
                  if (time != null) {
                    setState(() {
                      _date = date;
                      _time = time;
                    });
                    _onFieldChanged();
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _driver,
              decoration: const InputDecoration(
                labelText: 'Available driver',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Select a driver'),
              items: _isLoadingDrivers
                  ? [
                      const DropdownMenuItem(
                        value: null,
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    ]
                  : _availableDrivers
                      .map(
                        (driver) {
                          final name = driver['fullName'] ?? '';
                          final id = driver['id'];
                          return DropdownMenuItem<String>(
                            value: id as String,
                            child: Text(
                              name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      )
                      .toList(),
              onChanged: _isLoadingDrivers ? null : (val) => setState(() => _driver = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _bus,
              decoration: const InputDecoration(labelText: 'Available bus'),
              hint: const Text('Select a bus'),
              items: _isLoadingBuses
                  ? [
                      const DropdownMenuItem(
                        value: null,
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                      ),
                    ]
                  : _availableBuses
                      .map(
                        (bus) => DropdownMenuItem<String>(
                          value: bus['id'].toString(),
                          child: Text(
                            bus['busNumber'] ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: _isLoadingBuses ? null : (val) => setState(() => _bus = val),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _price = double.tryParse(val);
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Validate required fields
            if (_from == null || _to == null || _driver == null || _bus == null || _date == null || _time == null || _price == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all fields.')),
              );
              return;
            }
            try {
              final busId = int.tryParse(_bus!);
              if (busId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid bus selection.')),
                );
                return;
              }
              final dt = DateTime(
                _date!.year,
                _date!.month,
                _date!.day,
                _time!.hour,
                _time!.minute,
              );
              await TripRepository.createTrip(
                price: _price!,
                tripStatus: null, // Send null by default as per allowed values
                departureDateTime: dt,
                busId: busId,
                busDriverId: _driver!,
                fromId: _from!,
                toId: _to!,
                jwtToken: _jwtToken,
              );
              if (!mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trip created successfully!')),
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to create trip: $e')),
              );
            }
          },
          child: const Text('Create Trip'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
}
