// lib/api_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class APIConfig {
  static List<Map<String, String>> get providers => [
        // 1️⃣ Together
        {
          "name": "together",
          "apiUrl": "https://api.together.xyz/v1/chat/completions",
          "model": "meta-llama/Llama-3.3-70B-Instruct-Turbo-Free",
          "apiKey": dotenv.env['TOGETHER_API_KEY'] ?? ""
        },
        // 2️⃣ OpenRouter
        {
          "name": "openrouter",
          "apiUrl": "https://openrouter.ai/api/v1/chat/completions",
          "model": "meta-llama/llama-3.3-70b-instruct:free",
          "apiKey": dotenv.env['OPENROUTER_API_KEY'] ?? ""
        },
        // 3️⃣ Groq
        {
          "name": "groq",
          "apiUrl": "https://api.groq.com/openai/v1/chat/completions",
          "model": "llama3-8b-8192",
          "apiKey": dotenv.env['GROQ_API_KEY'] ?? ""
        },
        // 4️⃣ Cohere
        {
          "name": "cohere",
          "apiUrl": "https://api.cohere.ai/v1/chat",
          "model": "command-r",
          "apiKey": dotenv.env['COHERE_API_KEY'] ?? ""
        },
        // 5️⃣ Mistral
        {
          "name": "mistral",
          "apiUrl": "https://api.mistral.ai/v1/chat/completions", 
          "model": "mistral-large-latest",  // Adjust if you have a different Mistral model
          "apiKey": dotenv.env['MISTRAL_API_KEY'] ?? ""
        },
      ];
}
