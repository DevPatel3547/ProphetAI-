// lib/documentation_screen.dart
import 'package:flutter/material.dart';
import 'intro_screen.dart';
import 'how_to_use_screen.dart';

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
                        // Normal push => fade
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
                          fontFamily: 'Lobster', // fallback approach
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // A button to go to HowToUse
                    IconButton(
                      tooltip: "How to Use",
                      icon: const Icon(Icons.help_outline, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const HowToUseScreen(),
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
              // body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Big heading
                      Text(
                        "ProphetAI Documentation",
                        style: TextStyle(
                          fontFamily: 'Lobster',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Explanation
                      Text(
                        "Welcome to the official documentation for ProphetAI. I created this project to compute probabilities "
                        "for any event using multiple free AI providers, while ensuring zero cost. ProphetAI is built in Flutter and "
                        "can run on iOS, Android, Windows, and beyond, thanks to Flutter's cross-platform capabilities.\n\n"
                        "Throughout development, I encountered numerous obstacles, from invalid JSON responses to daily usage caps, but "
                        "I persevered to implement a robust synergy approach. Here’s a glimpse of my journey and the solutions I adopted:\n",
                        style: TextStyle(
                          fontFamily: 'Lobster',
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),

                      // Approaches & Problems
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.all(10),
                        color: Colors.black54,
                        child: const Text(
                          "Approaches I’ve Considered & Their Problems:\n\n"
                          "1) Running a Small AI Model on the User's Device\n"
                          "   - Eliminates API costs and ensures instant offline responses.\n"
                          "   - Even a small 2B parameter model is ~500MB, too large for a mobile app.\n"
                          "   - iOS restrictions and cross-platform issues complicate local inference.\n\n"
                          "2) Hosting My Own AI Model on a Cloud GPU\n"
                          "   - Full control with no rate limits.\n"
                          "   - Even the cheapest GPU is ~Dollar 20– Dollar 50/month, out of my personal budget.\n"
                          "   - Scaling would be expensive if user demand grows.\n\n"
                          "3) API Rotation + Queuing (My Current Partial Solution)\n"
                          "   - I rotate multiple free APIs => ~30 requests/min total.\n"
                          "   - Many APIs have daily/monthly caps or require credit cards.\n"
                          "   - Real-time queuing is still tricky for a production-level mobile app.\n",
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ),

                      Text(
                        "Ultimately, I ended up rotating free APIs in a HashMap for O(1) selection, so I can handle around 30 RPM across them. "
                        "This is definitely insufficient for large-scale usage, but it works for a personal project with minimal usage.\n\n"
                        "I overcame issues with daily usage caps, invalid JSON from certain providers, and the need for local caching to reduce repeated queries. "
                        "Additionally, I integrated a local math approach so probabilities never truly hit zero (clamping at 0.000001) "
                        "and I can handle basic combinatorial logic for certain events.\n\n",
                        style: TextStyle(
                          fontFamily: 'Lobster',
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),

                      // ASCII diagram
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.all(10),
                        color: Colors.black54,
                        child: Text(
                          """
        +---------------+      +----------------+
        |   Math Svc    | <--> |  AI Synergy   |
        +---------------+      +----------------+
                 \\                /
                  \\   synergy   /
                   \\           /
                    +---------+
                     Probability 
                     Calculator 
                          ^
                          |
                     [User Query]
                          |
        [Together, OpenRouter, Groq, Cohere, Mistral]
                          |
             [Local Caching & Rate-Limit Queuing]
""",
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),

                      Text(
                        "I want to emphasize: ProphetAI is NOT just a simple LLM wrapper. I:\n"
                        "• Provide synergy across five free providers.\n"
                        "• Implement local caching with minimal storage.\n"
                        "• Combine math computations with AI reasoning.\n\n"
                        "Because this is a personal project, I cannot afford dedicated GPU hosting or large-scale usage. "
                        "If I exceed free tier limits, I queue or rate-limit requests.\n\n"
                        "For best results:\n"
                        "• Provide as many scenario details as possible.\n"
                        "• Understand that each provider might have daily caps.\n"
                        "• Probability is never truly 0, so I clamp to 0.000001.\n"
                        "• The short_explanation is a quick summary.\n"
                        "• The math_explanation reveals the formula or logic used.\n\n"
                        "If you're curious about how to craft the best queries or prompts, check out my 'How to Use' page next.\n",
                        style: TextStyle(
                          fontFamily: 'Lobster',
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),

                      // Button linking to how to use
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
                          icon: const Icon(Icons.help_outline, color: Colors.white),
                          label: const Text(
                            "Go to How to Use",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const HowToUseScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),
                      // Maybe an icon at bottom
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
