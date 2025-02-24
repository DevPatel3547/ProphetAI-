// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'intro_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load your .env from assets/.env (declared in pubspec.yaml)
  await dotenv.load(fileName: ".env");
  runApp(const ProphetAIApp());
}

class ProphetAIApp extends StatelessWidget {
  const ProphetAIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProphetAI',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101010),
        primaryColor: Colors.deepPurpleAccent,
        fontFamily: 'Trebuchet MS', // use a fun built-in font
        useMaterial3: true,
      ),
      home: const IntroScreen(), // Start with the animated intro screen
    );
  }
}
