// lib/how_to_use_screen.dart
import 'package:flutter/material.dart';
import 'intro_screen.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF101010), Color(0xFF1F1F1F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  "How to Use ProphetAI",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      "1. Type your probability question in the text box.\n\n"
                      "2. ProphetAI uses multiple providers to find the best synergy approach.\n\n"
                      "3. We do not store conversation history due to limited storage.\n"
                      "   Each new question is handled independently.\n\n"
                      "4. If the system is rate-limited, your request is queued and retried automatically.\n\n"
                      "5. Check the short insights for a quick summary, or open 'Detailed Calculations' for paragraph and math details.\n\n"
                      "Enjoy this funky, modern app with a dark vibe!",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text("Back to Home", style: TextStyle(color: Colors.white, fontSize: 18)),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const IntroScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
