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
              // Top bar with "ProphetAI" => IntroScreen
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
                          fontFamily: 'Lobster',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Button to doc
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
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "1. Type your probability question in the text box.\n"
                        "2. ProphetAI uses multiple providers for the best synergy approach.\n"
                        "3. This is a personal project, so minimal storage and no conversation history.\n"
                        "   Provide as many details as you can for best accuracy.\n"
                        "4. If the system is rate-limited, your request is queued.\n"
                        "5. Short insights for a quick summary, or open 'Detailed Calculations' for paragraph + math.\n\n"
                        "Prompt Crafting:\n\n"
                        "• Good Prompt:\n"
                        "  \"What is the probability of me winning the lottery if I buy 2 tickets per week for 1 year?\"\n\n"
                        "• Bad Prompt:\n"
                        "  \"Lottery??\"\n\n"
                        "Basically, be specific and thorough. The synergy logic thrives on details.\n\n"
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
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
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
                      ),
                      const SizedBox(height: 40),
                      // Another funky icon
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
