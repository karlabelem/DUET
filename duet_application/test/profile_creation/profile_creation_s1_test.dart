import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:duet_application/src/frontEnd/profile_creation/profile_creation_s1.dart';

void main() {
  testWidgets('ProfileCreationStep1 widget test', (WidgetTester tester) async {
    // Create a mock nextStep function
    bool nextStepCalled = false;
    Map<String, String>? passedData;

    void mockNextStep(Map<String, String> data) {
      nextStepCalled = true;
      passedData = data;
    }

    // Build the widget
    await tester.pumpWidget(MaterialApp(
      home: ProfileCreationStep1(nextStep: mockNextStep),
    ));

    // Verify initial state
    expect(find.text("What's Your Name?"), findsOneWidget);
    expect(find.text('Step 1 of 4'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Test empty fields
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(nextStepCalled, false);

    // Enter valid input
    await tester.enterText(
        find.widgetWithText(TextField, 'First Name'), 'John');
    await tester.enterText(find.widgetWithText(TextField, 'Last Name'), 'Doe');
    await tester.pump();

    // Verify button is enabled and tap it
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify nextStep was called with correct data
    expect(nextStepCalled, true);
    expect(passedData, {
      'firstName': 'John',
      'lastName': 'Doe',
    });
  });

  testWidgets('ProfileCreationStep1 validates input fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ProfileCreationStep1(nextStep: (_) {}),
    ));

    // Test with only first name
    await tester.enterText(
        find.widgetWithText(TextField, 'First Name'), 'John');
    await tester.pump();

    // Get the button widget
    final ElevatedButton firstNameOnlyButton =
        tester.widget(find.byType(ElevatedButton));
    expect(firstNameOnlyButton.enabled, false);

    // Test with only last name
    await tester.enterText(find.widgetWithText(TextField, 'First Name'), '');
    await tester.enterText(find.widgetWithText(TextField, 'Last Name'), 'Doe');
    await tester.pump();

    // Get the button widget
    final ElevatedButton lastNameOnlyButton =
        tester.widget(find.byType(ElevatedButton));
    expect(lastNameOnlyButton.enabled, false);

    // Test with both names
    await tester.enterText(
        find.widgetWithText(TextField, 'First Name'), 'John');
    await tester.pump();

    // Get the button widget
    final ElevatedButton bothNamesButton =
        tester.widget(find.byType(ElevatedButton));
    expect(bothNamesButton.enabled, true);
  });
}
