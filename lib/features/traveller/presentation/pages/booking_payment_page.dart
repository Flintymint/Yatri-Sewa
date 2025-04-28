import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:drive/features/traveller/data/route_repository.dart';
import 'package:drive/features/traveller/data/khalti_payment_repository.dart';
import 'package:khalti_checkout_flutter/khalti_checkout_flutter.dart';

class BookingPaymentPage extends StatefulWidget {
  final Map<String, dynamic> trip;
  final List<String> selectedSeats;
  const BookingPaymentPage({
    super.key,
    required this.trip,
    required this.selectedSeats,
  });

  @override
  State<BookingPaymentPage> createState() => _BookingPaymentPageState();
}

class _BookingPaymentPageState extends State<BookingPaymentPage>
    with SingleTickerProviderStateMixin {
  List<LatLng> _routePoints = [];
  bool _loadingRoute = true;
  String? _routeError;
  late final LatLng fromPoint;
  late final LatLng toPoint;
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final MapController _mapController;
  String? _lastPidx;

  int? _getTripId() => widget.trip['id'] is int ? widget.trip['id'] : int.tryParse(widget.trip['id']?.toString() ?? '');
  String? _getSeatLabel() => widget.trip['seatLabel']?.toString() ?? (widget.selectedSeats.isNotEmpty ? widget.selectedSeats.first : null);

  @override
  void initState() {
    super.initState();
    fromPoint = LatLng(
      (widget.trip['from']?['latitude'] ??
              widget.trip['from']?['lat'] ??
              27.6710)
          .toDouble(),
      (widget.trip['from']?['longitude'] ??
              widget.trip['from']?['lng'] ??
              85.4298)
          .toDouble(),
    );
    toPoint = LatLng(
      (widget.trip['to']?['latitude'] ?? widget.trip['to']?['lat'] ?? 27.7062)
          .toDouble(),
      (widget.trip['to']?['longitude'] ?? widget.trip['to']?['lng'] ?? 85.3240)
          .toDouble(),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: false);
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _mapController = MapController();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    setState(() {
      _loadingRoute = true;
      _routeError = null;
    });
    try {
      final route = await RouteRepository.fetchRoute(fromPoint, toPoint);
      setState(() {
        _routePoints = route;
        _loadingRoute = false;
      });
      // Fit map bounds to route
      if (route.isNotEmpty) {
        LatLngBounds bounds = LatLngBounds(route.first, route.first);
        for (final p in route) {
          bounds.extend(p);
        }
        // Add padding so markers are not at the edge
        await Future.delayed(const Duration(milliseconds: 100));
        _mapController.fitBounds(
          bounds,
          options: const FitBoundsOptions(padding: EdgeInsets.all(60)),
        );
      }
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
    final bus = widget.trip['bus'] ?? {};
    final route =
        "${widget.trip['from']?['displayName'] ?? widget.trip['from']?['name'] ?? ''} → ${widget.trip['to']?['displayName'] ?? widget.trip['to']?['name'] ?? ''}";
    final date = widget.trip['departureDate'] ?? widget.trip['date'] ?? '';
    final timeStr = widget.trip['departureTime'] ?? widget.trip['time'] ?? '';
    final busNumber = bus['busNumber'] ?? widget.trip['busNumber'] ?? '';
    String formattedTime = timeStr;
    try {
      final t =
          timeStr.length > 5
              ? DateFormat('HH:mm:ss').parse(timeStr)
              : DateFormat('HH:mm').parse(timeStr);
      formattedTime = DateFormat('h:mm a').format(t);
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFF8BC34A),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF8BC34A),
      body: Stack(
        children: [
          _loadingRoute
              ? const Center(child: CircularProgressIndicator())
              : _routeError != null
              ? Center(
                child: Text(
                  'Error loading route: \n$_routeError',
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: fromPoint,
                  initialZoom: 13,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
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
                      final route = _routePoints.isNotEmpty ? _routePoints : [fromPoint, toPoint];
                      LatLng carPos;
                      final status = widget.trip['tripStatus'] ?? '';
                      if (status == 'teardown' && route.length > 1) {
                        // Place car in the middle of the route
                        final midIdx = (route.length / 2).floor();
                        carPos = route[midIdx];
                      } else if (status == 'departed' && route.length > 1) {
                        // Animate the car along the route continuously
                        final t = _animation.value;
                        int index = (t * (route.length - 1)).floor();
                        if (index < 0) index = 0;
                        if (index >= route.length) index = route.length - 1;
                        carPos = route[index];
                      } else {
                        // Default: Place car at the 'from' point
                        carPos = fromPoint;
                      }
                      return MarkerLayer(
                        markers: [
                          Marker(
                            width: 40,
                            height: 40,
                            point: carPos,
                            child: const Icon(
                              Icons.directions_bus,
                              color: Colors.red,
                              size: 36,
                            ),
                          ),
                          Marker(
                            width: 30,
                            height: 30,
                            point: fromPoint,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 28,
                            ),
                          ),
                          Marker(
                            width: 30,
                            height: 30,
                            point: toPoint,
                            child: const Icon(
                              Icons.flag,
                              color: Colors.blue,
                              size: 28,
                            ),
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
                color: const Color.fromRGBO(0, 0, 0, 0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  const BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.route,
                        color: Color(0xFF8BC34A),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          route,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_bus,
                        color: Color(0xFF8BC34A),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Bus number:',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        busNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF8BC34A),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Departure:',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 18),
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFF8BC34A),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.event_seat,
                        color: Color(0xFF8BC34A),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Selected Seats:',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children:
                              widget.selectedSeats
                                  .map(
                                    (s) => Container(
                                      margin: const EdgeInsets.only(
                                        top: 2,
                                        bottom: 2,
                                      ),
                                      child: Chip(
                                        label: Text(
                                          s,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                        backgroundColor: const Color(
                                          0xFF8BC34A,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 0,
                                        ),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                        labelPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF5C2D91,
                        ), // Khalti accent
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        // 1. Prepare payment data
                        // Calculate fare and amount for all selected seats
                        final rawFare = widget.trip['baseFare'] ?? widget.trip['fare'] ?? widget.trip['price'] ?? 500;
                        final fare = (rawFare is int ? rawFare : rawFare.round()) * 100;
                        final amount = fare * widget.selectedSeats.length;
                        final orderId =
                            "TRIP_${widget.trip['id'] ?? DateTime.now().millisecondsSinceEpoch}";
                        final orderName = "Bus Ticket Booking";
                        final returnUrl = "khalti://payment-callback";
                        final customerInfo = {
                          'name': widget.trip['userName'] ?? 'Traveller',
                          'email': widget.trip['userEmail'] ?? '',
                          'phone': widget.trip['userPhone'] ?? '',
                        };
                        try {
                          // Prepare amount breakdown and product details as per backend API
                          final amountBreakdown = [
                            {
                              'label': 'Base Fare',
                              'amount': fare * widget.selectedSeats.length,
                            },
                            {
                              'label': 'Tax',
                              'amount': (widget.trip['tax'] ?? 0) * 100,
                            },
                          ];
                          final productDetails = widget.selectedSeats.map((seat) => {
                            'identity': seat,
                            'name': 'Seat $seat',
                            'unit_price': fare,
                            'total_price': fare,
                            'quantity': 1,
                          }).toList();
                          final paymentResp =
                              await KhaltiPaymentRepository.initiatePayment(
                                amount: amount,
                                orderId: orderId,
                                orderName: orderName,
                                returnUrl: returnUrl,
                                customerInfo: customerInfo,
                                amountBreakdown: amountBreakdown,
                                productDetails: productDetails,
                              );
                          final pidx = paymentResp['pidx'] as String?;
                          _lastPidx = pidx;
                          if (pidx != null) {
                            // Use Khalti Flutter SDK to show payment UI
                            final payConfig = KhaltiPayConfig(
                              publicKey: '8d28b7de3e4a4a408fc6aeddab0cb860',
                              pidx: pidx,
                              environment:
                                  Environment.test, // or Environment.live
                            );
                            await Khalti.init(
                              enableDebugging: true,
                              payConfig: payConfig,
                              onPaymentResult: (paymentResult, khalti) async {
                                final paymentPayload = paymentResult.payload;
                                final token = paymentPayload?.pidx;
                                final amount = paymentPayload?.totalAmount;
                                _lastPidx = token;
                                if (token != null && amount != null) {
                                  // Removed redundant KhaltiPaymentRepository.lookupPayment call here.
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Token or amount missing in payment payload!',
                                      ),
                                    ),
                                  );
                                }
                                khalti.close(context);
                                // After closing Khalti view, lookup payment status
                              },
                              onMessage: (
                                khalti, {
                                description,
                                statusCode,
                                event,
                                returnUrl,
                                needsPaymentConfirmation,
                              }) async {
                                final tripId = _getTripId();
                                final seatLabel = _getSeatLabel();
                                if (_lastPidx != null && _lastPidx!.isNotEmpty && tripId != null && seatLabel != null) {
                                  
                                  try {
                                    await KhaltiPaymentRepository.lookupPayment(
                                      pidx: _lastPidx!,
                                      tripId: tripId,
                                      seatLabels: widget.selectedSeats,
                                      caller: 'onMessage',
                                    );
                                    // If lookup is successful, navigate to /home
                                   
                                    if (!mounted) return;
                                    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/home', (route) => false);
                                  } catch (e) {
                                  
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Payment lookup failed: $e'),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No pidx/tripId/seatLabel found for lookup'),
                                    ),
                                  );
                                }
                                khalti.close(context);
                              },
                              onReturn: () async {
                                if (!mounted) return;
                                try {
                                  final tripId = _getTripId();
                                  final seatLabel = _getSeatLabel();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lookup error: $e'),
                                    ),
                                  );
                                }
                              },
                            ).then((khalti) => khalti.open(context));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Failed to get payment session from backend',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Khalti payment failed: $e'),
                            ),
                          );
                        }
                      },
                      child: const Text('Pay with Khalti'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
