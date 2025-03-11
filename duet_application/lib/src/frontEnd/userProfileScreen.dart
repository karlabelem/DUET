import 'package:duet_application/src/backend/userProfile.dart';
import 'package:duet_application/src/frontEnd/feed/swipe_user_parent.dart';
import 'package:flutter/material.dart';
import 'package:duet_application/src/backend/spotifyUserData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  final UserProfileData user;
  final Function logOut;

  const UserProfileScreen(
      {super.key, required this.user, required this.logOut});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<Set<String>> _favoriteGenresFuture;

  @override
  void initState() {
    super.initState();
    _favoriteGenresFuture = _loadTopGenres();
  }

  Future<Set<String>> _loadTopGenres() async {
    SpotifyUserData? userData = await SpotifyUserData.get(widget.user.uuid);
    return userData.favoriteGenres ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C469C),
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Log Out"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.logOut();
                      },
                      child: const Text("Log Out"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<UserProfileData?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5C469C),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User profile not found.'));
          } else {
            final userProfile = snapshot.data!;
            return Container(
              color: const Color(0xFFE6E6FA),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileHeader(userProfile),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          _buildAboutMeSection(userProfile),
                          const SizedBox(height: 20),
                          _buildMusicSection(),
                          const SizedBox(height: 20),
                          _buildDetailsSection(userProfile),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
    );
          }
        

  Widget _buildProfileHeader(UserProfileData userProfile) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF5C469C),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 30.0, top: 20.0),
      child: Column(
        children: [
          // Profile picture
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 4),
              borderRadius: BorderRadius.circular(75),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.person,
                size: 80,
                color: Color(0xFF5C469C),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            userProfile.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          // Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                userProfile.location,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Edit profile button
          ElevatedButton.icon(
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
            icon: const Icon(Icons.edit),
            label: const Text("Edit Profile",
                style: TextStyle(
                    color: Colors.black87, fontStyle: FontStyle.normal)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF5C469C),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutMeSection(UserProfileData userProfile) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "About Me",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5C469C),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xFF5C469C),
                  ),
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
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              userProfile.bio.isEmpty
                  ? "Tell potential matches about yourself..."
                  : userProfile.bio,
              style: TextStyle(
                fontSize: 16,
                color: userProfile.bio.isEmpty ? Colors.grey : Colors.black87,
                fontStyle: userProfile.bio.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicSection() {
    return FutureBuilder<Set<String>>(
      future: _favoriteGenresFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF5C469C),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final favoriteGenres = snapshot.data ?? {};
          return Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.music_note,
                        color: Color(0xFF5C469C),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "My Music Taste",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C469C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  favoriteGenres.isEmpty
                      ? const Text(
                          "Connect your Spotify to show your music taste!",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: favoriteGenres
                              .take(5)
                              .map(
                                (genre) => Chip(
                                  label: Text(
                                    genre,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFF5C469C),
                                ),
                              )
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

  Widget _buildDetailsSection(UserProfileData userProfile) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C469C),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.cake, "Birthday", userProfile.dob),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.email, "Email", userProfile.email),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF5C469C),
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          "$label:",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
  bool _isChanged = false;
  int maxChars = 300;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.bio; // Set initial value
    _controller.addListener(() {
      setState(() {
        _isChanged = _controller.text != widget.bio;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Me"),
        backgroundColor: const Color(0xFF5C469C),
      ),
      backgroundColor: const Color(0xFFE6E6FA),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Tell potential matches about yourself",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C469C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
                "What artists are you passionate about? What makes your music taste unique? What's a song you can't live without?",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontStyle: FontStyle.normal,
                )),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 8,
              maxLength: maxChars,
              decoration: InputDecoration(
                hintText: "Write something about yourself...",
                hintStyle: TextStyle(
                  fontStyle: FontStyle.normal,
                  color: Colors.black54,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.black,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF5C469C),
                    width: 2,
                  ),
                ),
                counterStyle: TextStyle(color: Colors.black),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 13),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isChanged ? Colors.purple : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
              child: const Text(
                "Save",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFF5C469C),
      ),
      backgroundColor: const Color(0xFFE6E6FA),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Name",
              style: TextStyle(
                color: Color(0xFF5C469C),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person, color: Color(0xFF5C469C)),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFF5C469C), width: 2),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 10),
            const Text(
              "Email",
              style: TextStyle(
                color: Color(0xFF5C469C),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email, color: Color(0xFF5C469C)),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFF5C469C), width: 2),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 10),
            const Text(
              "DOB",
              style: TextStyle(
                color: Color(0xFF5C469C),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _dobController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.cake, color: Color(0xFF5C469C)),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFF5C469C), width: 2),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 10),
            const Text(
              "Location",
              style: TextStyle(
                color: Color(0xFF5C469C),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on, color: Color(0xFF5C469C)),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFF5C469C), width: 2),
                ),
              ),
              style: const TextStyle(color: Colors.black),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C469C),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Save",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
