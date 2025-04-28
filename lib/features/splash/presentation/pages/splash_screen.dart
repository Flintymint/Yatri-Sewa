import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Simulate a loading delay, then navigate
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.directions_bus, size: 60, color: colorScheme.onPrimary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Yatri-Sewa',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            _loading
                ? CircularProgressIndicator(color: colorScheme.primary)
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
