import 'package:flutter/material.dart';
import 'package:agromind/login/login_page.dart';
import '../login/register_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AgroMind"),
        centerTitle: true,
        backgroundColor: Colors.green[800],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                const Text(
                  "🌿 AgroMind empowers individuals and communities with smart agricultural solutions. We provide tailored product recommendations, insightful content, and crop strategies to improve sustainable farming in the African region.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset("lib/images/img.jpeg"),
                ),
                const SizedBox(height: 30),

                const Text(
                  '🌍 About Us',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                const Text(
                  'AgroMind is dedicated to transforming agriculture through technology. We focus on optimizing planting decisions with personalized data and predictive insights tailored to local conditions.',
                ),
                const SizedBox(height: 20),

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset("lib/images/img2.jpeg"),
                ),
                const SizedBox(height: 30),

                const Text(
                  '⚙️ How It Works',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "1. Sign up or log in\n"
                      "2. Explore informative blogs\n"
                      "3. Get location-based product suggestions\n"
                      "4. Track and view your decision history at any time.",
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(onTap: null),
                          ),
                        );
                      },
                      icon: const Icon(Icons.login),
                      label: const Text("Log In"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(onTap: null),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text("Register"),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
