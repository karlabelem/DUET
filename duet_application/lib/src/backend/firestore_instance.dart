import 'package:cloud_firestore/cloud_firestore.dart';

/// A class that wraps around the FirebaseFirestore instance.
/// This allows for easier dependency injection and testing.
class FirestoreInstance {
  final FirebaseFirestore _instance;

  /// Constructor that initializes the FirestoreInstance with a given FirebaseFirestore instance.
  const FirestoreInstance({required FirebaseFirestore instance}) : _instance = instance;

  /// Getter to access the FirebaseFirestore instance.
  FirebaseFirestore get instance => _instance;
}

/// A global variable to hold the FirestoreInstance.
/// This allows for easy access to the FirestoreInstance throughout the app.
FirestoreInstance? firestoreInstance;

/// A function to create and set the global FirestoreInstance.
/// This function should be called during app initialization.
void makeFirestoreInstance({required FirebaseFirestore instance}) {
  firestoreInstance = FirestoreInstance(instance: instance);
}