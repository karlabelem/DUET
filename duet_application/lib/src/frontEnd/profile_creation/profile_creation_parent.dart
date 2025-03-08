import 'package:duet_application/src/backend/spotifyUserData.dart';
import 'package:duet_application/src/backend/userProfile.dart';
import 'package:duet_application/src/frontEnd/profile_creation/profile_creation_s0.dart';
import 'package:duet_application/src/frontEnd/profile_creation/profile_creation_s1.dart';
import 'package:duet_application/src/frontEnd/profile_creation/profile_creation_s2.dart';
import 'package:duet_application/src/frontEnd/profile_creation/profile_creation_s3.dart';
import 'package:duet_application/src/frontEnd/profile_creation/profile_creation_s4.dart';
import 'package:duet_application/src/frontEnd/profile_creation/user_registration_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProfileCreationParent extends StatefulWidget {
  const ProfileCreationParent({super.key, required this.nextStep});

  final Function nextStep;

  @override
  State<ProfileCreationParent> createState() => ProfileCreationParentState();
}

class ProfileCreationParentState extends State<ProfileCreationParent> {
  final UserRegistrationData userRegistrationData = UserRegistrationData();
  late String uuid = ''; 
  int step = 0;

  void nextStep(Map<String, dynamic> data) {
    setState(() {
      switch (step) {
        case 0:
          userRegistrationData.email = data['email'] ?? '';
          userRegistrationData.password = data['password'] ?? '';
          break;
        case 1:
          userRegistrationData.firstName = data['firstName'] ?? '';
          userRegistrationData.lastName = data['lastName'] ?? '';
          break;
        case 2:
          userRegistrationData.dob = data['dob'] ?? '';
          break;
        case 3:
          userRegistrationData.location = data['location'] ?? '';
          break;
        case 4:
          _createUserProfile(data);
          widget.nextStep();
          break;
      }
      step = step + 1;
    });
  }

  Future<void> _createUserProfile(Map<String, dynamic> data) async {
    try {
      final userProfile = UserProfileData(
        name:
            '${userRegistrationData.firstName} ${userRegistrationData.lastName}',
        email: userRegistrationData.email,
        dob: userRegistrationData.dob,
        location: userRegistrationData.location,
        password: userRegistrationData.password,
        imageUrl: '', // Default empty image URL
      );

      await userProfile.saveToFirestore();
      uuid = userProfile.uuid;
      await _createSpotifyUserData(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user profile: $e');
      }
    }
  }

  Future<void> _createSpotifyUserData(Map<String, dynamic> data) async {
    final Set<String> favoriteGenres = (data['genres'] as Set<dynamic>).cast<String>();
    final spotifyUserData = SpotifyUserData(
      uuid: uuid,
      email: userRegistrationData.email,
      favoriteGenres: favoriteGenres,
    );
    spotifyUserData.save();
  }

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return AccountRegistration(nextStep: nextStep);
      case 1:
        return ProfileCreationStep1(nextStep: nextStep);
      case 2:
        return ProfileCreationStep2(nextStep: nextStep);
      case 3:
        return ProfileCreationStep3(nextStep: nextStep);
      case 4:
        return ProfileCreationStep4(nextStep: nextStep);
      default:
        return Scaffold();
    }
  }
}
