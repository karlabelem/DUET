import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:duet_application/src/frontEnd/profile_creation/profile_creation_s4.dart';

void main() {
  testWidgets('ProfileCreationStep4 renders correctly', (WidgetTester tester) async {
    bool nextStepCalled = false;

    // Build the widget
    await tester.pumpWidget(MaterialApp(
      home: ProfileCreationStep4(
        nextStep: (data) {
          nextStepCalled = true;
        },
      ),
    ));

    // Verify the basic structure and content
    expect(find.text('Choose your favorite music genres'), findsOneWidget);
    expect(find.text('Step 4 of 4'), findsOneWidget);
    expect(find.text('Select Music Genres'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Verify the container styling
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, equals(Colors.white));
    expect(decoration.borderRadius, equals(BorderRadius.circular(16.0)));

    // Test the next button functionality
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(nextStepCalled, isTrue);
  });

  testWidgets('ProfileCreationStep4 has correct background color', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ProfileCreationStep4(
        nextStep: (data) {},
      ),
    ));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, equals(const Color(0xFFE0CFF2)));
  });

  testWidgets('ProfileCreationStep4 button has correct styling', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ProfileCreationStep4(
        nextStep: (data) {},
      ),
    ));

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton).first);
    final buttonStyle = button.style as ButtonStyle;

    // Verify button background color
    final backgroundColor = buttonStyle.backgroundColor?.resolve({});
    expect(backgroundColor, equals(Colors.grey));

    // Verify button shape
    final shape = buttonStyle.shape?.resolve({}) as RoundedRectangleBorder;
    expect(shape.borderRadius, equals(BorderRadius.circular(24.0)));
  });

  testWidgets('ProfileCreationStep4 navigates to SelectMusicGenres and updates selected genres', (WidgetTester tester) async {
    bool nextStepCalled = false;
    Set<dynamic> selectedGenres = {};

    // Build the widget
    await tester.pumpWidget(MaterialApp(
      home: ProfileCreationStep4(
        nextStep: (data) {
          nextStepCalled = true;
          selectedGenres = data['genres'];
        },
      ),
    ));

    // Tap the "Select Music Genres" button
    await tester.tap(find.text('Select Music Genres'));
    await tester.pumpAndSettle();

    // Verify that the SelectMusicGenres screen is displayed
    expect(find.text('Select Music Genres'), findsOneWidget);

    // Select some genres
    await tester.tap(find.text('rock'));
    await tester.tap(find.text('pop'));
    await tester.tap(find.text('jazz'));
    await tester.pump();

    // Navigate back to ProfileCreationStep4
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verify that the selected genres are displayed as chips
    expect(find.text('rock'), findsOneWidget);
    expect(find.text('pop'), findsOneWidget);
    expect(find.text('jazz'), findsOneWidget);

    // Tap the "Next" button
    await tester.tap(find.text('Next'));
    await tester.pump();

    // Verify that nextStep was called with the correct data
    expect(nextStepCalled, isTrue);
    expect(selectedGenres, equals(['rock', 'pop', 'jazz']));
  });
}
