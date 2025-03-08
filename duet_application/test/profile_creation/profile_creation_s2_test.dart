import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:duet_application/src/frontEnd/profile_creation/profile_creation_s2.dart';

void main() {
  testWidgets('ProfileCreationStep2 renders correctly',
      (WidgetTester tester) async {
    bool nextStepCalled = false;
    nextStep(Map<String, String> data) {
      nextStepCalled = true;
    }

    await tester.pumpWidget(MaterialApp(
      home: ProfileCreationStep2(nextStep: nextStep),
    ));

    // Verify initial UI elements
    expect(find.text("What's Your Date of Birth?"), findsOneWidget);
    expect(find.text("Step 2 of 4"), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Verify nextStep hasn't been called yet
    expect(nextStepCalled, false);
  });

  testWidgets('Date validation works correctly', (WidgetTester tester) async {
    bool nextStepCalled = false;
    nextStep(Map<String, String> data) {
      nextStepCalled = true;
    }

    await tester.pumpWidget(MaterialApp(
      home: ProfileCreationStep2(nextStep: nextStep),
    ));

    // Find all text fields
    final yearField = find.widgetWithText(TextField, 'Year');
    final monthField = find.widgetWithText(TextField, 'Month');
    final dayField = find.widgetWithText(TextField, 'Day');

    // Test invalid year
    await tester.enterText(yearField, '2026');
    await tester.pump();

    // Check the error text
    final yearTextFieldWidget = tester.widget<TextField>(yearField);
    expect(yearTextFieldWidget.decoration?.errorText, equals('Invalid year'));

    // Test invalid month
    await tester.enterText(monthField, '13');
    await tester.pump();

    final monthTextFieldWidget = tester.widget<TextField>(monthField);
    expect(monthTextFieldWidget.decoration?.errorText, equals('Invalid month'));

    // Test invalid day
    await tester.enterText(dayField, '32');
    await tester.pump();

    final dayTextFieldWidget = tester.widget<TextField>(dayField);
    expect(dayTextFieldWidget.decoration?.errorText, equals('Invalid day'));

    // Test valid date
    await tester.enterText(monthField, '12');
    await tester.enterText(dayField, '31');
    await tester.enterText(yearField, '2000');
    await tester.pump();

    // Verify no error messages
    expect(tester.widget<TextField>(yearField).decoration?.errorText, isNull);
    expect(tester.widget<TextField>(monthField).decoration?.errorText, isNull);
    expect(tester.widget<TextField>(dayField).decoration?.errorText, isNull);

    // Verify next button is enabled and clickable
    final button = find.byType(ElevatedButton);
    expect(tester.widget<ElevatedButton>(button).enabled, true);

    // Test button click
    await tester.tap(button);
    await tester.pump();
    expect(nextStepCalled, true);
  });

  testWidgets('Next button is disabled with empty fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ProfileCreationStep2(nextStep: (_) {}),
    ));

    final button = find.byType(ElevatedButton);
    expect(tester.widget<ElevatedButton>(button).enabled, false);
  });

  testWidgets('Text fields have correct input formatters',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ProfileCreationStep2(nextStep: (_) {}),
    ));

    // Test month field length limit
    await tester.enterText(find.widgetWithText(TextField, 'Month'), '123');
    await tester.pump();
    final monthField = find.widgetWithText(TextField, 'Month');
    expect(tester.widget<TextField>(monthField).controller?.text, '12');

    // Test day field length limit
    await tester.enterText(find.widgetWithText(TextField, 'Day'), '123');
    await tester.pump();
    final dayField = find.widgetWithText(TextField, 'Day');
    expect(tester.widget<TextField>(dayField).controller?.text, '12');

    // Test year field length limit
    await tester.enterText(find.widgetWithText(TextField, 'Year'), '12345');
    await tester.pump();
    final yearField = find.widgetWithText(TextField, 'Year');
    expect(tester.widget<TextField>(yearField).controller?.text, '1234');

    // Test non-numeric input
    await tester.enterText(find.widgetWithText(TextField, 'Month'), 'abc');
    await tester.pump();
    expect(find.text('abc'), findsNothing);
  });
}
