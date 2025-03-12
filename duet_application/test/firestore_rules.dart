// Tests expected algorithm results to actual algorithm results.
// Run with `flutter test` command.

import 'dart:math';

import 'package:duet_application/src/backend/firestore_instance.dart';
import 'package:duet_application/src/backend/userProfile.dart';
import 'package:duet_application/src/backend/messaging_backend.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:duet_application/src/backend/authentication_instance.dart';

void main() {
  group("Check connections to users collection with authentication", () {
    // set up the mock cloud firestore
    final auth = MockFirebaseAuth();
    final firestore = FakeFirebaseFirestore(securityRules: '''
    service cloud.firestore {
      match /databases/{database}/documents {
        match /users/{userId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }

        match/{document=**} {
          allow read, write: if request.auth != null;
        }
      }
    }
      ''', authObject: auth.authForFakeFirestore);
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

      final UserProfileData? savedUser =
          await UserProfileData.getUserProfile(user1.authId);

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
      final UserProfileData? login =
          await UserProfileData.getUserProfileByEmailAndPassword(
              email, password);

      expect(login, isNotNull);
      expect(login!.email, email);
    });

    test('Saving new conversation to database', () async {
      // Create users in Firestore
      UserProfileData user1 = UserProfileData(
        name: 'User 1',
        email: 'user1@example.com',
        dob: '01/01/2000',
        location: 'Location 1',
        password: 'password1',
      );
      await user1.saveToFirestore(); // Save user1 to Firestore

      UserProfileData user2 = UserProfileData(
        name: 'User 2',
        email: 'user2@example.com',
        dob: '02/02/2000',
        location: 'Location 2',
        password: 'password2',
      );
      await user2.saveToFirestore(); // Save user2 to Firestore

      // Create a new conversation
      Messagingbackend conversation = Messagingbackend(
        uuid1: user1.authId,
        uuid2: user2.authId,
      );
      int result = await conversation.saveToFirestore();

      expect(result, 0);

      final Messagingbackend? savedConversation =
          await getConversation(user1.authId, user2.authId);
      expect(savedConversation, isNotNull);
      expect(savedConversation!.uuid1, user1.authId);
      expect(savedConversation.uuid2, user2.authId);
    });

    test('Sending a message', () async {
      final UserProfileData? user1 =
          await UserProfileData.getUserProfileByEmailAndPassword(
              'user1@example.com', 'password1');
      final UserProfileData? user2 =
          await UserProfileData.getUserProfileByEmailAndPassword(
              'user2@example.com', 'password2');
      final Messagingbackend? savedConversation =
          await getConversation(user1!.authId, user2!.authId);

      // Send a message
      Message message = Message(
        user1.authId,
        user2.authId,
        'Hello, User 2!',
      );
      int result = await savedConversation!.sendMessage(message);

      expect(result, 0);

      final Messagingbackend? updatedConversation =
          await getConversation(user1.authId, user2.authId);

      expect(updatedConversation, isNotNull);
      expect(updatedConversation!.conversation.length, 1);
      expect(updatedConversation.conversation[0].text, 'Hello, User 2!');
    });
  });
}
