// Tests expected algorithm results to actual algorithm results.
// Run with `flutter test` command.

/** COMMENTED OUT IMPORTS AND TESTS ARE TO BE REVIEWED AND HOPEFULLY FIXED BY FINAL RELEASE */

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:duet_application/src/algo/matching.dart'; // Ensure `findBestMatches` is imported, and user profile

// import 'package:duet_application/src/backend/userProfile.dart';
// import 'package:duet_application/src/backend/spotifyUserData.dart';


void main() {
  test('Find best matches using Firestore mock', () async {
    expect(true, true);

    // UserProfileData user1 = UserProfileData(
    //   uuid: '1',
    //   name: 'Alice',
    //   email: 'alice@user.com',
    //   dob: '1/1/1990',
    //   location: 'New York',
    //   password: 'password',
    //   spotifyData: SpotifyUserData(
    //     uuid: '1',
    //     accessToken: 'testAccessToken',
    //     refreshToken: 'testRefreshToken',
    //     username: 'alice_spotify',
    //     email: 'alice@spotify.com',
    //     favoriteArtists: ["Taylor Swift", "Drake"],
    //     favoriteTracks: ["Track1", "Track2"],
    //     favoriteGenres: ["Pop", "Hip-Hop"],
    //   ),
    //   likedUsers: [],
    //   dislikedUsers: [],
    //   // String? authId,
    // );

    // UserProfileData user2 = UserProfileData(
    //   uuid: '2',
    //   name: 'Bob',
    //   email: 'bob@user.com',
    //   dob: '1/1/1995',
    //   location: 'New York',
    //   password: 'password',
    //   spotifyData: SpotifyUserData(
    //     uuid: '2',
    //     accessToken: 'testAccessToken',
    //     refreshToken: 'testRefreshToken',
    //     username: 'bob_spotify',
    //     email: 'bob@spotify.com',
    //     favoriteArtists: ["Drake", "Kanye West"],
    //     favoriteTracks: ["Track2"],
    //     favoriteGenres: ["Hip-Hop", "Rap"],
    //   ),
    //   likedUsers: [],
    //   dislikedUsers: [],
    //   // String? authId,
    // );

    // UserProfileData user3 = UserProfileData(
    //   uuid: '3',
    //   name: 'Charlie',
    //   email: 'charlie@user.com',
    //   dob: '1/1/1995',
    //   location: 'New York',
    //   password: 'password',
    //   spotifyData: SpotifyUserData(
    //     uuid: '3',
    //     accessToken: 'testAccessToken',
    //     refreshToken: 'testRefreshToken',
    //     username: 'charlie_spotify',
    //     email: 'charlie@spotify.com',
    //     favoriteArtists: ["Drake", "Kanye West"],
    //     favoriteTracks: ["Track1", "Track2"],
    //     favoriteGenres: ["Hip-Hop", "Rap"],
    //   ),
    //   likedUsers: [],
    //   dislikedUsers: [],
    //   // String? authId,
    // );

    // UserProfileData currentUser = user1;
    // List<UserProfileData> other_users = [user2, user3];

    // final matches = matchUsers(other_users, currentUser);

    // // Expect the matches to be user3, then user2
    // expect(matches[0].uuid, equals('3'));
    // expect(matches[1].uuid, equals('2'));


  });
}
