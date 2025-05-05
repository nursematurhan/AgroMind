import 'package:agromind/post_pages/map_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'components/root_page.dart';   // login öncesi menülü yapı

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
      home: const RootPage(),  // 🌟 Buraya yönlendirme sayfası
      routes: {
        '/map': (context) => const MapPage(),  // <--- Harita sayfası route'u
      },
    );
  }
}
