import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A class that wraps around the FirebaseFirestore instance.
/// This allows for easier dependency injection and testing.
class AuthenticationInstance {
  final FirebaseAuth _instance;

  /// Constructor that initializes the FirestoreInstance with a given FirebaseFirestore instance.
  const AuthenticationInstance({required FirebaseAuth instance}) : _instance = instance;

  /// Getter to access the FirebaseFirestore instance.
  FirebaseAuth get instance => _instance;
}

/// A global variable to hold the FirestoreInstance.
/// This allows for easy access to the FirestoreInstance throughout the app.
AuthenticationInstance? authenticationInstance;

/// A function to create and set the global FirestoreInstance.
/// This function should be called during app initialization.
void makeAuthenticationInstance({required FirebaseAuth instance}) {
  authenticationInstance = AuthenticationInstance(instance: instance);
}