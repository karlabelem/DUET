// Tests expected algorithm results to actual algorithm results.
// Run with `flutter test` command.

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duet_application/src/algo/matching.dart'; // Ensure `findBestMatches` is imported, and user profile

void main() {
  test('Find best matches using Firestore mock', () async {
    final instance = FakeFirebaseFirestore();

    // Create users in Firestore
    await instance.collection('users').doc('1').set({
      'favoriteArtists': ["Taylor Swift", "Drake"],
      'favoriteGenres': ["Pop", "Hip-Hop"],
      'audioFeatures': [0.8, 0.6, 0.7],
    });

    await instance.collection('users').doc('2').set({
      'favoriteArtists': ["Drake", "Kanye West"],
      'favoriteGenres': ["Hip-Hop", "Rap"],
      'audioFeatures': [0.7, 0.6, 0.8],
    });

    await instance.collection('users').doc('3').set({
      'favoriteArtists': ["Billie Eilish", "Lorde"],
      'favoriteGenres': ["Indie Pop", "Alternative"],
      'audioFeatures': [0.5, 0.4, 0.6],
    });

    // Fetch the user to match against
    final userA = User.fromFirestore(
        await instance.collection('users').doc('1').get());

    // Fetch all other users
    final querySnapshot = await instance.collection('users').get();
    final allUsers = querySnapshot.docs
        .where((doc) => doc.id != userA.id) // Exclude the main user
        .map((doc) => User.fromFirestore(doc))
        .toList();

    // Run match function
    final matches = findBestMatches(userA, allUsers);

    // Print and assert results
    for (var match in matches) {
      print(
          "Matched with ${match['user'].id} - Score: ${match['score'].toStringAsFixed(2)}");
    }

    expect(matches.isNotEmpty, true); // Ensure we have at least one match
  });
}
