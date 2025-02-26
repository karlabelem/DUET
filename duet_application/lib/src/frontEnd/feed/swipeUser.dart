import 'package:duet_application/src/backend/spotifyUserData.dart';
import 'package:flutter/material.dart';
import '../../backend/userProfile.dart';

// ------------------ Swipe User  ------------------
class SwipeUserScreen extends StatefulWidget {
  final UserProfileData userProfile;
  final SpotifyUserData spotifyUserData;
  final Function(bool, String) swipeAction;

  const SwipeUserScreen({super.key, required this.userProfile, required this.swipeAction, required this.spotifyUserData});

  @override
  State<SwipeUserScreen> createState() => _SwipeUserScreenState();
}

class _SwipeUserScreenState extends State<SwipeUserScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 100,
              color: Colors.transparent,
              child: Center(
                child: IconButton(
                  icon: Icon(Icons.thumb_down, color: Colors.red, size: 50),
                  onPressed: () {
                    widget.swipeAction(false, widget.userProfile.uuid); // Swiped left (dislike)
                  },
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 100,
              color: Colors.transparent,
              child: Center(
                child: IconButton(
                  icon: Icon(Icons.thumb_up, color: Colors.green, size: 50),
                  onPressed: () {
                    widget.swipeAction(true, widget.userProfile.uuid); // Swiped right (like)
                  },
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 400,
              child: Card(
                color: Color(0xFF5C469C),
                elevation: 20,
                margin: EdgeInsets.all(40),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.person, size: 50, color: Color(0xFF5C469C)),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.userProfile.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.userProfile.bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.userProfile.location,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Favorite Genres:',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: (widget.spotifyUserData.favoriteGenres ?? {}).map((genre) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Chip(
                            label: Text(genre, style: const TextStyle(color: Colors.white)),
                            backgroundColor: Color(0xFF5C469C),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
