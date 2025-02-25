import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../backend/userProfile.dart';
import '../backend/spotifyUserData.dart';
import 'swipeUser.dart';
import '../algo/matching.dart';

class SwipeUserParent extends StatefulWidget {
  final UserProfileData currentUser;

  const SwipeUserParent({
    super.key,
    required this.currentUser,
  });

  @override
  State<SwipeUserParent> createState() => _SwipeUserParentState();
}

class _SwipeUserParentState extends State<SwipeUserParent> {
  List<UserProfileData> potentialMatches = [];
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // _loadDummyUsers();
    _loadPotentialMatches();
  }

  void _loadDummyUsers() {
    // Create dummy users for testing
    final dummyUsers = [
      UserProfileData(
        uuid: "dummy1",
        name: "John Doe",
        email: "john@example.com",
        dob: "01/01/1995",
        location: "New York",
        password: "dummy",
        bio: "I love music and concerts!",
      ),
      UserProfileData(
        uuid: "dummy2",
        name: "Jane Smith",
        email: "jane@example.com",
        dob: "03/15/1997",
        location: "Los Angeles",
        password: "dummy",
        bio: "Rock and indie music enthusiast",
      ),
      UserProfileData(
        uuid: "dummy3",
        name: "Mike Johnson",
        email: "mike@example.com",
        dob: "07/22/1993",
        location: "Chicago",
        password: "dummy",
        bio: "Jazz and blues lover",
      ),
      UserProfileData(
        uuid: "dummy4",
        name: "Gold Tooth",
        email: "gt@inferno.com",
        dob: "07/22/2001",
        location: "Chicago",
        password: "dummy",
        bio: "Metal enjoyer",
      ),
    ];

    print('Dummy Users:');
    for (var user in dummyUsers) {
      print('Name: ${user.name}');
      print('Email: ${user.email}');
      print('Location: ${user.location}');
      print('Bio: ${user.bio}');
      print('-------------------');
    }

    // Filtering here, copy to real one too
    print('AR Name: ${widget.currentUser.name}');
    print('AR Email: ${widget.currentUser.email}');

    final profileSubset = dummyMatching(dummyUsers, widget.currentUser);
    print('Filtered Users:');
    for (var user in profileSubset) {
      print('Name: ${user.name}');
      print('Email: ${user.email}');
      print('Location: ${user.location}');
      print('Bio: ${user.bio}');
      print('-------------------');
    }

    setState(() {
      potentialMatches = profileSubset;
      isLoading = false;
    });

  }

  Future<void> _loadPotentialMatches() async {
    setState(() {
      isLoading = true;
    });

    // Get all users from Firestore
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    // Filter out current user and already swiped users
    final filteredUsers = await Future.wait(usersSnapshot.docs.where((doc) {
      final userId = doc.get('uuid');
      return userId != widget.currentUser.uuid &&
          !widget.currentUser.likedUsers.contains(userId) &&
          !widget.currentUser.dislikedUsers.contains(userId);
    }).map((doc) async {
      final userData = UserProfileData.fromMap(doc.data());
      return userData;
    }));

    // Now rerank the unseen users
    final rerankedUsers = reranking(filteredUsers, widget.currentUser);

    // print('init Name: ${widget.currentUser.name}');
    // print('init Email: ${widget.currentUser.email}');

    setState(() {
      potentialMatches = rerankedUsers;
      isLoading = false;
    });
  }

  void handleSwipe(bool isLiked) async {
    if (currentIndex < potentialMatches.length) {
      // Get Spotify data for the current profile
      await potentialMatches[currentIndex].updateSpotifyData();
      final spotifyData = potentialMatches[currentIndex].spotifyData;

      setState(() {
        currentIndex++;
      });

      // If we've reached the end of our list, load more matches
      if (currentIndex >= potentialMatches.length) {
        _loadPotentialMatches();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (potentialMatches.isEmpty) {
      return const Center(child: Text('No more profiles to show'));
    }

    if (currentIndex >= potentialMatches.length) {
      return const Center(child: Text('No more profiles to show'));
    }

    return FutureBuilder<SpotifyUserData?>(
      future: potentialMatches[currentIndex].getSpotifyUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return SwipeUserScreen(
          userProfile: potentialMatches[currentIndex],
          spotifyUserData: snapshot.data ??
              SpotifyUserData(
                uuid: potentialMatches[currentIndex].uuid,
                email: potentialMatches[currentIndex].email,
                favoriteGenres: [],
              ),
          swipeAction: handleSwipe,
        );
      },
    );
  }
}
