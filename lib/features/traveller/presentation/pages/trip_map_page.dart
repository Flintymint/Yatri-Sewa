import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:drive/features/traveller/data/route_repository.dart';
import 'package:drive/features/auth/data/user_session.dart';

class TripMapPage extends StatefulWidget {
  final Map<String, dynamic> trip;
  const TripMapPage({super.key, required this.trip});

  @override
  State<TripMapPage> createState() => _TripMapPageState();
}

class _TripMapPageState extends State<TripMapPage> with SingleTickerProviderStateMixin {
  late final LatLng fromLatLng;
  late final LatLng toLatLng;
  late final AnimationController _controller;
  late final Animation<double> _animation;
  List<LatLng> _routePoints = [];
  bool _loadingRoute = true;
  String? _routeError;

  @override
  void initState() {
    super.initState();
    fromLatLng = LatLng(
      widget.trip['from']?['latitude'] ?? 0.0,
      widget.trip['from']?['longitude'] ?? 0.0,
    );
    toLatLng = LatLng(
      widget.trip['to']?['latitude'] ?? 0.0,
      widget.trip['to']?['longitude'] ?? 0.0,
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: false);
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    setState(() {
      _loadingRoute = true;
      _routeError = null;
    });
    try {
      final route = await RouteRepository.fetchRoute(fromLatLng, toLatLng);
      setState(() {
        _routePoints = route;
        _loadingRoute = false;
      });
    } catch (e) {
      setState(() {
        _routeError = e.toString();
        _loadingRoute = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busNumber = widget.trip['bus']?['busNumber'] ?? '';
    final status = widget.trip['tripStatus'] ?? '';
    final reason = widget.trip['reason'] ?? '';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
        title: const Text('Trip details', style: TextStyle(fontFamily: 'Chalkboard', fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loadingRoute
                ? const Center(child: CircularProgressIndicator())
                : _routeError != null
                    ? Center(child: Text('Error loading route: \n$_routeError', style: TextStyle(color: Colors.red)))
                    : Stack(
                        children: [
                          FlutterMap(
                            options: MapOptions(
                              center: fromLatLng,
                              zoom: 13,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: ['a', 'b', 'c'],
                              ),
                              if (_routePoints.isNotEmpty)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: _routePoints,
                                      color: Colors.blue,
                                      strokeWidth: 5,
                                    ),
                                  ],
                                ),
                              AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) {
                                  final route = _routePoints.isNotEmpty ? _routePoints : [fromLatLng, toLatLng];
                                  LatLng carPos;
                                  final status = widget.trip['tripStatus'] ?? '';
                                  if (status == 'teardown' && route.length > 1) {
                                    // Place bus in the middle of the route
                                    final midIdx = (route.length / 2).floor();
                                    carPos = route[midIdx];
                                  } else if (status == 'departed' && route.length > 1) {
                                    // Animate the bus along the route continuously
                                    final t = _animation.value;
                                    int index = (t * (route.length - 1)).floor();
                                    if (index < 0) index = 0;
                                    if (index >= route.length) index = route.length - 1;
                                    carPos = route[index];
                                  } else {
                                    // Default: Place bus at the 'from' point
                                    carPos = fromLatLng;
                                  }
                                  return MarkerLayer(
                                    markers: [
                                      Marker(
                                        width: 40,
                                        height: 40,
                                        point: carPos,
                                        child: const Icon(Icons.directions_bus, color: Colors.red, size: 36),
                                      ),
                                      Marker(
                                        width: 30,
                                        height: 30,
                                        point: fromLatLng,
                                        child: const Icon(Icons.location_on, color: Colors.green, size: 28),
                                      ),
                                      Marker(
                                        width: 30,
                                        height: 30,
                                        point: toLatLng,
                                        child: const Icon(Icons.flag, color: Colors.blue, size: 28),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.75),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.route, color: Theme.of(context).colorScheme.secondary, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${widget.trip['from']?['displayName'] ?? ''}  →  ${widget.trip['to']?['displayName'] ?? ''}',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 26),
                                  Row(
                                    children: [
                                      Icon(Icons.directions_bus, color: Theme.of(context).colorScheme.secondary, size: 18),
                                      const SizedBox(width: 8),
                                      Text('Bus number:', style: TextStyle(color: Colors.white70, fontSize: 15)),
                                      const SizedBox(width: 4),
                                      Text('$busNumber', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                                    ],
                                  ),
                                  const SizedBox(height:12),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.secondary, size: 18),
                                      const SizedBox(width: 8),
                                      Text('Departure:', style: TextStyle(color: Colors.white70, fontSize: 15)),
                                      const SizedBox(width: 4),
                                      Text('${widget.trip['departureDate'] ?? ''}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                                      const SizedBox(width: 12),
                                      Icon(Icons.access_time, color: Theme.of(context).colorScheme.secondary, size: 18),
                                      const SizedBox(width: 4),
                                      Text('${widget.trip['departureTime'] ?? ''}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary, size: 18),
                                      const SizedBox(width: 8),
                                      Text('Status:', style: TextStyle(color: Colors.white70, fontSize: 15)),
                                      const SizedBox(width: 4),
                                      Text('$status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                                    ],
                                  ),
                                  if (status == 'teardown' && reason.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.warning, color: Colors.redAccent, size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text('Reason: $reason', style: const TextStyle(color: Colors.redAccent, fontSize: 15)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (!UserSession.isAuthenticated && (status.toString().toLowerCase() == 'scheduled'))
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.secondary,
                                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pushReplacementNamed('/login');
                                          },
                                          child: const Text('Login for reservation'),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
