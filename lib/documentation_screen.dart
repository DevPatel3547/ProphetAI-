// lib/documentation_screen.dart
import 'package:flutter/material.dart';

class DocumentationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Documentation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            "Probability Calculator Documentation\n\n"
            "Overview:\n"
            "- This app estimates the probability of any event as a numeric value (0-1).\n"
            "- It uses a hybrid approach where the AI extracts a math expression and a detailed explanation, and the expression is evaluated locally.\n\n"
            "Features:\n"
            "- Chat-style UI with conversation history.\n"
            "- Loading indicator during API calls.\n"
            "- Detailed calculation explanation accessible via expansion.\n"
            "- Documentation and conversation clear buttons.\n\n"
            "Future Enhancements:\n"
            "- Additional API rotation if needed.\n"
            "- More advanced math parsing and combination of multiple sources.\n"
            "- Further UI animations and custom styling.\n",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
