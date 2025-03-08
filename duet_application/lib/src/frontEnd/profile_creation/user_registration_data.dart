import 'package:duet_application/src/backend/userProfile.dart';

class UserRegistrationData {
  String email = '';
  String password = '';
  String firstName = '';
  String lastName = '';
  String dob = '';
  String location = '';

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': '$firstName $lastName',
      'dob': dob,
      'location': location,
    };
  }

  // Convert registration data to UserProfileData
  UserProfileData toUserProfile() {
    return UserProfileData(
      name: '$firstName $lastName',
      email: email,
      dob: dob,
      password: password,
      location: location,
      imageUrl: '', // Default empty image URL
    );
  }

  // Save to Firestore
  Future<void> saveToFirestore() async {
    final userProfile = toUserProfile();
    await userProfile.saveToFirestore();
  }
}
