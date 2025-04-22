import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yatrisewa/pages/add_bus_page.dart';
import 'package:yatrisewa/pages/add_route_page.dart';
import 'package:yatrisewa/pages/add_schedule_page.dart';
import 'package:yatrisewa/pages/khalti_payment_page.dart';
import 'package:yatrisewa/pages/login_page.dart';
import 'package:yatrisewa/pages/reservation_page.dart';
import 'package:yatrisewa/pages/search_page.dart';
import 'package:yatrisewa/pages/search_result_page.dart';
import 'package:yatrisewa/pages/seat_plan_page.dart';
import 'package:yatrisewa/pages/view_bus_page.dart';
import 'package:yatrisewa/pages/view_bus_schedule_page.dart';
import 'package:yatrisewa/providers/app_data_provider.dart';
import 'package:yatrisewa/utils/constants.dart';

import 'pages/booking_confirmation_page.dart';


void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => AppDataProvider(),
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        brightness: Brightness.dark,
      ),
      initialRoute: routeNameHome,
      routes: {
        routeNameHome : (context) => const SearchPage(),
        routeNameSearchResultPage : (context) => const SearchResultPage(),
        routeNameSeatPlanPage : (context) => const SeatPlanPage(),
        routeNameBookingConfirmationPage : (context) => const BookingConfirmationPage(),
        //routeNameKhaltiPay : (context) => const KhaltiPaymentPage(),
        routeNameAddBusPage : (context) => const AddBusPage(),
        routeNameViewBuses : (context) => const ViewBusesPage(),
        routeNameAddRoutePage : (context) => const AddRoutePage(),
        routeNameAddSchedulePage : (context) => const AddSchedulePage(),
        routeNameViewBusSchedule : (context) => const ViewBusSchedulePage(),
        routeNameReservationPage : (context) => const ReservationPage(),
        routeNameLoginPage : (context) => const LoginPage(),

      },
    );
  }
}