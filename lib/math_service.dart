// lib/math_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class MathService {
  // URL of your Python math engine (for development, use localhost)
  static const String apiUrl = "http://localhost:5000/calculate";

  static Future<String?> calculateProbability(String event) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"event": event}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse["probability"].toString();
    } else {
      return null;
    }
  }
}
