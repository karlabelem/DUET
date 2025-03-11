import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duet_application/src/app.dart';
import 'package:duet_application/src/backend/authentication_instance.dart';
import 'package:duet_application/src/backend/firestore_instance.dart';
import 'package:duet_application/src/settings/settings_controller.dart';
import 'package:duet_application/src/settings/settings_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from the .env file.
  await dotenv.load(fileName: ".env");
  // Initialize Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
   try {
     FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
     await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
   } catch (e) {
     // ignore: avoid_print
     print(e);
   }
 }


 makeFirestoreInstance(instance: FirebaseFirestore.instance);
 makeAuthenticationInstance(instance: FirebaseAuth.instance);
 
    runApp(MyApp(settingsController: settingsController,));
}
