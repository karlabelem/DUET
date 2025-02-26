import 'package:duet_application/src/backend/userProfile.dart';
import 'package:duet_application/src/frontEnd/feed/swipe_user_parent.dart';
import 'package:flutter/material.dart';
import 'package:duet_application/src/backend/spotifyUserData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  final String userUuid;
  final Function logOut;

  const UserProfileScreen(
      {super.key, required this.userUuid, required this.logOut});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<UserProfileData?> _userProfileFuture;
  late Future<Set<String>> _favoriteGenresFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _fetchUserProfile();
    _favoriteGenresFuture = _loadTopGenres();
  }

  Future<UserProfileData?> _fetchUserProfile() async {
    return await UserProfileData.getUserProfile(widget.userUuid);
  }

  Future<Set<String>> _loadTopGenres() async {
    SpotifyUserData? userData = await SpotifyUserData.get(widget.userUuid);
    return userData.favoriteGenres ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5C469C),
        title: Text("User Profile"),
        leading: IconButton(
          icon: Icon(Icons.menu), // Three-line menu icon
          onPressed: () {
            // Show the dropdown menu when the icon is pressed
            showMenu(
              context: context,
              position:
                  RelativeRect.fromLTRB(0, 60, 0, 0), // Adjust position of menu
              items: <PopupMenuEntry>[
                PopupMenuItem<String>(
                  value: 'HOME',
                  child: Text('HOME'),
                ),
                PopupMenuItem<String>(
                  value: 'PROFILE',
                  child: Text('PROFILE'),
                ),
                PopupMenuItem<String>(
                  value: 'SIGN OUT',
                  child: Text('SIGN OUT'),
                ),
              ],
            );
          },
        ),
      ),
      body: FutureBuilder<UserProfileData?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('User profile not found.'));
          } else {
            final userProfile = snapshot.data!;
            return Container(
              color: const Color(0xFFE6E6FA), // Lilac background
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(userProfile), // Profile Card
                  const SizedBox(width: 16),
                  _buildAboutMeCard(
                      userProfile), // About Me section next to Profile Card
                  const SizedBox(width: 16),
                  _buildTopGenresCard(), // Music section next to About Me section
                  const SizedBox(width: 16),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileCard(UserProfileData userProfile) {
    return Container(
      width: 300,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF5C469C),
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              userProfile.name,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 5),
            _buildInfoRow("Name", userProfile.name),
            _buildInfoRow("Email", userProfile.email),
            _buildInfoRow("DOB", userProfile.dob),
            _buildInfoRow("Location", userProfile.location),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                final updatedProfile = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditProfileScreen(userProfile: userProfile),
                  ),
                );

                if (updatedProfile != null) {
                  setState(() {
                    userProfile.name = updatedProfile['name'];
                    userProfile.email = updatedProfile['email'];
                    userProfile.dob = updatedProfile['dob'];
                    userProfile.location = updatedProfile['location'];
                  });

                  await userProfile.updateProfile(
                    updatedProfile['name'],
                    updatedProfile['email'],
                    updatedProfile['dob'],
                    updatedProfile['location'],
                  );
                }
              },
              child: const Text("Edit Profile"),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                widget.logOut();
              },
              child: const Text("Log Out"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutMeCard(UserProfileData userProfile) {
    return Container(
      width: 300,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("About Me",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 10),
            Text(userProfile.bio,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final updatedAboutMe = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditAboutMeScreen(bio: userProfile.bio),
                  ),
                );
                if (updatedAboutMe != null) {
                  setState(() {
                    userProfile.bio = updatedAboutMe;
                  });
                  await userProfile.updateBio(updatedAboutMe);
                }
              },
              child: const Text("Edit",
                  style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopGenresCard() {
    return FutureBuilder<Set<String>>(
      future: _favoriteGenresFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No top genres available.'));
        } else {
          final favoriteGenres = snapshot.data!;
          return Container(
            width: 300,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Top Genres",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: favoriteGenres
                        .take(5) // Ensure only top 5 genres are displayed
                        .map((genre) => Text(genre,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black)))
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

// ------------------ Edit About Me Screen ------------------
class EditAboutMeScreen extends StatefulWidget {
  final String bio;
  const EditAboutMeScreen({super.key, required this.bio});

  @override
  State<EditAboutMeScreen> createState() => _EditAboutMeScreenState();
}

class _EditAboutMeScreenState extends State<EditAboutMeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.bio; // Set initial value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit About Me")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Write something about yourself...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}

// ------------------ Edit Profile Screen ------------------
class EditProfileScreen extends StatefulWidget {
  final UserProfileData userProfile;
  const EditProfileScreen({super.key, required this.userProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController,
      _emailController,
      _dobController,
      _locationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.name);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _dobController = TextEditingController(text: widget.userProfile.dob);
    _locationController =
        TextEditingController(text: widget.userProfile.location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: "Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                  labelText: "Email", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dobController,
              decoration: const InputDecoration(
                  labelText: "DOB", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                  labelText: "Location", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'name': _nameController.text,
                  'email': _emailController.text,
                  'dob': _dobController.text,
                  'location': _locationController.text,
                });
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
