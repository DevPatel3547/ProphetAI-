// lib/api_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class APIConfig {
  static List<Map<String, String>> get providers => [
        {
          "name": "together",
          "apiUrl": "https://api.together.xyz/v1/chat/completions",
          "model": "meta-llama/Llama-3.3-70B-Instruct-Turbo-Free",
          "apiKey": dotenv.env['TOGETHER_API_KEY'] ?? ""
        },
        // You can add more providers here if needed.
      ];
}
