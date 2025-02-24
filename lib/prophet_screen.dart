// lib/prophet_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'documentation_screen.dart';
import 'intro_screen.dart'; // So we can go "Home"
import 'api_service.dart' as synergy;
import 'db_service.dart';
import 'math_service.dart';

class ProphetScreen extends StatelessWidget {
  const ProphetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProphetProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFF101010),
        body: SafeArea(child: ProphetChatUI()),
      ),
    );
  }
}

class ProphetChatUI extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  ProphetChatUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProphetProvider>(context);
    return Stack(
      children: [
        Column(
          children: [
            // Top bar
            Container(
              color: const Color(0xFF202123),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'ProphetAI',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  // New "Home" icon button
                  IconButton(
                    tooltip: "Home",
                    icon: const Icon(Icons.home_outlined, color: Colors.white),
                    onPressed: () {
                      // Fade transition back to IntroScreen
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const IntroScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                        ),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: "Documentation",
                    icon: const Icon(Icons.menu_book, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DocumentationScreen()),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: "Clear Conversation",
                    icon: const Icon(Icons.clear_all, color: Colors.white),
                    onPressed: () {
                      provider.clearConversation();
                    },
                  ),
                ],
              ),
            ),
            if (provider.queueMessage.isNotEmpty)
              Container(
                color: Colors.amber.shade100,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: Text(
                  provider.queueMessage,
                  style: const TextStyle(fontSize: 14, color: Colors.brown),
                ),
              ),
            const Divider(height: 1, color: Colors.grey),
            Expanded(
              child: Consumer<ProphetProvider>(
                builder: (context, provider, child) {
                  if (provider.conversation.isEmpty) {
                    return Center(
                      child: Text(
                        "Ask ProphetAI about any probability!",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.conversation.length,
                    itemBuilder: (context, index) {
                      if (index < 0 || index >= provider.conversation.length) return const SizedBox.shrink();
                      final msg = provider.conversation[index];
                      return ChatBubble(
                        role: msg["role"]!,
                        question: msg["question"]!,
                        confidenceScore: msg["confidenceScore"]!,
                        shortInsights: msg["shortInsights"]!,
                        paragraphDetail: msg["paragraphDetail"]!,
                        mathDetail: msg["mathDetail"]!,
                        isCached: msg["isCached"] == "true",
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            // Input row
            Consumer<ProphetProvider>(
              builder: (context, provider, child) {
                return Container(
                  color: const Color(0xFF202123),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: provider.inputController,
                          style: const TextStyle(color: Colors.white),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              provider.askProphet(value.trim());
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "Enter your question...",
                            hintStyle: const TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF303134),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: "Send",
                        icon: const Icon(Icons.send),
                        color: Colors.blueAccent,
                        onPressed: () {
                          final text = provider.inputController.text.trim();
                          if (text.isNotEmpty) {
                            provider.askProphet(text);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            Consumer<ProphetProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Container(
                    color: Colors.black.withOpacity(0.3),
                    height: 50,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.blueAccent),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Chat bubble with fade-in, showing confidence score and insights, with 2-tab detailed view.
class ChatBubble extends StatefulWidget {
  final String role; // "user" or "ai"
  final String question;
  final String confidenceScore; // e.g. "0.002500"
  final String shortInsights;
  final String paragraphDetail; // Paragraph tab content
  final String mathDetail;      // Math tab content
  final bool isCached;

  const ChatBubble({
    Key? key,
    required this.role,
    required this.question,
    required this.confidenceScore,
    required this.shortInsights,
    required this.paragraphDetail,
    required this.mathDetail,
    this.isCached = false,
  }) : super(key: key);

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> with SingleTickerProviderStateMixin {
  bool showDetails = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
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
    final isUser = widget.role == "user";
    final probVal = double.tryParse(widget.confidenceScore) ?? 0.0;
    final percentVal = probVal * 100;
    final percentStr = percentVal.toStringAsFixed(2);
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isUser ? Colors.teal.shade400 : const Color(0xFF303134);
    final textColor = isUser ? Colors.black : Colors.white;
    final radius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: radius,
            ),
            child: isUser
                ? Text(widget.question, style: const TextStyle(fontSize: 15))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Confidence: ${widget.confidenceScore} (~$percentStr%)",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.isCached ? Colors.orange : Colors.blueAccent.shade100,
                            ),
                          ),
                          if (widget.isCached)
                            const Text(
                              " (cached)",
                              style: TextStyle(fontSize: 13, color: Colors.orange),
                            )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Insights: ${widget.shortInsights}",
                        style: TextStyle(fontSize: 14, color: textColor),
                      ),
                      const SizedBox(height: 6),
                      if (!showDetails)
                        GestureDetector(
                          onTap: () => setState(() => showDetails = true),
                          child: const Text(
                            "Show Detailed Calculations",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.lightBlue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      if (showDetails)
                        DetailedTabs(
                          paragraph: widget.paragraphDetail,
                          math: widget.mathDetail,
                          onClose: () => setState(() => showDetails = false),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// A widget with 2 tabs: "Paragraph" and "Math" for detailed calculations.
class DetailedTabs extends StatefulWidget {
  final String paragraph;
  final String math;
  final VoidCallback onClose;

  const DetailedTabs({
    Key? key,
    required this.paragraph,
    required this.math,
    required this.onClose,
  }) : super(key: key);

  @override
  _DetailedTabsState createState() => _DetailedTabsState();
}

class _DetailedTabsState extends State<DetailedTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.lightBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.lightBlueAccent,
            tabs: const [
              Tab(text: "Paragraph"),
              Tab(text: "Math"),
            ],
          ),
          SizedBox(
            height: 150,
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Text(widget.paragraph, style: const TextStyle(fontSize: 14)),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Text(widget.math, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: widget.onClose,
            child: const Text(
              "Hide Details",
              style: TextStyle(
                fontSize: 13,
                color: Colors.lightBlue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The synergy provider for ProphetAI
class ProphetProvider with ChangeNotifier {
  bool isLoading = false;
  List<Map<String, String>> conversation = [];
  String queueMessage = "";
  final List<String> requestQueue = [];
  final TextEditingController inputController = TextEditingController();

  Future<void> askProphet(String event) async {
    inputController.clear();
    // Add user bubble
    conversation.add({
      "role": "user",
      "question": event,
      "confidenceScore": "",
      "shortInsights": "",
      "paragraphDetail": "",
      "mathDetail": "",
      "isCached": "false",
    });
    notifyListeners();

    if (queueMessage.isNotEmpty) {
      requestQueue.add(event);
      return;
    }

    isLoading = true;
    notifyListeners();

    // Check local cache
    String? cached = await DBService.getCachedResult(event);
    if (cached != null) {
      final cParts = cached.split("|"); // "conf|short|paragraph|math"
      String conf = cParts.isNotEmpty ? cParts[0] : "0.000001";
      String shortIn = cParts.length > 1 ? cParts[1] : "Cached short insights.";
      String paraIn = cParts.length > 2 ? cParts[2] : "Cached paragraph details.";
      String mathIn = cParts.length > 3 ? cParts[3] : "Cached math details.";
      conversation.add({
        "role": "ai",
        "question": "",
        "confidenceScore": conf,
        "shortInsights": shortIn,
        "paragraphDetail": paraIn,
        "mathDetail": mathIn,
        "isCached": "true",
      });
      isLoading = false;
      notifyListeners();
      return;
    }

    // Call synergy: returns "conf|short|paragraph|math"
    String raw = await synergy.AIService.getProbability(event);
    isLoading = false;
    if (raw.startsWith("Error:")) {
      if (raw.contains("429") || raw.contains("rate limit") || raw.contains("out of tokens")) {
        queueMessage = "Queue: Rate-limited. Retrying in 60s...";
        conversation.add({
          "role": "ai",
          "question": "",
          "confidenceScore": "0.000001",
          "shortInsights": "Rate-limited or out of tokens.",
          "paragraphDetail": "Your request is queued. We'll retry automatically in 60s.",
          "mathDetail": "",
          "isCached": "false",
        });
        notifyListeners();
        requestQueue.add(event);
        Timer(const Duration(seconds: 60), () => _retryQueue());
        return;
      } else {
        conversation.add({
          "role": "ai",
          "question": "",
          "confidenceScore": "0.000001",
          "shortInsights": "All providers failed or invalid data.",
          "paragraphDetail": "Try again later or check your API keys.",
          "mathDetail": "",
          "isCached": "false",
        });
        notifyListeners();
        return;
      }
    }

    final parts = raw.split("|"); // e.g. "0.002500|Short|Paragraph|Math"
    double prob = double.tryParse(parts[0]) ?? 0.000001;
    if (prob < 1e-6) prob = 1e-6;
    String finalProb = prob.toStringAsFixed(6);
    String shortExp = parts.length > 1 ? parts[1] : "No short insights.";
    String paraExp = parts.length > 2 ? parts[2] : "No paragraph details.";
    String mathExp = parts.length > 3 ? parts[3] : "No math details.";

    conversation.add({
      "role": "ai",
      "question": "",
      "confidenceScore": finalProb,
      "shortInsights": shortExp,
      "paragraphDetail": paraExp,
      "mathDetail": mathExp,
      "isCached": "false",
    });

    await DBService.saveResult(event, "$finalProb|$shortExp|$paraExp|$mathExp");
    notifyListeners();
  }

  void _retryQueue() async {
    queueMessage = "";
    while (requestQueue.isNotEmpty) {
      final item = requestQueue.removeAt(0);
      await askProphet(item);
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
