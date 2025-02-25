import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../backend/userProfile.dart';

/*
Well, Beta++ launches with dummy profiles. These look like 

      UserProfileData(
        uuid: "dummy3",
        name: "Mike Johnson",
        email: "mike@example.com",
        dob: "1993-07-22",
        location: "Chicago",
        password: "dummy",
        bio: "Jazz and blues lover",
      ),

Eventually, updates tests with these. For now, 
(1) generate dummy set with expected behavior
(2) write function to match them as expected
(3) get confirmation from DUET member who can run frontend
(4) compare data in Dummy to data in FireBase; update as needed

 */

List<UserProfileData> filterCity(List<UserProfileData> users, UserProfileData currentUser) {
  return users.where((user) => user.location == currentUser.location).toList();
}

List<UserProfileData> reranking(List<UserProfileData> users, UserProfileData currentUser) {
  // Order the user in decreasing order of weighted overlap in spotify albums between a user and current user.
  // The numerator (shared items) is more important, because people who listen to 100 of same songs should be strongly matched, even if 10,000 dissimilar
  // Let's start with raw intersection size, then normalize by the size of the current user's set
  users.sort((a, b) {
    int overlapA = a.spotifyData.favoriteArtists.intersection(currentUser.favoriteArtists).length / currentUser.favoriteArtists.length;
    int overlapB = b.spotifyData.favoriteArtists.intersection(currentUser.favoriteArtists).length / currentUser.favoriteArtists.length;
    return overlapB.compareTo(overlapA);
  });
  // TODO considerations around a song everyone listens to artificially boosting similarity; user can select what to search for (only Perfect Circle).
  return users;
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




class User {
  final String id;
  final Set<String> favoriteArtists;
  final Set<String> favoriteGenres;
  final List<double> audioFeatures;

  User({
    required this.id,
    required this.favoriteArtists,
    required this.favoriteGenres,
    required this.audioFeatures,
  });

  // Add this method to create a User from a Firestore document
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      favoriteArtists: Set<String>.from(data['favoriteArtists'] ?? []),
      favoriteGenres: Set<String>.from(data['favoriteGenres'] ?? []),
      audioFeatures: List<double>.from(data['audioFeatures'] ?? []),
    );
  }
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

// Return ranked matches
List<Map<String, dynamic>> findBestMatches(User targetUser, List<User> allUsers) {
  List<Map<String, dynamic>> matches = [];

  for (User user in allUsers) {
    if (user.id == targetUser.id) continue; // Skip self-matching

    double score = computeMatchScore(targetUser, user);
    matches.add({'user': user, 'score': score});
  }

  // Sort matches by score in descending order
  matches.sort((a, b) => b['score'].compareTo(a['score']));

  return matches;
}

// Example usage
void main() {
  User userA = User(
    id: "1",
    favoriteArtists: {"Taylor Swift", "Drake"},
    favoriteGenres: {"Pop", "Hip-Hop"},
    audioFeatures: [0.8, 0.6, 0.7], // Example tempo, energy, danceability
  );

  User userB = User(
    id: "2",
    favoriteArtists: {"Drake", "Kanye West"},
    favoriteGenres: {"Hip-Hop", "Rap"},
    audioFeatures: [0.7, 0.6, 0.8],
  );

  User userC = User(
    id: "3",
    favoriteArtists: {"Billie Eilish", "Lorde"},
    favoriteGenres: {"Indie Pop", "Alternative"},
    audioFeatures: [0.5, 0.4, 0.6],
  );

  List<User> allUsers = [userB, userC];

  List<Map<String, dynamic>> matches = findBestMatches(userA, allUsers);

  for (var match in matches) {
    print("Matched with ${match['user'].id} - Score: ${match['score'].toStringAsFixed(2)}");
  }
}


// Example usage
/*
void main() {
  User userA = User(
    id: "1",
    favoriteArtists: {"Taylor Swift", "Drake"},
    favoriteGenres: {"Pop", "Hip-Hop"},
    audioFeatures: [0.8, 0.6, 0.7], // Example tempo, energy, danceability
  );

  User userB = User(
    id: "2",
    favoriteArtists: {"Drake", "Kanye West"},
    favoriteGenres: {"Hip-Hop", "Rap"},
    audioFeatures: [0.7, 0.6, 0.8],
  );

  User userC = User(
    id: "3",
    favoriteArtists: {"Billie Eilish", "Lorde"},
    favoriteGenres: {"Indie Pop", "Alternative"},
    audioFeatures: [0.5, 0.4, 0.6],
  );

  List<User> allUsers = [userB, userC];

  List<Map<String, dynamic>> matches = findBestMatches(userA, allUsers);

  for (var match in matches) {
    print("Matched with ${match['user'].id} - Score: ${match['score'].toStringAsFixed(2)}");
  }
}
*/