import 'package:flutter/material.dart';
import '../backend/userProfile.dart';

class EditProfileImageScreen extends StatefulWidget {
  final UserProfileData userProfile;

  const EditProfileImageScreen({super.key, required this.userProfile});

  @override
  _EditProfileImageScreenState createState() => _EditProfileImageScreenState();
}

class _EditProfileImageScreenState extends State<EditProfileImageScreen> {
  late TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    _imageController = TextEditingController(text: widget.userProfile.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile Image")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              //backgroundImage: NetworkImage(widget.userProfile.imageUrl),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _imageController,
              decoration: InputDecoration(labelText: "Image URL"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                String newImageUrl = _imageController.text.trim();
                if (newImageUrl.isNotEmpty) {
                  await widget.userProfile.updateImage(newImageUrl);
                  setState(() {
                    widget.userProfile.imageUrl = newImageUrl;
                  });
                  Navigator.pop(context, newImageUrl);
                }
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
