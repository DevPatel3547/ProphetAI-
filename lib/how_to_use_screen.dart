// lib/how_to_use_screen.dart
import 'package:flutter/material.dart';
import 'intro_screen.dart';
import 'documentation_screen.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Funky gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1F1F1F), Color(0xFF2E2E2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with "ProphetAI" text => IntroScreen
              Container(
                color: Colors.black.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const IntroScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                          ),
                        );
                      },
                      child: Text(
                        'ProphetAI',
                        style: TextStyle(
                          fontFamily: 'Lobster', // fallback "funky" font
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Optional: a doc link if you want direct doc from here
                    IconButton(
                      tooltip: "Documentation",
                      icon: const Icon(Icons.menu_book, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const DocumentationScreen(),
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

              // Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "How to Use ProphetAI",
                        style: TextStyle(
                          fontFamily: 'Lobster',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "1. Type your probability question in the text box.\n"
                        "2. ProphetAI uses multiple providers for the best synergy approach.\n"
                        "3. This is a personal project, so our storage is minimal and we do not keep a conversation history.\n"
                        "   For best results, please enter all relevant details of your scenario.\n"
                        "4. If the system is rate-limited, your request is queued and retried automatically.\n"
                        "5. Check the short insights for a quick summary, or see 'Detailed Calculations' for paragraph and math details.\n\n"
                        "Enjoy this funky, modern app with a dark vibe!",
                        style: TextStyle(
                          fontFamily: 'Lobster',
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Link to doc
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.menu_book, color: Colors.white),
                          label: const Text(
                            "View Documentation",
                            style: TextStyle(fontFamily: 'Lobster', color: Colors.white, fontSize: 16),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const DocumentationScreen(),
                                transitionsBuilder:
                                    (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Funky icon at bottom
                      Center(
                        child: Icon(Icons.bubble_chart, color: Colors.blueAccent, size: 60),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
