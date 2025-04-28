import 'package:flutter/material.dart';
import 'features/splash/presentation/pages/splash_screen.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/admin/presentation/pages/add_bus_stops.dart';
import 'features/traveller/presentation/pages/explore_trips_page.dart';
import 'features/traveller/presentation/pages/my_bookings_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yatri-Sewa App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF39D353),
          brightness: Brightness.dark,
          background: Colors.black,
          surface: Colors.black,
          surfaceVariant: const Color(0xFF121212),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: const Color(0xFF39D353), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF39D353).withOpacity(0.6),
              width: 1,
            ),
          ),
          border: const OutlineInputBorder(),
          hintStyle: TextStyle(color: const Color(0xFF39D353).withOpacity(0.7)),
          labelStyle: TextStyle(
            color: const Color(0xFF39D353).withOpacity(0.9),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF39D353),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF39D353),
          foregroundColor: Colors.black,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF121212),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dividerTheme: DividerTheme.of(
          context,
        ).copyWith(color: const Color(0xFF39D353).withOpacity(0.2)),
        listTileTheme: ListTileThemeData(
          iconColor: const Color(0xFF39D353),
          textColor: Colors.white,
        ),
        iconTheme: IconThemeData(color: const Color(0xFF39D353)),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF39D353);
            }
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF39D353).withOpacity(0.5);
            }
            return null;
          }),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF39D353);
            }
            return null;
          }),
          checkColor: WidgetStateProperty.all(Colors.black),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF39D353);
            }
            return null;
          }),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: const Color(0xFF39D353),
          thumbColor: const Color(0xFF39D353),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF39D353)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF39D353),
            foregroundColor: Colors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF39D353),
            side: const BorderSide(color: Color(0xFF39D353)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF39D353),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black.withValues(alpha: 70),
          indicator: const BoxDecoration(color: Color(0xFF39D353)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Color(0xFF39D353),
          unselectedItemColor: Colors.grey,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/my-bookings': (context) => const MyBookingsPage(),
        '/manage-bus-stops': (context) => const AddBusStopsPage(),
        '/explore': (context) => const ExploreTripsPage(),
      },
    );
  }
}
