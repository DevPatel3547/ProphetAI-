class APIConfig {
  static final List<Map<String, String>> providers = [
    {
      "name": "together",
      "apiUrl": "https://api.together.xyz/v1/chat/completions",
      "model": "meta-llama/Llama-3.3-70B-Instruct-Turbo-Free",
      "apiKey": const String.fromEnvironment('TOGETHER_API_KEY'),
    },
    {
      "name": "openrouter",
      "apiUrl": "https://openrouter.ai/api/v1/chat/completions",
      "model": "meta-llama/llama-3.3-70b-instruct:free",
      "apiKey": const String.fromEnvironment('OPENROUTER_API_KEY'),
    },
    {
      "name": "groq",
      "apiUrl": "https://api.groq.com/openai/v1/chat/completions",
      "model": "llama3-8b-8192",
      "apiKey": const String.fromEnvironment('GROQ_API_KEY'),
    },
    {
      "name": "cohere",
      "apiUrl": "https://api.cohere.ai/v1/chat",
      "model": "command-r",
      "apiKey": const String.fromEnvironment('COHERE_API_KEY'),
    },
    {
      "name": "mistral",
      "apiUrl": "https://api.mistral.ai/v1/chat/completions",
      "model": "mistral-large-latest",
      "apiKey": const String.fromEnvironment('MISTRAL_API_KEY'),
    },
  ];
}
