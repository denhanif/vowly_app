import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/onboarding'); // Berubah ke onboarding
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPink, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/image_7919a6.png',
              height: 150, 
              errorBuilder: (context, error, stackTrace) {
                return const Text('V O W L Y', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, fontFamily: 'Serif', letterSpacing: 4.0));
              },
            ),
            const SizedBox(height: 20),
            const Text('Semua kebutuhan pernikahan\nmenjadi lebih mudah', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 50),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 14, color: Colors.black),
                SizedBox(width: 8),
                Icon(Icons.circle, size: 20, color: Colors.black),
                SizedBox(width: 8),
                Icon(Icons.circle, size: 14, color: Colors.black),
              ],
            ),
          ],
        ),
      ),
    );
  }
}