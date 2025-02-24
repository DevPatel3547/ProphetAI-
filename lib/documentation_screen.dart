// lib/documentation_screen.dart
import 'package:flutter/material.dart';
import 'intro_screen.dart';

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Full dark gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF2F2F2F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // top bar
              Container(
                color: Colors.black.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        // normal push => fade
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Possibly an icon or something else, or leave it empty
                  ],
                ),
              ),
              // body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ProphetAI Documentation",
                        style: TextStyle(
                          fontFamily: 'Lobster',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Overview:\n\n"
                        "• Uses a synergy approach with multiple providers and local caching.\n"
                        "• Confidence Score (numeric value and percentage) is provided along with insights.\n"
                        "• Detailed calculations are shown in two tabs: Paragraph and Math.\n"
                        "• If rate-limited, requests are queued and retried automatically.\n"
                        "• Press Enter or tap the send icon to submit queries.\n\n"
                        "Extra Info:\n\n"
                        "• This is a personal project with minimal storage; we do not keep conversation history.\n"
                        "• Make sure to include relevant details in your query for best accuracy.\n"
                        "• The short insights give a quick summary, while the math tab reveals deeper logic.\n\n"
                        "Thanks for checking out ProphetAI!",
                        style: TextStyle(
                          fontFamily: 'Lobster',
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // optional icon
                      Center(
                        child: Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 60),
                      ),
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
