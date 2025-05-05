import 'package:agromind/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_or_register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Giriş yapılmışsa MainScreen'e yönlendir
          if (snapshot.hasData) {
            print("🟢 Kullanıcı giriş yaptı: ${snapshot.data!.email}");
            return const MainScreen();
          } else {
            return const LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
