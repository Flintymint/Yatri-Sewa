import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yatrisewa/pages/search_page.dart';
import 'package:yatrisewa/pages/search_result_page.dart';
import 'package:yatrisewa/pages/seat_plan_page.dart';
import 'package:yatrisewa/providers/app_data_provider.dart';
import 'package:yatrisewa/utils/constants.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create :(context) => AppDataProvider(),
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        brightness: Brightness.dark,
      ),
      home: SearchPage(),
      routes: {
        routeNameHome : (context) => const SearchPage(),
        routeNameSearchResultPage : (context) => const SearchResultPage(),
        routeNameSeatPlanPage : (context) => const SeatPlanPage(),
      },
    );
  }
}
