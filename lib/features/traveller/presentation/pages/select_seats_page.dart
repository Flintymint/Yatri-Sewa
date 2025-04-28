import 'package:flutter/material.dart';
import 'package:drive/features/traveller/data/booking_repository.dart';
import 'package:drive/features/traveller/presentation/pages/booking_payment_page.dart';

class SelectSeatsPage extends StatefulWidget {
  final Map<String, dynamic> trip;
  const SelectSeatsPage({super.key, required this.trip});

  @override
  State<SelectSeatsPage> createState() => _SelectSeatsPageState();
}

class _SelectSeatsPageState extends State<SelectSeatsPage> {
  Set<String> selectedSeats = {};
  List<String> reservedSeats = [];
  bool _loadingReserved = true;

  void _fetchReservedSeats() async {
    setState(() {
      _loadingReserved = true;
    });
    final tripId = widget.trip['id'];
    final seats = await BookingRepository.fetchReservedSeats(tripId);
    setState(() {
      reservedSeats = seats;
      _loadingReserved = false;
    });
  }

  void _proceedToBooking() async {
    if (selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one seat.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPaymentPage(
          trip: widget.trip,
          selectedSeats: selectedSeats.toList(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchReservedSeats();
  }

  // --- Seat & Layout Builders (moved back to class scope) ---
  Widget _buildSeat(String label) {
    final isSelected = selectedSeats.contains(label);
    final isReserved = reservedSeats.contains(label);
    return GestureDetector(
      onTap: isReserved
          ? null
          : () {
              setState(() {
                if (isSelected) {
                  selectedSeats.remove(label);
                } else {
                  selectedSeats.add(label);
                }
              });
            },
      child: Container(
        margin: const EdgeInsets.all(4),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isReserved
              ? Colors.red
              : isSelected
                  ? Colors.blue
                  : Colors.transparent,
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildAcEconomyLayout() {
    List<List<String>> seatLabels = [];
    for (int i = 0; i < 16; i += 2) {
      seatLabels.add([
        'A${i+1}', 'A${i+2}',
        'B${i+1}', 'B${i+2}'
      ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              for (final row in seatLabels)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSeat(row[0]), _buildSeat(row[1]),
                    const SizedBox(width: 24),
                    _buildSeat(row[2]), _buildSeat(row[3]),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcBusinessLayout() {
    final seatRows = [
      ['A1', '', 'B1', 'B2'],
      ['A2', '', 'B3', 'B4'],
      ['A3', '', 'B5', 'B6'],
      ['A4', '', 'B7', 'B8'],
      ['A5', '', 'B9', 'B10'],
      ['A6', '', 'B11', 'B12'],
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              for (final row in seatRows)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final label in row)
                      label.isNotEmpty ? _buildSeat(label) : const SizedBox(width: 44, height: 44),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final busCategory = widget.trip['bus']?['category']?['name']?.toString().toLowerCase() ?? '';
    Widget seatLayout;
    String heading = widget.trip['bus']?['category']?['name']?.toString() ?? '';
    if (busCategory == 'ac business') {
      seatLayout = _buildAcBusinessLayout();
    } else {
      seatLayout = _buildAcEconomyLayout();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Seats'),
      ),
      backgroundColor: Colors.black,
      body: _loadingReserved
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    heading,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontFamily: 'Chalkboard', fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  seatLayout,
                  const SizedBox(height: 24),
                  Text(
                    'Selected Seats: ${selectedSeats.join(', ')}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _proceedToBooking,
                    child: const Text('Proceed to Booking'),
                  ),
                ],
              ),
            ),
    );
  }
}
