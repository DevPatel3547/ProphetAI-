// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Data class to hold numeric probability plus short & detailed explanations.
class AIProbabilityResult {
  final double probability;
  final String shortExplanation;
  final String detailedExplanation;

  AIProbabilityResult(this.probability, this.shortExplanation, this.detailedExplanation);
}

class AIService {
  /// Rotates through each provider in APIConfig until one returns a valid result.
  static Future<AIProbabilityResult?> getProbabilityResult(String query) async {
    for (var provider in APIConfig.providers) {
      final result = await _callProvider(provider, query);
      if (result != null) return result;
    }
    return null;
  }

  /// Calls one provider with a system prompt that demands a JSON:
  /// {
  ///   "probability": <0-1 but not 0>,
  ///   "short_explanation": "<some short lines>",
  ///   "detailed_explanation": "<longer detail>",
  /// }
  static Future<AIProbabilityResult?> _callProvider(Map<String, String> provider, String query) async {
    final name = provider['name']!;
    final apiUrl = provider['apiUrl']!;
    final apiKey = provider['apiKey']!;
    final model = provider['model']!;

    const systemPrompt = """
You are an AI that calculates the probability of any event.
Output ONLY a JSON object with exactly three keys:
1) "probability": a numeric value between 0 and 1 (never 0, if it is near 0 clamp it to 0.000001).
2) "short_explanation": a brief 1-2 line explanation.
3) "detailed_explanation": a more thorough 5+ line explanation of the factors and math behind that probability.
No extra text outside the JSON.
""";

    Map<String, dynamic> requestBody;
    if (name == "cohere") {
      // Cohere uses { "model": "...", "message": "System: <prompt>\nUser: <query>" }
      final cohereMsg = "System: $systemPrompt\nUser: $query";
      requestBody = {
        "model": model,
        "message": cohereMsg,
      };
    } else {
      // For Together, OpenRouter, Groq => OpenAI-like chat format
      requestBody = {
        "model": model,
        "messages": [
          {"role": "system", "content": systemPrompt},
          {"role": "user", "content": query},
        ]
      };
    }

    final headers = {
      "Authorization": "Bearer $apiKey",
      "Content-Type": "application/json"
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // Parse response based on provider
        String rawOutput;
        if (name == "cohere") {
          // Cohere => { "reply": "some text" }
          rawOutput = jsonResponse["reply"]?.toString().trim() ?? "";
        } else {
          // Others => { "choices": [ { "message": { "content": "..." } } ] }
          rawOutput = jsonResponse["choices"]?[0]?["message"]?["content"]?.toString().trim() ?? "";
        }

        if (rawOutput.isNotEmpty) {
          // Attempt to parse the JSON
          try {
            final parsed = jsonDecode(rawOutput);
            if (parsed is Map &&
                parsed.containsKey("probability") &&
                parsed.containsKey("short_explanation") &&
                parsed.containsKey("detailed_explanation")) {
              double? prob = double.tryParse(parsed["probability"].toString());
              String shortExp = parsed["short_explanation"].toString();
              String detailedExp = parsed["detailed_explanation"].toString();
              if (prob != null && prob > 0 && prob <= 1) {
                // Final clamp
                if (prob < 1e-6) prob = 1e-6;
                return AIProbabilityResult(prob, shortExp, detailedExp);
              }
            }
          } catch (e) {
            print("Error parsing JSON from $name => $e");
          }
        }
      } else {
        print("Error from $name => ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Error calling $name => $e");
    }
    return null;
  }

  /// Public method: returns "probability|short_explanation|detailed_explanation"
  static Future<String> getProbability(String query) async {
    final result = await getProbabilityResult(query);
    if (result == null) {
      return "Error: All providers failed or invalid data.";
    }
    double prob = result.probability;
    String shortExp = result.shortExplanation;
    String detailedExp = result.detailedExplanation;

    return "${prob.toStringAsFixed(6)}|$shortExp|$detailedExp";
  }
}
