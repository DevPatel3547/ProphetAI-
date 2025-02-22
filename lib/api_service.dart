import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static const String apiUrl = "https://api.together.xyz/v1/chat/completions";
  static const String modelName = "deepseek-ai/DeepSeek-R1-Distill-Llama-70B-free";

  /// Sends a query to the Together AI API with an instruction to only output a number.
  static Future<String> getProbability(String query) async {
    final String apiKey = dotenv.env['API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      return "Error: API key is missing!";
    }

    final messages = [
      {
        "role": "system",
        "content": "When answering the following question, please provide only a single numeric value between 0 and 1 representing the probability. Do not include any text or explanation."
      },
      {
        "role": "user",
        "content": query
      }
    ];

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "model": modelName,
        "messages": messages,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse["choices"][0]["message"]["content"].trim();
    } else {
      return "Error: ${response.statusCode} - ${response.body}";
    }
  }
}
