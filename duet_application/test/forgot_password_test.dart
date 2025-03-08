import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:duet_application/src/frontEnd/forgot_password/forgot_password.dart';

void main() {
  testWidgets('forgot password clicking on buttons', (WidgetTester tester) async {
    // Wrap in MaterialApp for correct context
    await tester.pumpWidget(MaterialApp(home: ForgotPassword()));
    await tester.pumpAndSettle(); // Ensures UI is built properly

    // Debug: Print all text widgets
    final allTextWidgets = tester.widgetList(find.byType(Text)).map((w) => (w as Text).data).toList();
    print('Visible text widgets: $allTextWidgets');

    // Ensure the title is found
    expect(find.textContaining('Forgot password?'), findsOneWidget);

    // Find and tap the "Send code" button (ElevatedButton)
    final sendCodeFinder = find.ancestor(of: find.text('Send code'), matching: find.byType(ElevatedButton));
    expect(sendCodeFinder, findsOneWidget, reason: 'Send code button should be visible');
    await tester.tap(sendCodeFinder);
    await tester.pumpAndSettle();

    // User inserts code
    expect(find.textContaining('Please check your email'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '123456');

    // Find and tap the "Verify" button
    final verifyButtonFinder = find.ancestor(of: find.text('Verify'), matching: find.byType(ElevatedButton));
    expect(verifyButtonFinder, findsOneWidget, reason: 'Verify button should be visible');
    await tester.tap(verifyButtonFinder);
    await tester.pumpAndSettle();

    // User enters new password
    expect(find.textContaining('Reset password'), findsWidgets);

    var fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'newpassword');
    await tester.enterText(fields.at(1), 'newpassword');

    // Find and tap the "Reset password" button
    final resetPasswordButtonFinder = find.ancestor(of: find.text('Reset password'), matching: find.byType(ElevatedButton));
    expect(resetPasswordButtonFinder, findsOneWidget, reason: 'Reset password button should be visible');
    await tester.tap(resetPasswordButtonFinder);
    await tester.pumpAndSettle();

    // Ensure password is changed
    expect(find.textContaining('Password changed'), findsOneWidget);

    // Find and tap the "Back to log in" button
    final backToLoginButtonFinder = find.ancestor(of: find.text('Back to log in'), matching: find.byType(ElevatedButton));
    expect(backToLoginButtonFinder, findsOneWidget, reason: 'Back to log in button should be visible');
    await tester.tap(backToLoginButtonFinder);
    await tester.pumpAndSettle();
  });
}



