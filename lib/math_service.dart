// lib/math_service.dart
class MathService {
  /// Evaluates a simple fraction like "3/7" or "0.5".
  /// If we can't parse, return null.
  static double? parseExpression(String query) {
    // For example, if user typed "Probability = 1/3" => we try to parse "1/3"
    // but let's keep it simple. We'll just look for something like "a/b" or numeric.
    // In reality, you'd do more advanced parsing or an AI approach.
    final fractionRegex = RegExp(r'(\d+(\.\d+)?)\s*/\s*(\d+(\.\d+)?)');
    final match = fractionRegex.firstMatch(query);
    if (match != null) {
      // Evaluate fraction
      final numerator = double.tryParse(match.group(1)!);
      final denominator = double.tryParse(match.group(3)!);
      if (numerator != null && denominator != null && denominator != 0) {
        return numerator / denominator;
      }
    }
    // Try a direct numeric parse
    final val = double.tryParse(query);
    if (val != null) return val;

    return null; // Not parseable
  }
}
