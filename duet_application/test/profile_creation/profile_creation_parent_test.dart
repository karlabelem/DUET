import 'package:duet_application/src/frontEnd/profile_creation/profile_creation_parent.dart';
import 'package:duet_application/src/frontEnd/profile_creation/profile_creation_s0.dart';
import 'package:duet_application/src/frontEnd/profile_creation/profile_creation_s1.dart';
import 'package:duet_application/src/frontEnd/profile_creation/profile_creation_s2.dart';
import 'package:duet_application/src/frontEnd/profile_creation/profile_creation_s3.dart';
import 'package:duet_application/src/frontEnd/profile_creation/profile_creation_s4.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileCreationParent Widget Tests', () {
    testWidgets('Initial state shows AccountRegistration', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: ProfileCreationParent(nextStep: () {})));
      expect(find.byType(AccountRegistration), findsOneWidget);
    });

    testWidgets('Navigation through steps works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: ProfileCreationParent(nextStep: () {})));

      // Initial state - AccountRegistration
      expect(find.byType(AccountRegistration), findsOneWidget);

      // Move to Step 1
      final state = tester.state<ProfileCreationParentState>(find.byType(ProfileCreationParent));
      state.nextStep({'email': 'test@test.com', 'password': 'password123'});
      await tester.pump();
      expect(find.byType(ProfileCreationStep1), findsOneWidget);

      // Move to Step 2
      state.nextStep({'firstName': 'John', 'lastName': 'Doe'});
      await tester.pump();
      expect(find.byType(ProfileCreationStep2), findsOneWidget);

      // Move to Step 3
      state.nextStep({'dob': '1990-01-01'});
      await tester.pump();
      expect(find.byType(ProfileCreationStep3), findsOneWidget);

      // Move to Step 4
      state.nextStep({'location': 'New York'});
      await tester.pump();
      expect(find.byType(ProfileCreationStep4), findsOneWidget);
    });

    testWidgets('UserRegistrationData is updated correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: ProfileCreationParent(nextStep: () {})));

      final state = tester.state<ProfileCreationParentState>(find.byType(ProfileCreationParent));

      // Test email and password update
      state.nextStep({'email': 'test@test.com', 'password': 'password123'});
      expect(state.userRegistrationData.email, equals('test@test.com'));
      expect(state.userRegistrationData.password, equals('password123'));

      // Test name update
      state.nextStep({'firstName': 'John', 'lastName': 'Doe'});
      expect(state.userRegistrationData.firstName, equals('John'));
      expect(state.userRegistrationData.lastName, equals('Doe'));

      // Test DOB update
      state.nextStep({'dob': '1990-01-01'});
      expect(state.userRegistrationData.dob, equals('1990-01-01'));

      // Test location update
      state.nextStep({'location': 'New York'});
      expect(state.userRegistrationData.location, equals('New York'));
    });
  });
}
