import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../backend/userProfile.dart';

List<UserProfileData> filterCity(List<UserProfileData> users, UserProfileData currentUser) {
  return users.where((user) => user.location == currentUser.location).toList();
}

List<UserProfileData> reranking(List<UserProfileData> users, UserProfileData currentUser) {
  // Order the user in decreasing order of weighted overlap in spotify albums between a user and current user.
  // The numerator (shared items) is more important, because people who listen to 100 of same songs should be strongly matched, even if 10,000 dissimilar
  // Let's start with raw intersection size, then normalize by the size of the current user's set
  users.sort((a, b) {
    // Handle null values safely
    final Set<dynamic> aTracks = (a.spotifyData?.favoriteTracks ?? {}).toSet();
    final Set<dynamic> bTracks = (b.spotifyData?.favoriteTracks ?? {}).toSet();
    final Set<dynamic> currentUserTracks = (currentUser.spotifyData?.favoriteTracks ?? {}).toSet();

    // Avoid division by zero: If currentUserTracks is empty, return users as-is
    int currentUserTrackCount = currentUserTracks.length;
    if (currentUserTrackCount == 0) return 0;

    double overlapA = aTracks.intersection(currentUserTracks).length / currentUserTrackCount;
    double overlapB = bTracks.intersection(currentUserTracks).length / currentUserTrackCount;

    return overlapB.compareTo(overlapA);
  });

  // TODO: considerations around a song everyone listens to artificially boosting similarity;
  // user can select what to search for (only Perfect Circle).
  return users;
  }

// Top level function to handle matching (filtering, sorting)
List<UserProfileData> matchUsers(List<UserProfileData> users, UserProfileData currentUser) {
  // List<UserProfileData> filteredUsers = filterCity(users, currentUser);
  return reranking(users, currentUser);
}
