// Tests expected algorithm results to actual algorithm results.
// Run with `flutter test` command.

import 'package:duet_application/src/backend/firestore_instance.dart';
import 'package:duet_application/src/backend/userProfile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duet_application/src/algo/matching.dart'; // Ensure `findBestMatches` is imported, and user profile

void main() {
  test('Find best matches using Firestore mock', () async {
    final instance = FakeFirebaseFirestore(
      securityRules: '''
    service cloud.firestore {
      match /databases/{database}/documents {
        
        // Rules for the users collection
        match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
        }

        // Rules for the conversations collection
        match /conversations/{conversationId} {
      allow read: if request.auth != null && isParticipant(request.auth.uid, conversationId);
      allow write: if request.auth != null && isParticipant(request.auth.uid, conversationId);
        }

        // Rules for the messages subcollection within conversations
        match /conversations/{conversationId}/messages/{messageId} {
      allow read: if request.auth != null && isParticipant(request.auth.uid, conversationId);
      allow write: if request.auth != null && isParticipant(request.auth.uid, conversationId);
        }

        // Function to check if a user is a participant in a conversation
        function isParticipant(userId, conversationId) {
      return get(/databases/\$(database)/documents/conversations/\$(conversationId)).data.participants[userId] == true;
        }

        // Rules for other collections can be added here
      }
    }
      ''',
    );
    makeFirestoreInstance(instance: instance);

    // Create users in Firestore
    UserProfileData user1 = UserProfileData(
      uuid: '1',
      name: 'User 1',
      email: 'email@yes.com',
      dob: '01/01/2001',
      location: 'USA',
      password: 'password',
    );
    user1.saveToFirestore();

    final UserProfileData? login = await getUserProfileByEmailAndPassword('email@yes.com', 'password');

    expect(user1, login);

  });
}
