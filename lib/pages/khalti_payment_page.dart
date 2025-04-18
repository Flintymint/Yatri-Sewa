import 'package:flutter/material.dart';
import 'package:yatrisewa/models/bus_reservation.dart';
import 'package:yatrisewa/utils/constants.dart';

class KhaltiPaymentPage extends StatefulWidget {
  final BusReservation reservation;

  const KhaltiPaymentPage({Key? key, required this.reservation}) : super(key: key);

  @override
  State<KhaltiPaymentPage> createState() => _KhaltiPaymentPageState();
}

class _KhaltiPaymentPageState extends State<KhaltiPaymentPage> {
  late TextEditingController amountController;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(
        text: widget.reservation.totalPrice.toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    final reservation = widget.reservation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khalti Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),

            // Customer Info
            _buildSectionTitle('Customer Info'),
            _buildInfoRow('Name', reservation.customer.customerName),
            _buildInfoRow('Mobile', reservation.customer.mobile),
            _buildInfoRow('Email', reservation.customer.email),

            const SizedBox(height: 10),

            // Booking Details
            _buildSectionTitle('Booking Details'),
            _buildInfoRow('Route', reservation.busSchedule.busRoute.routeName),
            _buildInfoRow('Departure Date', reservation.departureDate),
            _buildInfoRow('Departure Time', reservation.busSchedule.departureTime),
            _buildInfoRow('Ticket Price', '$currency${reservation.busSchedule.ticketPrice}'),
            _buildInfoRow('Total Seats', '${reservation.totalSeatBooked}'),
            _buildInfoRow('Seat Numbers', reservation.seatNumbers),
            _buildInfoRow('Discount', '${reservation.busSchedule.discount}%'),
            _buildInfoRow('Processing Fee', '${reservation.busSchedule.processingFee}%'),

            const SizedBox(height: 10),

            // Grand Total
            _buildSectionTitle('Payment'),
            _buildInfoRow('Grand Total', '$currency${reservation.totalPrice.toStringAsFixed(2)}'),

            // Amount Input Field
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter Amount to Pay",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Payment Button
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.red),
              ),
              height: 50,
              color: const Color(0xFF56328c),
              child: const Text(
                'Pay With Khalti',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              onPressed: () {
                // Handle Khalti Payment Processing Here
                double amount = double.tryParse(amountController.text) ?? 0;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Processing Rs. ${amount.toStringAsFixed(2)} payment...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}
