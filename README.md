# DUET
This project aims to connect people through shared musical interests, creating friendships and community by analyzing Spotify activity to match users with similar tastes and recommending concerts to promote activities to build relationships. Unlike dating-focused platforms, it emphasizes connections, whether platonic or romantic, centered around music. Built with Flutter for mobile and web compatibility, the backend uses Firebase, including Firestore and Firebase Auth for real-time data and authentication, and with Meta’s Send API allowing chat features. Its unique concert recommendation feature sets it apart by offering users a way to strengthen connections through shared experiences, helping them discover local events/concerts that align with their music preferences. This provides a safe and natural setting to meet in person, strengthening the bond formed through the platform.

> We aim to get users that feel connection off our platform onto their existing social media

### Layout
* Status Reports: weekly status reports of the project
* proposal: original project proposal and feedback
* duet_application: application source code with flutter layout
* data:

## Beta Release - Core Features

### **Implemented and Integrated Features**:

- **Backend Data Storage**: Integration with Firebase Firestore for secure, real-time user data storage, including profiles and messages.
- **Messaging System**: Real-time messaging class implemented, allowing users to communicate with each other seamlessly.
- **User Profile Update**: Users can create and update their profiles, and any changes are saved to Firestore, reflecting on the user interface.
- **User Screen UI**: The start of the user profile interface is integrated, displaying updates from the backend, including profile details.
  
### **Use Cases Operational**:

- **User Profile Update**: Users can view and update their profile (e.g., bio, profile). Changes are stored in the backend and reflected on the user interface.
- **UI Integration**: The UI reflects changes from the backend, ensuring that user profile updated.

### **Build System**

1. **Prerequisites**:
   - Install Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install).
   - Install the latest version of Android Studio (for mobile development) or Visual Studio Code with the Flutter and Dart extensions for development.
   - Install Firebase CLI and initialize Firebase for the project using [Firebase Setup](https://firebase.google.com/docs/flutter/setup).

2. **Setup Firebase**:

   - Install Firebase CLI globally:
     ```bash
     dart pub global activate flutterfire_cli
     ```

   - Edit your shell configuration file (`~/.zshrc` for zsh, or the appropriate file for your shell):
     ```bash
     nano ~/.zshrc
     export PATH="$PATH":"$HOME/.pub-cache/bin"  # Save this to ~/.zshrc or the relevant shell config file
     source ~/.zshrc
     ```

   - Run `flutterfire configure` to set up Firebase configuration:
     ```bash
     flutterfire configure
     ```

   - If you encounter issues with Xcode setup, install the necessary gem:
     ```bash
     sudo gem install xcodeproj
     gem list xcodeproj
     ```

   - Add Firebase Core to your project:
     ```bash
     flutter pub add firebase_core
     ```

   - Add other Firebase plugins based on your needs (check the plugin names on the [FlutterFire website](https://firebase.flutter.dev/docs/overview)):
     ```bash
     flutter pub add PLUGIN_NAME  # Replace PLUGIN_NAME with the specific plugin you need
     ```

3. **Run the App**:
   To run the app on your desired platform (iOS/Android), execute the following command:
   ```bash
   flutter run

### **Version Control and Tagging**

To mark this release, we have created a Git tag for the Beta Release:

```bash
git tag -a v1.0.0-beta -m "Beta release of DUET"
commit 9d0f1a99f03662c9b9e12878c3a7330b9ae95126 (HEAD, tag: v1.0.0-beta, origin/main, origin/HEAD, main)