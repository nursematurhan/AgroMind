import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Layout/guest_layout.dart';
import '../login/auth_page.dart';
import '../pages/main_screen.dart';
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            return const AuthPage();
          } else {
            return const GuestMainScreen();
          }
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
