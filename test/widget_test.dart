// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:probability_app/main.dart';

void main() {
  testWidgets('ProbabilityApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ProphetAIApp());

    // Verify that our UI contains a TextField and an ElevatedButton.
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Optionally, you could simulate a tap on the button.
    // For example, if you have a counter or some text change:
    // await tester.tap(find.byType(ElevatedButton));
    // await tester.pump();

    // You can add further expectations if desired.
  });
}
