import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duet_application/src/backend/messaging_backend.dart';
import 'package:flutter/material.dart';
import '../../backend/userProfile.dart';
import '../../backend/spotifyUserData.dart';
import 'swipeUser.dart';
import '../../algo/matching.dart';

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
    _loadPotentialMatches();
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
      final userId = doc.get('authid');
      return userId != widget.currentUser.authId &&
          !widget.currentUser.likedUsers.contains(userId) &&
          !widget.currentUser.dislikedUsers.contains(userId);
    }).map((doc) async {
      final userData = UserProfileData.fromMap(doc.data());
      return userData;
    }));

    // Run dummy matching algorithm
    final filteredUsersSubset = dummyMatching(filteredUsers, widget.currentUser);

    setState(() {
      potentialMatches = filteredUsersSubset;
      isLoading = false;
    });
  }

  void handleSwipe(bool isLiked, String otherUuid) async {
    // Update Firestore with swipe
    await widget.currentUser.swipeUser(otherUuid, isLiked);

    // Create new conversation if both users liked each other
    if (isLiked) {
      final otherUser = await UserProfileData.getUserProfile(otherUuid);
      if (otherUser!.likedUsers.contains(widget.currentUser.authId)) {
        final newConversation = Messagingbackend(
          uuid1: widget.currentUser.authId,
          uuid2: otherUuid,
        );
        await newConversation.saveToFirestore();
      }
    }

    // Move to next profile
    if (currentIndex < potentialMatches.length) {
      setState(() {
        currentIndex++;
      });
    } else {
      // If we've reached the end of our list, load more matches
      _loadPotentialMatches();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (potentialMatches.isEmpty) {
      _loadPotentialMatches();
      return const Center(child: Text('No more profiles to show'));
    }

    if (currentIndex >= potentialMatches.length) {
      return const Center(child: Text('No more profiles to show'));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C469C),
        title: const Text("Match with Someone!"),
      ),
      body: FutureBuilder<SpotifyUserData?>(
        future: potentialMatches[currentIndex].getSpotifyUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Container(
            color: const Color(0xFFE6E6FA), // Lilac background
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child:  SwipeUserScreen(
                  userProfile: potentialMatches[currentIndex],
                  spotifyUserData: snapshot.data ??
                      SpotifyUserData(
                        uuid: potentialMatches[currentIndex].uuid,
                        email: potentialMatches[currentIndex].email,
                        favoriteGenres: {},
                      ),
                  swipeAction: handleSwipe,
                ),
              ),
            );
        },
      ),
    );
  }
}
