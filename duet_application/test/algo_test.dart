// Tests expected algorithm results to actual algorithm results.
// Run with `flutter test` command.

/** COMMENTED OUT IMPORTS AND TESTS ARE TO BE REVIEWED AND HOPEFULLY FIXED BY FINAL RELEASE */

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duet_application/src/algo/matching.dart'; // Ensure `findBestMatches` is imported, and user profile

import 'package:duet_application/src/backend/userProfile.dart';
import 'package:duet_application/src/backend/spotifyUserData.dart';


void main() {
  test('Find best matches using Firestore mock', () async {
    // expect(true, true);

    UserProfileData user1 = UserProfileData(
      uuid: '1',
      name: 'Alice',
      email: 'alice@user.com',
      dob: '1/1/1990',
      location: 'New York',
      password: 'password',
      spotifyData: SpotifyUserData(
        uuid: '1',
        accessToken: 'testAccessToken',
        refreshToken: 'testRefreshToken',
        username: 'alice_spotify',
        email: 'alice@spotify.com',
        favoriteArtists: ["Taylor Swift", "Drake"],
        favoriteTracks: ["Track1", "Track2"],
        favoriteGenres: ["Pop", "Hip-Hop"],
      ),
      likedUsers: [],
      dislikedUsers: [],
      // String? authId,
    );

    UserProfileData user2 = UserProfileData(
      uuid: '2',
      name: 'Bob',
      email: 'bob@user.com',
      dob: '1/1/1995',
      location: 'New York',
      password: 'password',
      spotifyData: SpotifyUserData(
        uuid: '2',
        accessToken: 'testAccessToken',
        refreshToken: 'testRefreshToken',
        username: 'bob_spotify',
        email: 'bob@spotify.com',
        favoriteArtists: ["Drake", "Kanye West"],
        favoriteTracks: ["Track2"],
        favoriteGenres: ["Hip-Hop", "Rap"],
      ),
      likedUsers: [],
      dislikedUsers: [],
      // String? authId,
    );

    UserProfileData user3 = UserProfileData(
      uuid: '3',
      name: 'Charlie',
      email: 'charlie@user.com',
      dob: '1/1/1995',
      location: 'New York',
      password: 'password',
      spotifyData: SpotifyUserData(
        uuid: '3',
        accessToken: 'testAccessToken',
        refreshToken: 'testRefreshToken',
        username: 'charlie_spotify',
        email: 'charlie@spotify.com',
        favoriteArtists: ["Drake", "Kanye West"],
        favoriteTracks: ["Track1", "Track2"],
        favoriteGenres: ["Hip-Hop", "Rap"],
      ),
      likedUsers: [],
      dislikedUsers: [],
      // String? authId,
    );

    UserProfileData currentUser = user1;
    List<UserProfileData> other_users = [user2, user3];

    final matches = matchUsers(other_users, currentUser);

    // Expect the matches to be user3, then user2
    expect(matches[0].uuid, equals('3'));
    expect(matches[1].uuid, equals('2'));


    // final instance = FakeFirebaseFirestore();

    // // Create users in Firestore
    // await instance.collection('users').doc('1').set({
    //   'favoriteArtists': ["Taylor Swift", "Drake"],
    //   'favoriteGenres': ["Pop", "Hip-Hop"],
    //   'audioFeatures': [0.8, 0.6, 0.7],
    // });

    // await instance.collection('users').doc('2').set({
    //   'favoriteArtists': ["Drake", "Kanye West"],
    //   'favoriteGenres': ["Hip-Hop", "Rap"],
    //   'audioFeatures': [0.7, 0.6, 0.8],
    // });

    // await instance.collection('users').doc('3').set({
    //   'favoriteArtists': ["Billie Eilish", "Lorde"],
    //   'favoriteGenres': ["Indie Pop", "Alternative"],
    //   'audioFeatures': [0.5, 0.4, 0.6],
    // });

    // // Fetch the user to match against
    // final userA = User.fromFirestore(
    //     await instance.collection('users').doc('1').get());

    // // Fetch all other users
    // final querySnapshot = await instance.collection('users').get();
    // final allUsers = querySnapshot.docs
    //     .where((doc) => doc.id != userA.id) // Exclude the main user
    //     .map((doc) => User.fromFirestore(doc))
    //     .toList();

    // // Run match function
    // final matches = findBestMatches(userA, allUsers);

    // // Print and assert results
    // for (var match in matches) {
    //   print(
    //       "Matched with ${match['user'].id} - Score: ${match['score'].toStringAsFixed(2)}");
    // }

    // expect(matches.isNotEmpty, true); // Ensure we have at least one match
  });
}
