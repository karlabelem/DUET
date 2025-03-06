import 'package:duet_application/src/backend/userProfile.dart';
import 'package:duet_application/src/frontEnd/login_screen.dart';
import 'package:duet_application/src/frontEnd/userProfileScreen.dart';
import 'package:duet_application/src/frontEnd/profile_creation/profile_creation_parent.dart';
import 'package:duet_application/src/messaging/messaging_page.dart';
import 'package:duet_application/src/frontEnd/feed/swipe_user_parent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'settings/settings_controller.dart';

enum AppState {
  profileCreation,
  userProfile,
  conversation,
  login,
  swipe,
  // Add other states as needed
}

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppState appState = AppState.login;
  UserProfileData? loggedInUser;

  void openLoginScreen() {
    setState(() {
      appState = AppState.login;
      loggedInUser = null;
    });
  }

  void openProfileCreationScreen() {
    setState(() {
      appState = AppState.profileCreation;
    });
  }

  void openUserProfileScreen(UserProfileData user) {
    setState(() {
      loggedInUser = user;
      appState = AppState.userProfile;
    });
  }

  void openConversationScreen() {
    setState(() {
      appState = AppState.conversation;
    });
  }

  void openSwipeScreen() {
    setState(() {
      appState = AppState.swipe;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: widget.settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                if (loggedInUser == null) {
                  switch (appState) {
                    case AppState.profileCreation:
                      return ProfileCreationParent(nextStep: openLoginScreen);
                    case AppState.login:
                      return LoginScreen(
                          onRegister: openProfileCreationScreen,
                          onLogin: openUserProfileScreen);
                    default:
                      return LoginScreen(
                          onRegister: openProfileCreationScreen,
                          onLogin: openUserProfileScreen);
                  }
                } else {
                  return Scaffold(
                    body: IndexedStack(
                      index: appState == AppState.userProfile
                          ? 0
                          : appState == AppState.conversation
                              ? 1
                              : 2,
                      children: [
                        UserProfileScreen(
                            userUuid: loggedInUser!.uuid,
                            logOut: openLoginScreen),
                        MessagingPage(
                          loggedInUser: loggedInUser!,
                        ),
                        SwipeUserParent(
                          currentUser: loggedInUser!,
                        ),
                      ],
                    ),
                    bottomNavigationBar: BottomNavigationBar(
                      currentIndex: appState == AppState.userProfile
                          ? 0
                          : appState == AppState.conversation
                              ? 1
                              : 2,
                      onTap: (index) {
                        if (index == 0) {
                          openUserProfileScreen(loggedInUser!);
                        } else if (index == 1) {
                          openConversationScreen();
                        } else {
                          openSwipeScreen();
                        }
                      },
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person),
                          label: 'Profile',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.message),
                          label: 'Messages',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.favorite),
                          label: 'Swipe',
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
