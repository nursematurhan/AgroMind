import 'package:agromind/SplashScreen.dart';
import 'package:agromind/location/map_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'components/root_page.dart';
import 'location/manuel_address_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/map': (context) => const MapPage(),
        '/manual': (context) => const ManuelAddressPage(),
      },
    );
  }
}