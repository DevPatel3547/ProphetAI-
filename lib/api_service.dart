// lib/api_service.dart
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AIService {
  /// Calls a single provider with a numeric-only system prompt, returning numeric string or null.
  static Future<String?> _callProvider(
    Map<String, String> provider,
    String query,
    String systemPrompt,
  ) async {
    final name = provider['name']!;
    final apiUrl = provider['apiUrl']!;
    final apiKey = provider['apiKey']!;
    final model = provider['model']!;

    // Build request differently depending on provider.
    if (name == "cohere") {
      // Cohere uses { model: "command-r", message: "System: <prompt>\nUser: <query>" }
      final cohereMsg = "System: $systemPrompt\nUser: $query";
      final body = {
        "model": model,
        "message": cohereMsg,
      };
      return _postRequest(apiUrl, apiKey, body, providerName: name);
    } else {
      // For Together, OpenRouter, Groq => OpenAI-like format
      final body = {
        "model": model,
        "messages": [
          {"role": "system", "content": systemPrompt},
          {"role": "user", "content": query},
        ]
      };
      return _postRequest(apiUrl, apiKey, body, providerName: name);
    }
  }

  /// Helper to make the POST request and parse the result.
  static Future<String?> _postRequest(
    String apiUrl,
    String apiKey,
    Map<String, dynamic> body, {
    required String providerName,
  }) async {
    final headers = {
      "Authorization": "Bearer $apiKey",
      "Content-Type": "application/json"
    };

    try {
      final response = await http.post(Uri.parse(apiUrl),
          headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (providerName == "cohere") {
          // Cohere => { "reply": "some text" }
          if (jsonResponse["reply"] is String) {
            return jsonResponse["reply"].trim();
          }
        } else {
          // Together / OpenRouter / Groq => { "choices": [ { "message": { "content": "..." } } ] }
          if (jsonResponse["choices"] != null &&
              jsonResponse["choices"][0]["message"] != null) {
            return jsonResponse["choices"][0]["message"]["content"].trim();
          }
        }
      } else {
        print("Error from $providerName => ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Error calling $providerName => $e");
    }
    return null;
  }

  /// Calls all providers in parallel, returning a list of numeric results.
  static Future<List<double>> getProbabilityConcurrent(String query) async {
    // We'll define a short system prompt to force numeric-only output.
    const systemPrompt =
        "Answer only with a single numeric value between 0 and 1. No extra text.";

    // Launch all calls in parallel using Future.wait
    final futures = APIConfig.providers.map((provider) async {
      final rawResult = await _callProvider(provider, query, systemPrompt);
      if (rawResult != null) {
        final val = double.tryParse(rawResult);
        if (val != null) {
          return val;
        }
      }
      return null;
    }).toList();

    final results = await Future.wait(futures);
    // Filter out null
    return results.whereType<double>().toList();
  }
}
