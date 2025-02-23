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

// Inside main.dart (ProbabilityProvider)
class ProbabilityProvider with ChangeNotifier {
  String result = "";

  Future<void> calculateProbability(String event) async {
    // 1) Check local cache
    String? cached = await DBService.getCachedResult(event);
    if (cached != null) {
      result = "Cached: $cached";
      notifyListeners();
      return;
    }

    // 2) Local Math synergy
    List<double> combinedVals = [];
    double? localVal = MathService.parseExpression(event);
    if (localVal != null) {
      combinedVals.add(localVal);
    }

    // 3) AI concurrency
    List<double> aiVals = await AIService.getProbabilityConcurrent(event);
    combinedVals.addAll(aiVals);

    // 4) Evaluate final result
    if (combinedVals.isEmpty) {
      // No numeric results => error or rate limit
      result = "Error: Could not compute any probability (0 results).";
    } else {
      double avg = combinedVals.reduce((a, b) => a + b) / combinedVals.length;
      if (avg < 1e-6) {
        avg = 1e-6; // never zero
      }
      result = avg.toStringAsFixed(6);
    }

    // 5) Cache & notify
    await DBService.saveResult(event, result);
    notifyListeners();
  }
}



