// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Data class for storing the four fields from the AI:
/// probability, short, paragraph, math
class AIProbabilityResult {
  final double probability;
  final String shortExplanation;
  final String paragraphExplanation;
  final String mathExplanation;

  AIProbabilityResult(
    this.probability,
    this.shortExplanation,
    this.paragraphExplanation,
    this.mathExplanation,
  );
}

class AIService {
  /// Public method: returns "prob|short|paragraph|math"
  static Future<String> getProbability(String query) async {
    final result = await getProbabilityResult(query);
    if (result == null) {
      return "Error: All providers failed or invalid data.";
    }
    double prob = result.probability;
    String shortExp = result.shortExplanation;
    String paragraphExp = result.paragraphExplanation;
    String mathExp = result.mathExplanation;

    return "${prob.toStringAsFixed(6)}|$shortExp|$paragraphExp|$mathExp";
  }

  /// Rotates through each provider in APIConfig until one returns a valid result.
  static Future<AIProbabilityResult?> getProbabilityResult(String query) async {
    for (var provider in APIConfig.providers) {
      final result = await _callProvider(provider, query);
      if (result != null) return result;
    }
    return null;
  }

  /// Calls one provider with a system prompt that demands 4 JSON keys:
  /// 1) "probability" (0 < p <= 1)
  /// 2) "short_explanation"
  /// 3) "paragraph_explanation"
  /// 4) "math_explanation"
  static Future<AIProbabilityResult?> _callProvider(Map<String, String> provider, String query) async {
    final name = provider['name']!;
    final apiUrl = provider['apiUrl']!;
    final apiKey = provider['apiKey']!;
    final model = provider['model']!;

    // The updated system prompt:
    const systemPrompt = """
You are an AI that calculates the probability of any event, returning exactly FOUR keys in JSON:
1) "probability" => numeric in (0,1], never 0 (clamp to 0.000001 if near zero).
2) "short_explanation" => 1-2 line summary.
3) "paragraph_explanation" => longer 3-5 line discussion in plain text.
4) "math_explanation" => the actual math or formula used in your reasoning.

Output ONLY this JSON. No extra text outside the JSON.
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

        // Extract the AI's textual output
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
                parsed.containsKey("paragraph_explanation") &&
                parsed.containsKey("math_explanation")) {

              double? prob = double.tryParse(parsed["probability"].toString());
              String shortExp = parsed["short_explanation"].toString();
              String paraExp = parsed["paragraph_explanation"].toString();
              String mathExp = parsed["math_explanation"].toString();

              if (prob != null && prob > 0 && prob <= 1) {
                // Final clamp
                if (prob < 1e-6) prob = 1e-6;
                return AIProbabilityResult(prob, shortExp, paraExp, mathExp);
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
}
