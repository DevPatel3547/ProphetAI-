// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'documentation_screen.dart';
import 'api_service.dart';
import 'db_service.dart';
import 'math_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env from "assets/.env" without "assets/" prefix
  await dotenv.load(fileName: ".env");
  runApp(ProbabilityApp());
}

class ProbabilityApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProbabilityProvider(),
      child: MaterialApp(
        title: 'Probability Calculator',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
      body: Container(
        // Use a gradient from Colors.blue.shade100 to Colors.white
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Custom top bar
                  Container(
                    color: Colors.blue.shade50,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.bubble_chart, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Probability Calculator',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.menu_book, color: Colors.blue),
                          tooltip: "Documentation",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => DocumentationScreen()),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.clear_all, color: Colors.blue),
                          tooltip: "Clear Conversation",
                          onPressed: () {
                            provider.clearConversation();
                          },
                        ),
                      ],
                    ),
                  ),
                  // If we have a queue message
                  if (provider.queueMessage.isNotEmpty)
                    Container(
                      color: Colors.yellow.shade100,
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          provider.queueMessage,
                          style: TextStyle(fontSize: 14, color: Colors.brown),
                        ),
                      ),
                    ),
                  Divider(height: 1, color: Colors.blue.shade200),
                  // Conversation area
                  Expanded(
                    child: provider.conversation.isEmpty
                        ? Center(
                            child: Text(
                              "Your conversation will appear here.",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: provider.conversation.length,
                            itemBuilder: (context, index) {
                              final msg = provider.conversation[index];
                              return ChatBubble(
                                question: msg["question"]!,
                                probability: msg["probability"]!,
                                shortExplanation: msg["shortExplanation"]!,
                                detailedExplanation: msg["detailedExplanation"]!,
                              );
                            },
                          ),
                  ),
                  Divider(height: 1, color: Colors.blue.shade200),
                  // Input area
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: "Enter your probability question...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                provider.calculateProbability(value.trim());
                                controller.clear();
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (controller.text.trim().isNotEmpty) {
                              provider.calculateProbability(controller.text.trim());
                              controller.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding:
                                EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text("Send", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Loading overlay
              if (provider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text(
                          "Calculating...",
                          style: TextStyle(fontSize: 16, color: Colors.white),
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

class ChatBubble extends StatefulWidget {
  final String question;
  final String probability;
  final String shortExplanation;
  final String detailedExplanation;

  const ChatBubble({
    Key? key,
    required this.question,
    required this.probability,
    required this.shortExplanation,
    required this.detailedExplanation,
  }) : super(key: key);

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  bool showDetails = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // A short fade-in for the entire bubble
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question bubble
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Q: ${widget.question}",
              style: TextStyle(fontSize: 16),
            ),
          ),
          // Answer bubble
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "A: ${widget.probability}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Short Explanation:\n${widget.shortExplanation}",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                if (!showDetails)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showDetails = true;
                      });
                    },
                    child: Text(
                      "Show More Details",
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                if (showDetails)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Detailed Explanation:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.detailedExplanation,
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showDetails = false;
                          });
                        },
                        child: Text(
                          "Hide Details",
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      )
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProbabilityProvider with ChangeNotifier {
  bool isLoading = false;
  String queueMessage = "";
  List<Map<String, String>> conversation = [];
  List<String> requestQueue = [];

  Future<void> calculateProbability(String event) async {
    // If there's a queue message, we queue new requests
    if (queueMessage.isNotEmpty) {
      requestQueue.add(event);
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    // Check cache
    String? cached = await DBService.getCachedResult(event);
    if (cached != null) {
      conversation.add({
        "question": event,
        "probability": "Cached: $cached",
        "shortExplanation": "Loaded from cache.",
        "detailedExplanation": "No further detail needed (from cache).",
      });
      isLoading = false;
      notifyListeners();
      return;
    }

    // AI synergy approach
    String raw = await AIService.getProbability(event);
    if (raw.startsWith("Error:")) {
      // Possibly 429 or rate-limited
      if (raw.contains("429") || raw.contains("rate limit") || raw.contains("out of tokens")) {
        queueMessage = "Queue: Rate-limited or out of tokens. Retrying in 60s...";
        conversation.add({
          "question": event,
          "probability": "0.000001",
          "shortExplanation": "Rate-limited or out of tokens.",
          "detailedExplanation": "We've queued your request. It will be retried automatically in 60s.",
        });
        requestQueue.add(event);
        isLoading = false;
        notifyListeners();

        // Start a 60-second timer to retry all queued items
        Future.delayed(Duration(seconds: 60), () => _retryQueue());
        return;
      } else {
        // Generic error
        conversation.add({
          "question": event,
          "probability": "0.000001",
          "shortExplanation": "All providers failed or invalid data.",
          "detailedExplanation": "Try again later or check your API keys.",
        });
        isLoading = false;
        notifyListeners();
        return;
      }
    }

    // Otherwise parse the "prob|short|detailed"
    List<String> parts = raw.split("|");
    double prob = double.tryParse(parts[0]) ?? 0.000001;
    if (prob < 1e-6) prob = 1e-6;
    String finalProb = prob.toStringAsFixed(6);

    String shortExp = (parts.length > 1) ? parts[1] : "No short explanation.";
    String detailExp = (parts.length > 2) ? parts[2] : "No detailed explanation.";

    conversation.add({
      "question": event,
      "probability": finalProb,
      "shortExplanation": shortExp,
      "detailedExplanation": detailExp,
    });

    await DBService.saveResult(event, "$finalProb | $shortExp | $detailExp");
    isLoading = false;
    notifyListeners();
  }

  void _retryQueue() async {
    // Clear queue message
    queueMessage = "";
    while (requestQueue.isNotEmpty) {
      final item = requestQueue.removeAt(0);
      await calculateProbability(item);
    }
    notifyListeners();
  }

  void clearConversation() {
    conversation.clear();
    queueMessage = "";
    requestQueue.clear();
    notifyListeners();
  }
}
