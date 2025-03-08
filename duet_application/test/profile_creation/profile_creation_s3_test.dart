import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:duet_application/src/frontEnd/profile_creation/profile_creation_s3.dart';

void main() {
  testWidgets('ProfileCreationStep3 renders correctly', (WidgetTester tester) async {
    // Create a mock nextStep function
    bool nextStepCalled = false;
    Map<String, String>? passedData;

    void mockNextStep(Map<String, String> data) {
      nextStepCalled = true;
      passedData = data;
    }

    // Build the widget
    await tester.pumpWidget(MaterialApp(
      home: ProfileCreationStep3(nextStep: mockNextStep),
    ));

    // Verify initial UI elements
    expect(find.text("Where do you live?"), findsOneWidget);
    expect(find.text("Step 3 of 4"), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Verify nextStep hasn't been called yet
    expect(nextStepCalled, false);
    expect(passedData, null);

    // Verify button is initially disabled (grey)
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final buttonStyle = button.style as ButtonStyle;
    expect(
      buttonStyle.backgroundColor?.resolve({}),
      Colors.grey,
    );
  });

  testWidgets('Button enables when city is entered', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ProfileCreationStep3(nextStep: (_) {}),
    ));

    // Enter city name
    await tester.enterText(find.byType(TextField), 'New York');
    await tester.pump();

    // Verify button is now enabled (purple)
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final buttonStyle = button.style as ButtonStyle;
    expect(
      buttonStyle.backgroundColor?.resolve({}),
      Colors.purple,
    );
  });

  testWidgets('Next step is called with correct data', (WidgetTester tester) async {
    Map<String, String>? passedData;
    void mockNextStep(Map<String, String> data) {
      passedData = data;
    }

    await tester.pumpWidget(MaterialApp(
      home: ProfileCreationStep3(nextStep: mockNextStep),
    ));

    // Enter city and submit
    await tester.enterText(find.byType(TextField), 'New York');
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify correct data was passed
    expect(passedData, {
      'location': 'New York',
    });
  });

  testWidgets('Shows error message when submitting empty city', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ProfileCreationStep3(nextStep: (_) {}),
    ));

    // Try to submit without entering city
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('Please enter a valid city'), findsOneWidget);
  });

  testWidgets('TextField updates trigger state changes', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ProfileCreationStep3(nextStep: (_) {}),
    ));

    // Initial state - button should be grey
    ElevatedButton initialButton = tester.widget(find.byType(ElevatedButton));
    expect(
      (initialButton.style as ButtonStyle).backgroundColor?.resolve({}),
      Colors.grey,
    );

    // Enter text
    await tester.enterText(find.byType(TextField), 'L');
    await tester.pump();

    // Button should now be purple
    ElevatedButton updatedButton = tester.widget(find.byType(ElevatedButton));
    expect(
      (updatedButton.style as ButtonStyle).backgroundColor?.resolve({}),
      Colors.purple,
    );

    // Clear text
    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    // Button should be grey again
    ElevatedButton finalButton = tester.widget(find.byType(ElevatedButton));
    expect(
      (finalButton.style as ButtonStyle).backgroundColor?.resolve({}),
      Colors.grey,
    );
  });
}
