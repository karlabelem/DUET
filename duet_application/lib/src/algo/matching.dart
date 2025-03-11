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


// A matching algorithm that, given a list of UserProfileData, (1) removes users in a different city (2) ranks them by min age distance 
List<UserProfileData> dummyMatching(List<UserProfileData> users, UserProfileData currentUser) {
  // Remove users in a different city
  users.removeWhere((user) => user.location != currentUser.location);

  // Rank users by min age distance from current user

  // Assume M/D/YYYY format
  users.sort((a, b) {
    int ageA = DateTime.now().year - int.parse(a.dob.split('/')[2]);
    int ageB = DateTime.now().year - int.parse(b.dob.split('/')[2]);
    int ageDiffA = (ageA - int.parse(currentUser.dob.split('/')[2])).abs();
    int ageDiffB = (ageB - int.parse(currentUser.dob.split('/')[2])).abs();
    return ageDiffB.compareTo(ageDiffA);
  });
  
  
  // // YYYY-MM-DD format
  // users.sort((a, b) {
  //   int ageA = DateTime.now().year - int.parse(a.dob.split('-')[0]);
  //   int ageB = DateTime.now().year - int.parse(b.dob.split('-')[0]);
  //   int ageDiffA = (ageA - int.parse(currentUser.dob.split('-')[0])).abs();
  //   int ageDiffB = (ageB - int.parse(currentUser.dob.split('-')[0])).abs();
  //   return ageDiffA.compareTo(ageDiffB);
  // });

  return users;
}





// Similarity Algorithms
double jaccardSimilarity(Set<String> set1, Set<String> set2) {
  if (set1.isEmpty || set2.isEmpty) return 0.0;

  int intersectionSize = set1.intersection(set2).length;
  int unionSize = set1.union(set2).length;

  return intersectionSize / unionSize;
}

double cosineSimilarity(List<double> vec1, List<double> vec2) {
  if (vec1.length != vec2.length || vec1.isEmpty) return 0.0;

  double dotProduct = 0.0;
  double norm1 = 0.0;
  double norm2 = 0.0;

  for (int i = 0; i < vec1.length; i++) {
    dotProduct += vec1[i] * vec2[i];
    norm1 += vec1[i] * vec1[i];
    norm2 += vec2[i] * vec2[i];
  }

  if (norm1 == 0 || norm2 == 0) return 0.0;

  return dotProduct / (sqrt(norm1) * sqrt(norm2));
}

// Match Score
double computeMatchScore(User user1, User user2, {double artistWeight = 0.4, double genreWeight = 0.3, double audioWeight = 0.3}) {
  double artistSim = jaccardSimilarity(user1.favoriteArtists, user2.favoriteArtists);
  double genreSim = jaccardSimilarity(user1.favoriteGenres, user2.favoriteGenres);
  double audioSim = cosineSimilarity(user1.audioFeatures, user2.audioFeatures);

  return (artistSim * artistWeight) + (genreSim * genreWeight) + (audioSim * audioWeight);
}

