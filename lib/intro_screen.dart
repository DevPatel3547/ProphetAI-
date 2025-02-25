// lib/intro_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'prophet_screen.dart';
import 'how_to_use_screen.dart';
import 'documentation_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<SymbolParticle> particles = [];
  final Random random = Random();

  // Some random math/science symbols
  final List<String> symbols = ['π', '∑', '∆', '√', '∫', 'θ', 'λ', 'Ω', '≈', '∞', 'µ', 'α'];

  @override
  void initState() {
    super.initState();
    // Animate continuously
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();

    // Create 30 random symbol particles
    for (int i = 0; i < 30; i++) {
      particles.add(
        SymbolParticle(
          symbol: symbols[random.nextInt(symbols.length)],
          x: random.nextDouble(),
          y: random.nextDouble(),
          vx: (random.nextDouble() - 0.5) * 0.005,
          vy: (random.nextDouble() - 0.5) * 0.005,
          fontSize: 22 + random.nextDouble() * 18,
          color: Colors.primaries[random.nextInt(Colors.primaries.length)].withOpacity(0.4),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateParticles() {
    for (var p in particles) {
      p.x += p.vx;
      p.y += p.vy;
      if (p.x < 0 || p.x > 1) p.x = random.nextDouble();
      if (p.y < 0 || p.y > 1) p.y = random.nextDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          _updateParticles();
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF050505), Color(0xFF1A1A1A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  painter: SymbolParticlePainter(particles),
                  child: Container(),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Big Title
                      Text(
                        "Welcome to ProphetAI",
                        style: TextStyle(
                          fontFamily: 'Lobster',
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      // Subtitle
                      Text(
                        "Calculate the probability of anything, instantly.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // Row of 3 buttons: Start + Documentation + How to Use
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow, color: Colors.white),
                            label: const Text("Start", style: TextStyle(color: Colors.white, fontSize: 18)),
                            onPressed: () {
                              // Normal push => fade
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => const ProphetScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.menu_book, color: Colors.white),
                            label: const Text("Documentation", style: TextStyle(color: Colors.white, fontSize: 18)),
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
                          const SizedBox(width: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.help_outline, color: Colors.white),
                            label: const Text("How to Use", style: TextStyle(color: Colors.white, fontSize: 18)),
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
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Particle logic
class SymbolParticle {
  String symbol;
  double x, y;
  double vx, vy;
  double fontSize;
  Color color;
  SymbolParticle({
    required this.symbol,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.fontSize,
    required this.color,
  });
}

class SymbolParticlePainter extends CustomPainter {
  final List<SymbolParticle> particles;
  SymbolParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final pos = Offset(p.x * size.width, p.y * size.height);
      final textPainter = TextPainter(
        text: TextSpan(
          text: p.symbol,
          style: TextStyle(fontSize: p.fontSize, color: p.color, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, pos);
    }
  }

  @override
  bool shouldRepaint(covariant SymbolParticlePainter oldDelegate) => true;
}
