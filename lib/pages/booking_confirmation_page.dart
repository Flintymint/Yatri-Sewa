import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yatrisewa/models/bus_reservation.dart';
import 'package:yatrisewa/models/bus_schedule.dart';
import 'package:yatrisewa/models/customer.dart';
import 'package:yatrisewa/providers/app_data_provider.dart';
import 'package:yatrisewa/utils/constants.dart';

import '../utils/helper_functions.dart';

class BookingConfirmationPage extends StatefulWidget {
  const BookingConfirmationPage({super.key});

  @override
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  late BusSchedule schedule;
  late String departureDate;
  late int totalSeatsBooked;
  late String seatNumbers;
  bool isFirst = true;
  final _formkey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    nameController.text = 'Mr. Sandy';
    mobileController.text = '001122334455';
    emailController.text = 'sandy@gmail.com';
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isFirst) {
      final argList = ModalRoute
          .of(context)!
          .settings
          .arguments as List;
      departureDate = argList[0];
      schedule = argList[1];
      seatNumbers = argList[2];
      totalSeatsBooked = argList[3];
      isFirst = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Booking'),
      ),
      body: Form(
          key: _formkey,
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Please provide your information',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Customer Name',
                    filled: true,
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return emptyFieldErrMessage;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Mobile Number',
                      filled: true,
                      prefixIcon: const Icon(Icons.call),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return emptyFieldErrMessage;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {});
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'E-mail Address',
                      filled: true,
                      prefixIcon: const Icon(Icons.mail),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return emptyFieldErrMessage;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {});
                    }),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Booking Info',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer Name: ${nameController.text}'),
                      Text('Mobile Number: ${mobileController.text}'),
                      Text('Email Address: ${emailController.text}'),
                      Text('Route: ${schedule.busRoute.routeName}'),
                      Text('Departure Date: $departureDate'),
                      Text('Departure Time: ${schedule.departureTime}'),
                      Text('Ticket Price: $currency${schedule.ticketPrice}'),
                      Text('Total Seat(s): $totalSeatsBooked'),
                      Text('Seat Number(s): $seatNumbers'),
                      Text('Discount: ${schedule.discount}%'),
                      Text('Processing Fee: ${schedule.processingFee}%'),
                      Text(
                          'Grand Total: $currency${getGrandTotal(
                              schedule.discount, totalSeatsBooked,
                              schedule.ticketPrice, schedule.processingFee)}'),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _confirmBooking,
                child: const Text('CONFIRM BOOKING'),
              )
            ],
          )),
    );
  }

  void _confirmBooking() {
    if (_formkey.currentState!.validate()) {
      final customer = Customer(
        customerName: nameController.text,
        mobile: mobileController.text,
        email: emailController.text,
      );

      final reservation = BusReservation(customer: customer,
          busSchedule: schedule,
          timestamp: DateTime
              .now()
              .microsecondsSinceEpoch,
          departureDate: departureDate,
          totalSeatBooked: totalSeatsBooked,
          seatNumbers: seatNumbers,
          reservationStatus: reservationActive,
          totalPrice: getGrandTotal(
              schedule.discount, totalSeatsBooked, schedule.ticketPrice, schedule.processingFee),
      );
      Provider.of<AppDataProvider>(context, listen: false)
      .addReservation(reservation)
      .then((response){
        if (response.responseStatus == ResponseStatus.SAVED){
          showMsg(context, response.message);
          Navigator.popUntil(context, ModalRoute.withName(routeNameHome));
          }else{
          showMsg(context, response.message);
        }
      })
      .catchError((error){
        showMsg(context, 'Could not save');
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
