// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_service.dart';
import 'db_service.dart';
import 'math_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure everything is set up
  await dotenv.load(fileName: ".env"); // Load API keys and config from .env file
  runApp(ProbabilityApp());
}

class ProbabilityApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProbabilityProvider(),
      child: MaterialApp(
        title: 'Probability Calculator',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: ProbabilityScreen(),
      ),
    );
  }
}

class ProbabilityScreen extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProbabilityProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Probability Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Enter an event (e.g., "coin", "dice", or an abstract question")',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.calculateProbability(controller.text),
              child: Text("Calculate Probability"),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  provider.result,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Inside lib/main.dart (ProbabilityProvider class)
class ProbabilityProvider with ChangeNotifier {
  String result = "";

  Future<void> calculateProbability(String event) async {
    // Check local cache first.
    String? cached = await DBService.getCachedResult(event);
    if (cached != null) {
      result = "Cached: $cached";
      notifyListeners();
      return;
    }

    // Use the hybrid method for all events.
    String hybridResult = await AIService.getProbability(event);

    // If the result indicates a rate limit or token error, simulate a queue.
    if (hybridResult.contains("rate limit") ||
        hybridResult.contains("out of tokens")) {
      result = "Queue: High demand detected. Please wait 60 seconds and try again.";
    } else {
      result = hybridResult;
    }

    await DBService.saveResult(event, result);
    notifyListeners();
  }
}


