import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userProfile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user with email & password
  Future<User?> registerUser({
    required String name,
    required String email,
    required String password,
    required String dob,
    required String location,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        UserProfileData userProfile = UserProfileData(
          uuid: user.uid,
          name: name,
          email: email,
          password: password,
          dob: dob,
          location: location,
        );
        await userProfile.saveToFirestore();
      }
      return user;
    } catch (e) {
      print("Error registering user: $e");
      return null;
    }
  }

  // Login user with email & password
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error logging in: $e");
      return null;
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Send email verification
  Future<void> sendVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Delete user account
  Future<void> deleteUserAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
      }
    } catch (e) {
      print("Error deleting account: $e");
    }
  }
}