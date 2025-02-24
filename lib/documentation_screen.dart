// lib/documentation_screen.dart
import 'package:flutter/material.dart';

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ProphetAI Documentation"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            "ProphetAI Documentation\n\n"
            "Overview:\n"
            "- Uses a synergy approach with multiple providers and local caching.\n"
            "- Confidence Score (numeric value and percentage) is provided along with insights.\n"
            "- Detailed calculations are shown in two tabs: Paragraph and Math.\n"
            "- If rate-limited, requests are queued and retried automatically.\n"
            "- Press Enter or tap the send icon to submit queries.\n\n"
            "Enjoy!",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
