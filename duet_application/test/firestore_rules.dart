// Tests expected algorithm results to actual algorithm results.
// Run with `flutter test` command.

import 'dart:math';

import 'package:duet_application/src/backend/firestore_instance.dart';
import 'package:duet_application/src/backend/userProfile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:duet_application/src/backend/authentication_instance.dart';

void main() {
  group("Check connections to users collection with authentication", () {
    // set up the mock cloud firestore
    final auth = MockFirebaseAuth();
    final firestore = FakeFirebaseFirestore(
      securityRules: '''
    service cloud.firestore {
      match /databases/{database}/documents {
        match /users/{userId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }

        match/{document=**} {
      allow read, write: if request.auth != null
    }
      }
    }
      ''',
      authObject: auth.authForFakeFirestore
    );
    makeFirestoreInstance(instance: firestore);
    makeAuthenticationInstance(instance: auth);

    

    test('Saving new profile to database', () async {
    // Create users in Firestore
    UserProfileData user1 = UserProfileData(
      name: 'User 1',
      email: 'email@yes.com',
      dob: '01/01/2001',
      location: 'USA',
      password: 'password',
    );
    await user1.saveToFirestore(); // Save user1 to Firestore

    final UserProfileData? savedUser = await UserProfileData.getUserProfile(user1.authId);

    expect(savedUser, isNotNull);
    expect(savedUser!.uuid, user1.uuid);
    expect(savedUser.name, user1.name);
    expect(savedUser.email, user1.email);
    expect(savedUser.dob, user1.dob);
    expect(savedUser.location, user1.location);

    await auth.signOut();
    });

    test('Logging in with existing profile', () async {
      const String email = 'email@yes.com';
      const String password = 'password';
      final UserProfileData? login = await UserProfileData.getUserProfileByEmailAndPassword(email, password);

      expect(login, isNotNull);
      expect(login!.email, email);
      expect(login.password, password);
    });


    


  });
  }

