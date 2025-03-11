import 'dart:async';
import 'dart:convert';
// import 'dart:html' as html; // Use dart:html for redirection on web

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duet_application/src/backend/firestore_instance.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

enum MusicGenre {
  Pop,
  Rock,
  HipHop,
  Jazz,
  Classical,
  Electronic,
  Country,
  Reggae,
  Blues,
  Metal,
}


class SpotifyUserData {
  final String uuid;
  String username;
  String email;
  String accessToken;
  // In the implicit flow no refresh token is provided.
  String refreshToken;
  List<dynamic> favoriteArtists;
  List<dynamic> favoriteTracks;
  Set<String> favoriteGenres;

  SpotifyUserData({
    required this.uuid,
    this.accessToken = '',
    this.refreshToken = '',
    this.username = '',
    this.email = '',
    favoriteArtists,
    favoriteTracks,
    favoriteGenres,
  })  : favoriteArtists = favoriteArtists ?? [],
        favoriteTracks = favoriteTracks ?? [],
        favoriteGenres = favoriteGenres ?? {};

  static final String _clientId = dotenv.env['CLIENT_ID']!;
  // In your web app you MUST not expose a client secret.
  static final String _redirectUri = dotenv.env['REDIRECT_URI']!;
  static final String _spotifyAuthUrl = 'https://accounts.spotify.com/authorize';
  static final String _spotifyApiUrl = 'https://api.spotify.com/v1';

  /// Creates a new Spotify profile by performing authentication and saving the user profile.
  static Future<SpotifyUserData> createSpotifyProfile(String uuid) async {
    final user = await connectWithSpotify(uuid);
    await user.save();
    return user;
  }

  /// Initiates Spotify authentication using the Implicit Grant Flow.
  ///
  /// If the URL contains an access token (in the fragment), it will use that;
  /// otherwise, it redirects the user to Spotify's authentication page.
  static Future<SpotifyUserData> connectWithSpotify(String uuid) async {
    final currentUri = Uri.parse(html.window.location.href);

    if (currentUri.fragment.isNotEmpty) {
      // Parse the URL fragment (after the '#' symbol) to get the access token.
      final params = Uri.splitQueryString(currentUri.fragment);
      final token = params['access_token'];
      if (token == null) {
        throw Exception("Access token not found in URL.");
      }
      // Clean the URL in the address bar so the token isn’t visible.
      final cleanUrl = currentUri.toString().split('#')[0];
      html.window.history.replaceState(null, 'Spotify Auth', cleanUrl);

      final user = SpotifyUserData(
        uuid: uuid,
        accessToken: token,
        refreshToken: '', // Not available using implicit flow.
        username: '',
        email: '',
      );
      await user.fetchUserData();
      await user.save();
      return user;
    } else {
      // No token available; construct the auth URL and redirect the user.
      final authUrl = '$_spotifyAuthUrl?'
          'response_type=token'
          '&client_id=$_clientId'
          '&redirect_uri=${Uri.encodeComponent(_redirectUri)}'
          '&scope=${Uri.encodeComponent("user-top-read user-library-read user-read-email user-read-private")}';
      html.window.location.assign(authUrl);

      // Since we are redirecting, return a Future that never completes.
      final completer = Completer<SpotifyUserData>();
      return completer.future;
    }
  }

  /// Updates Spotify data by refetching the user’s profile, top artists, and saved tracks.
  /// (In the implicit flow, if the token expires you will need to re-authenticate.)
  Future<void> updateSpotifyData() async {
    await fetchUserData();
    await fetchArtists();
    await fetchLibrary();
    await save();
  }

  /// Fetches the Spotify user profile (display name and email).
  Future<void> fetchUserData() async {
    final response = await _spotifyRequest('$_spotifyApiUrl/me');
    username = response['display_name'] ?? 'Unknown';
    email = response['email'] ?? 'Unknown';
  }

  /// Fetches the user’s top artists.
  Future<List<dynamic>> fetchArtists({int limit = 20}) async {
    final response =
        await _spotifyRequest('$_spotifyApiUrl/me/top/artists?limit=$limit');
    favoriteArtists = response['items'] != null ? List<dynamic>.from(response['items']) : [];
    return favoriteArtists ?? [];
  }

  /// Fetches the user’s saved tracks.
  Future<List<dynamic>> fetchLibrary({int limit = 20}) async {
    final response =
        await _spotifyRequest('$_spotifyApiUrl/me/tracks?limit=$limit');
    favoriteTracks = response['items'] != null ? List<dynamic>.from(response['items']) : [];
    return favoriteTracks ?? [];
  }

  /// Makes an authenticated request to the Spotify API.
  Future<dynamic> _spotifyRequest(String url) async {
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 401) {
      // In implicit flow, token expiration can only be resolved by reauthentication.
      throw Exception("Access token expired or unauthorized.");
    }
    return jsonDecode(response.body);
  }

  /// Saves the current user data to Firestore.
  Future<void> save() async {
    await firestoreInstance!.instance
        .collection('spotify_users')
        .doc(uuid)
        .set(toMap());
  }

  Map<String, dynamic> toMap() => {
        'uuid': uuid,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'username': username,
        'email': email,
        'favoriteArtists': favoriteArtists,
        'favoriteTracks': favoriteTracks,
        'favoriteGenres': favoriteGenres?.toList(),
      };

  factory SpotifyUserData.fromMap(Map<String, dynamic> data) => SpotifyUserData(
        uuid: data['uuid'] ?? '',
        username: data['username'] ?? '',
        email: data['email'] ?? '',
        accessToken: data['accessToken'] ?? '',
        refreshToken: data['refreshToken'] ?? '',
        favoriteArtists: data['favoriteArtists'] != null
            ? List<dynamic>.from(data['favoriteArtists'])
            : null,
        favoriteTracks: data['favoriteTracks'] != null
            ? List<dynamic>.from(data['favoriteTracks'])
            : null,
        favoriteGenres: data['favoriteGenres'] != null
            ? Set<String>.from(data['favoriteGenres'])
            : null,
      );

  static Future<SpotifyUserData?> fromFirestore(String uuid) async {
    final doc = await firestoreInstance!.instance
        .collection('spotify_users')
        .doc(uuid)
        .get();
    if (!doc.exists) return null;
    return SpotifyUserData.fromMap(doc.data()!);
  }
}

