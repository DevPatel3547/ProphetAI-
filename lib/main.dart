// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_service.dart';
import 'db_service.dart';
import 'math_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures everything is set up before running
  await dotenv.load(fileName: ".env"); // Load environment variables
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

// lib/main.dart (excerpt)
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


class ProbabilityProvider with ChangeNotifier {
  String result = "";

  Future<void> calculateProbability(String event) async {
    // Check local cache first
    String? cached = await DBService.getCachedResult(event);
    if (cached != null) {
      result = "Cached: $cached";
      notifyListeners();
      return;
    }

    // For well-defined math events, use MathService; otherwise, use AI.
    if (event.toLowerCase().contains("coin") ||
        event.toLowerCase().contains("dice") ||
        event.toLowerCase().contains("lottery")) {
      String? mathResult = await MathService.calculateProbability(event);
      if (mathResult != null) {
        result = "Math Engine Result: $mathResult";
      } else {
        result = "Math Engine: Unable to calculate for this event.";
      }
    } else {
      result = await AIService.getProbability(event);
    }
    // Save the result to cache
    await DBService.saveResult(event, result);
    notifyListeners();
  }
}
