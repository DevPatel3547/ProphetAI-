// lib/math_service.dart
class MathService {
  /// Evaluates a simple arithmetic expression of the form "a/b" or a plain number.
  static Future<String?> calculateExpression(String expression) async {
    if (expression.contains("/")) {
      List<String> parts = expression.split("/");
      if (parts.length == 2) {
        double? numerator = double.tryParse(parts[0].trim());
        double? denominator = double.tryParse(parts[1].trim());
        if (numerator != null && denominator != null && denominator != 0) {
          double value = numerator / denominator;
          return value.toString();
        }
      }
    } else {
      double? value = double.tryParse(expression.trim());
      if (value != null) {
        return value.toString();
      }
    }
    return null;
  }
}
