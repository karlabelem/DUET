/* This file is for user profile to keep track of information about users
  UserProfileData class has the following informations about the user:
    - uuid: Unique User ID
    - name: Name of the user
    - dob: Date of birth
    - location: Current location of the user
    - aboutMe: Users about me section to let them have a small text on the profile
    - Spotify Data: Their connected spotify data??
    - Ranked Profiles: Ranked profiles on the feed
*/

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'spotifyUserData.dart';
import 'firestore_instance.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

// Create an instance of the Uuid class
var _uuidGen = Uuid();

// This class represents a user's profile data.
// It stores user details (name, DOB, location) and rankings for other users.
// The `rankedProfiles` map stores user UUIDs with their ranking (-1, 0, 1).
// Rankings can be dynamically updated via the `rankUser` method.
class UserProfileData {
  final String _uuid; // Private unique user ID
  String name, email, dob, location, bio; //password;
  SpotifyUserData? spotifyData;
  String? imageUrl;
  List<String> likedUsers; // Stores liked users with user UUIDs
  List<String> dislikedUsers; // Stores liked users with user UUIDs
  late String _passwordHash; //  Securely store password hash

  UserProfileData({
    uuid,
    required this.name,
    required this.email,
    required this.dob,
    required this.location,
    required String password,
    this.spotifyData,
    this.imageUrl,
    this.bio = "",
    List<String>? likedUsers,
    List<String>? dislikedUsers,
  })  : _uuid = uuid ?? _uuidGen.v4(),
        likedUsers = likedUsers ?? [],
        dislikedUsers = dislikedUsers ?? [] {
    _passwordHash = _hashPassword(password); // ✅ Assign password inside constructor body
  }

  // Convert to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'email': email,
      'dob': dob,
      'passwordHash': _passwordHash, // 🔒 Store only hashed password
      // 'password': password,
      'location': location,
      'imageUrl': imageUrl,
      'bio': bio,
      'likedUsers': likedUsers,
      'dislikedUsers': dislikedUsers,
    };
  }

  // Create an instance from Firestore data
  factory UserProfileData.fromMap(Map<String, dynamic> data) {
    return UserProfileData(
      uuid: data['uuid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      dob: data['dob'] ?? '',
      password: '', // password: data['password'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      bio: data['bio'] ?? '',
      likedUsers: List<String>.from(data['likedUsers'] ?? []),
      dislikedUsers: List<String>.from(data['dislikedUsers'] ?? []),
    ).._passwordHash = data['passwordHash']; // 🔒 Assign password hash
  }

   // Hash password using SHA-256
  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // Verify password
  bool verifyPassword(String password) {
    return _passwordHash == _hashPassword(password);
  }

  // Getter for _uuid (to allow read access)
  String get uuid => _uuid;

  // Save user profile data to Firestore
  Future<void> saveToFirestore() async {
    await firestoreInstance!.instance
        .collection('users')
        .doc(uuid)
        .set(toMap()); // creates users collection
  }

  // Method to link Spotify profile
  Future<void> linkSpotifyProfile() async {
    spotifyData = await SpotifyUserData.createSpotifyProfile(uuid);
  }

  // Fetch or update Spotify data
  Future<void> updateSpotifyData() async {
    if (spotifyData != null) {
      await spotifyData!.updateSpotifyData();
    } else {
      await linkSpotifyProfile();
    }
  }

  // Method to get Spotify User Data
  // For algorihtm
  Future<SpotifyUserData?> getSpotifyUserData() async {
    final spotifyRef = firestoreInstance!.instance
        .collection('spotify_users')
        .doc(uuid); // fetch Spotify data based on the user UUID
    final spotifySnapshot = await spotifyRef.get();
    if (spotifySnapshot.exists) {
      return SpotifyUserData.fromMap(spotifySnapshot.data()!);
    }
    return null;
  }

  // Method for getting UserProfile Snapshot shortcut
  // For Algorithm
  static Future<UserProfileData?> getUserProfile(String userId) async {
    final userRef = firestoreInstance!.instance
        .collection('users')
        .doc(userId); // fetch data from Firestore users collection
    final userSnapshot = await userRef.get();
    if (userSnapshot.exists) {
      return UserProfileData.fromMap(userSnapshot.data()!);
    }
    return null;
  }

  // Swipe function to update userprofile
  // For UI
  Future<void> swipeUser(String otherUuid, bool isLiked) async {
    final userRef = firestoreInstance!.instance
        .collection('users')
        .doc(uuid); // fetch data from Firestore users collection

    // Transaction is for updating data in Firebase directly rather than updating on local class
    await firestoreInstance!.instance.runTransaction((transaction) async {
      // Access to user snapshot with transaction
      final userTransaction = await transaction.get(userRef);
      if (!userTransaction.exists) return;

      // Get liked and disliked users data from the database map from Firestore transaction
      final data = userTransaction.data() as Map<String, dynamic>;
      likedUsers = List<String>.from(data['likedUsers'] ?? []);
      dislikedUsers = List<String>.from(data['dislikedUsers'] ?? []);

      // Update liked/disliked lists
      if (isLiked) {
        if (!likedUsers.contains(otherUuid)) {
          likedUsers.add(otherUuid);
        }
        dislikedUsers.remove(otherUuid);
      } else {
        if (!dislikedUsers.contains(otherUuid)) {
          dislikedUsers.add(otherUuid);
        }
        likedUsers.remove(otherUuid);
      }

      // Add updated changes on transaction through Firestore
      transaction.update(userRef, {
        'likedUsers': likedUsers,
        'dislikedUsers': dislikedUsers,
      });
    });
  }

  // Method to update bio info
  // For UI
  Future<int> updateBio(String newBio) async {
    try {
      final userRef = firestoreInstance!.instance.collection('users').doc(uuid);

      // Update the bio directly in Firestore without a transaction
      await userRef.update({
        'bio': newBio,
      });
      return 0;
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return 1;
    }
  }

  // Method to update profile details (name, dob, location)
  // For UI
  Future<int> updateProfile(String newName, String newEmail, String newDob, String newLocation) async {
    try {
      print(uuid);
      final userRef = firestoreInstance!.instance.collection('users').doc(uuid);

      // Update profile details directly in Firestore without a transaction
      await userRef.update({
        'name': newName,
        'email': newEmail,
        'dob': newDob,
        'location': newLocation,
      });
      return 0;
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return 1;
    }
  }

  // Method to update profile picture
  // For UI
  Future<void> updateImage(String newImageUrl) async {
    final userRef = firestoreInstance!.instance.collection('users').doc(uuid);

    // Run a transaction to update profile details
    await firestoreInstance!.instance.runTransaction((transaction) async {
      final userTransaction = await transaction.get(userRef);
      if (!userTransaction.exists) return;

      // Update profile details directly in Firestore
      transaction.update(userRef, {
        'imageUrl': newImageUrl,
      });
    });
  }
}

// Method to get user profile based on email and password
Future<UserProfileData?> getUserProfileByEmailAndPassword(dynamic email, dynamic password) async {
  final userQuery = await firestoreInstance!.instance
      .collection('users')
      .where('email', isEqualTo: email)
      .where('password', isEqualTo: password)
      .limit(1)
      .get();
  if (userQuery.docs.isNotEmpty) {
    return UserProfileData.fromMap(userQuery.docs.first.data());
  }
  return null;
}
