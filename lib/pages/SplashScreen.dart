import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agromind/components/root_page.dart'; // RootPage import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RootPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAEAE8),
      body: Center(
        child: Image.asset('lib/images/logo.png', width: 600),
      ),
    );
  }
}
