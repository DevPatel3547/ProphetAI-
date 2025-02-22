// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'math_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static const String apiUrl = "https://api.together.xyz/v1/chat/completions";
  static final String apiKey = dotenv.env['TOGETHER_API_KEY'] ?? "";
  static const String modelName = "meta-llama/Llama-3.3-70B-Instruct-Turbo-Free";

  /// Calls the Together API to extract a math expression from the query.
  static Future<Map<String, dynamic>?> getStructuredResponse(String query) async {
    final messages = [
      {
        "role": "system",
        "content":
            "Extract all necessary parameters from the following question and output ONLY a JSON object with a key 'expression' containing a valid mathematical expression (using standard arithmetic operators) that evaluates to a probability between 0 and 1. Do not include any additional text."
      },
      {"role": "user", "content": query}
    ];

    final body = jsonEncode({
      "model": modelName,
      "messages": messages,
    });

    final headers = {
      "Authorization": "Bearer $apiKey",
      "Content-Type": "application/json"
    };

    try {
      final response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        String content = jsonResponse["choices"][0]["message"]["content"].trim();
        // Attempt to parse the content as JSON.
        return jsonDecode(content);
      } else {
        return {"error": "Error: ${response.statusCode} - ${response.body}"};
      }
    } catch (e) {
      return {"error": "Error: $e"};
    }
  }

  /// Hybrid method: Uses AI to extract a math expression, then uses MathService to evaluate it.
  static Future<String> getHybridProbability(String query) async {
    final structured = await getStructuredResponse(query);
    if (structured == null) return "Error: Structured response is null";
    if (structured.containsKey("error")) return structured["error"];
    if (structured.containsKey("expression")) {
      String expression = structured["expression"];
      String? mathResult = await MathService.calculateExpression(expression);
      if (mathResult != null && double.tryParse(mathResult) != null) {
        return mathResult;
      } else {
        return "Error: Math evaluation failed.";
      }
    }
    return "Error: No expression found.";
  }

  /// Main entry point to get the probability using the hybrid approach.
  static Future<String> getProbability(String query) async {
    return await getHybridProbability(query);
  }
}
