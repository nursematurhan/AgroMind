import 'package:flutter/material.dart';
import 'package:agromind/login/register_page.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  late Timer _sliderTimer;
  int _currentPage = 0;

  final String didYouKnow =
      "Did you know? Tomatoes are the most consumed vegetable globally.";
  final String todaysTip =
      "Today’s tip: Water your crops early in the morning to prevent evaporation.";

  final List<Map<String, String>> sliderContents = [
    {
      "title": "1 – Set Your Location",
      "text":
      "Choose your location so we can recommend the right crops based on your local weather and soil."
    },
    {
      "title": "2 – Get Smart Crop Suggestions",
      "text": "We analyze your climate and soil to suggest the best crops."
    },
    {
      "title": "3 – Explore & Learn",
      "text": "Visit our blog for farming tips and soil guides."
    },
    {
      "title": "4 – Track & Improve",
      "text": "Save and track your crop recommendations each season."
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _sliderTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % sliderContents.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sliderTimer.cancel();
    super.dispose();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "☀️ Good Morning";
    if (hour >= 12 && hour < 17) return "🌞 Good Day";
    if (hour >= 17 && hour < 21) return "🌇 Good Evening";
    return "🌙 Good Night";
  }


  @override
  Widget build(BuildContext context) {
    final greeting = getGreeting();

    return Scaffold(
      appBar: AppBar(
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
                const SizedBox(height: 25),
                Text(
                  greeting,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Text(didYouKnow),
                ),
                const SizedBox(height: 15),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Text(todaysTip),
                ),
                const SizedBox(height: 25),

                const Text(
                  '⚙️ How It Works',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 140,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: sliderContents.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        color: Colors.orange[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sliderContents[index]['title']!,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                sliderContents[index]['text']!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // 🌱 ABOUT SECTION
                const Text(
                  '🌱 About AgroMind',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    "Agromind is a smart assistant for every farmer, grower, or curious beginner who wants to make better decisions in agriculture.\n\n"
                        "We help you choose the right crops based on your location, climate, and growing season. Whether you’re starting from scratch or managing an existing field, Agromind gives you tailored crop recommendations, educational blog articles, and practical tips — all in one place.\n\n"
                        "Our mission is simple: To make sustainable farming easier, smarter, and accessible to everyone.",
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),

                const SizedBox(height: 30),

                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterPage(onTap: null)),
                          );
                        },
                        child: const Text("Let’s Get Started!"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                        ),
                      ),
                    ],
                  ),
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
