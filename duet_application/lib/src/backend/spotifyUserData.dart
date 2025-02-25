import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:async';
import 'userProfile.dart';
import 'firestore_instance.dart';

enum MusicGenre {
  rock,
  pop,
  jazz,
  classical,
  hipHop,
  electronic,
  country,
  reggae,
  blues,
  metal,
  folk,
  punk,
  soul,
  rnb,
  latin,
  disco,
  funk,
  techno,
  house,
  trance,
  dubstep,
  drumAndBass,
  ambient,
  indie,
  alternative,
  kpop,
  jpop,
  cpop,
  world,
  soundtrack,
}

class SpotifyUserData {
  static const String _clientId = '4dbf19a959ff4c3bb0992c29ce581668'; // String.fromEnvironment('SPOTIFY_CLIENT_ID')
  static const String _clientSecret = 'e4fa3a54db064be3bdae30d26bb33b12'; // String.fromEnvironment('SPOTIFY_CLIENT_SECRET')
  static const String _redirectUri = 'http://localhost:8080/callback'; // Web redirect URI EDIT THIS TO OUR OWN
  static const String _spotifyAuthUrl = 'https://accounts.spotify.com/authorize';
  static const String _spotifyTokenUrl = 'https://accounts.spotify.com/api/token';
  static const String _spotifyApiUrl = 'https://api.spotify.com/v1';

  final String uuid;
  String? username;
  String? email;
  String? accessToken;
  String? refreshToken;
  Set<dynamic>? favoriteArtists; // IDK if we should limit these data structures
  Set<dynamic>? favoriteTracks;
  Set<String>? favoriteGenres;

 SpotifyUserData({
    required this.uuid,
    this.accessToken,
    this.refreshToken,
    this.username,
    this.email,
    Set<dynamic>? favoriteArtists,
    Set<dynamic>? favoriteTracks,
    Set<String>? favoriteGenres,
  })  : favoriteArtists = favoriteArtists ?? {},
        favoriteTracks = favoriteTracks ?? {},
        favoriteGenres = favoriteGenres ?? {};

  // Create and store a new Spotify profile in Firestore.
  static Future<SpotifyUserData> createSpotifyProfile(String uuid) async {
    final user = await SpotifyUserData.connectWithSpotify(uuid);
    await user.save(); // Save user data in Firestore
    return user;
  }

  // Update the stored Spotify data when the user logs in.
  Future<void> updateSpotifyData() async {
    await refreshAccessToken(); // Ensure token is up-to-date
    await fetchUserData(); // Get latest user details
    favoriteArtists = await fetchArtists(); // Get top artists
    favoriteTracks = await fetchLibrary(); // Get saved tracks
    favoriteGenres = await fetchGenre(); // Get favorite genres
    await save(); // Save updated data in Firestore
  }

  // Get user data from Firestore
  static Future<SpotifyUserData?> get(String uuid) async {
    final doc = await firestoreInstance!.instance
        .collection('spotify_users')
        .doc(uuid)
        .get();
    if (!doc.exists) throw Exception('User not found in Firestore');
    return SpotifyUserData.fromMap(doc.data()!);
  }

  // // Connect with Spotify OAuth
  // static Future<SpotifyUserData> connectWithSpotify(String uuid) async {
  //   final authUrl = '$_spotifyAuthUrl?response_type=code&client_id=$_clientId'
  //       '&redirect_uri=${Uri.encodeComponent(_redirectUri)}'
  //       '&scope=${Uri.encodeComponent("user-top-read user-library-read user-read-email user-read-private")}';

  //   final result = await FlutterWebAuth.authenticate(
  //     url: authUrl,
  //     callbackUrlScheme: "yourapp",
  //   );

  //   final code = Uri.parse(result).queryParameters['code'];
  //   if (code == null) throw Exception('Authorization code not found');

  //   final tokenResponse = await http.post(
  //     Uri.parse(_spotifyTokenUrl),
  //     headers: {
  //       'Authorization': 'Basic ${base64Encode(utf8.encode('$_clientId:$_clientSecret'))}',
  //       'Content-Type': 'application/x-www-form-urlencoded',
  //     },
  //     body: {
  //       'grant_type': 'authorization_code',
  //       'code': code,
  //       'redirect_uri': _redirectUri,
  //     },
  //   );

  //   if (tokenResponse.statusCode != 200) {
  //     throw Exception('Failed to get token: ${tokenResponse.body}');
  //   }

  //   final tokenData = jsonDecode(tokenResponse.body);
  //   final user = SpotifyUserData(
  //     uuid: uuid,
  //     accessToken: tokenData['access_token'],
  //     refreshToken: tokenData['refresh_token'],
  //   );

  //   await user.fetchUserData();
  //   return user;
  // }
  
  // Connect with Spotify OAuth flow (web-only)
  static Future<SpotifyUserData> connectWithSpotify(String uuid) async {
    try {
      // Build the authorization URL
      final authUrl =
          '$_spotifyAuthUrl?response_type=code&client_id=$_clientId'
          '&redirect_uri=${Uri.encodeComponent(_redirectUri)}'
          '&scope=${Uri.encodeComponent("user-top-read user-library-read user-read-email user-read-private")}';

      // Redirect the browser to Spotify's auth page
      html.window.location.href = authUrl;

      // Wait for the callback and get the authorization code
      final code = await _getAuthorizationCode();
      if (code == null) throw Exception('Authorization code not found');

      // Exchange code for tokens
      final tokenResponse = await http.post(
        Uri.parse(_spotifyTokenUrl),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_clientId:$_clientSecret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': _redirectUri,
        },
      );

      if (tokenResponse.statusCode != 200) {
        throw Exception('Failed to get token: ${tokenResponse.body}');
      }

      final tokenData = jsonDecode(tokenResponse.body);
      final user = SpotifyUserData(
        uuid: uuid,
        accessToken: tokenData['access_token'],
        refreshToken: tokenData['refresh_token'],
      );

      await user.fetchUserData();
      return user;
    } catch (e) {
      throw Exception('Spotify authentication failed: $e');
    }
  }

  // Handle the authorization code callback
  static Future<String?> _getAuthorizationCode() async {
    final completer = Completer<String?>();

    // Check if we're already on the callback URL
    final currentUrl = html.window.location.href;
    final uri = Uri.parse(currentUrl);
    if (uri.queryParameters.containsKey('code')) {
      completer.complete(uri.queryParameters['code']);
    } else if (uri.queryParameters.containsKey('error')) {
      completer.completeError(Exception('OAuth error: ${uri.queryParameters['error']}'));
    } else {
      // Listen for URL changes (e.g., after redirect)
      html.window.onPopState.listen((event) {
        final newUrl = html.window.location.href;
        final newUri = Uri.parse(newUrl);
        if (newUri.queryParameters.containsKey('code')) {
          completer.complete(newUri.queryParameters['code']);
        } else if (newUri.queryParameters.containsKey('error')) {
          completer.completeError(Exception('OAuth error: ${newUri.queryParameters['error']}'));
        }
      });
    }

    return completer.future.timeout(Duration(minutes: 5), onTimeout: () {
      throw Exception('Authorization timed out');
    });
  }

  // Refresh access token
  Future<void> refreshAccessToken() async {
    if (refreshToken == null) throw Exception('No refresh token available');
    try {
      final response = await http.post(
        Uri.parse(_spotifyTokenUrl),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_clientId:$_clientSecret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken!,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to refresh token: ${response.body}');
      }

      final data = jsonDecode(response.body);
      accessToken = data['access_token'];
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }

  // Fetch user profile data
  Future<void> fetchUserData() async {
    final response = await _spotifyRequest('$_spotifyApiUrl/me');
    username = response['display_name'] ?? 'Unknown';
    email = response['email'] ?? 'Unknown';
  }

  // Fetch top artists
  Future<Set<dynamic>> fetchArtists({int limit = 20}) async {
    final response = await _spotifyRequest(
      '$_spotifyApiUrl/me/top/artists?limit=$limit',
    );
    favoriteArtists = response['items'];
    return favoriteArtists!;
  }

  // Fetch user's library (saved tracks)
  Future<Set<dynamic>> fetchLibrary({int limit = 20}) async {
    final response = await _spotifyRequest(
      '$_spotifyApiUrl/me/tracks?limit=$limit',
    );
    return response['items'];
  }

  // Fetch specific songs
  Future<List<dynamic>> fetchSongs(List<String> trackIds) async {
    final response = await _spotifyRequest(
      '$_spotifyApiUrl/tracks?ids=${trackIds.join(',')}',
    );
    return response['tracks'];
  }

  // Fetch saved albums
  Future<List<dynamic>> fetchAlbums({int limit = 20}) async {
    final response = await _spotifyRequest(
      '$_spotifyApiUrl/me/albums?limit=$limit',
    );
    return response['items'];
  }

  // Fetch genre based on top artists
  Future<Set<String>> fetchGenre() async {
    final artists = await fetchArtists();
    final genres = <String>{};  
    for (final artist in artists) {
      genres.addAll((artist['genres'] as List).cast<String>());
    }
    return genres.toSet();
  }

  // Helper method for Spotify API requests
  Future<dynamic> _spotifyRequest(String url) async {
    if (accessToken == null) throw Exception('No access token available');
    var response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 401) {
      await refreshAccessToken();
      response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    }

    if (response.statusCode != 200) {
      throw Exception('Spotify API request failed: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'username': username,
      'email': email,
      'favoriteArtists': favoriteArtists,
      'favoriteTracks': favoriteTracks,
      'favoriteGenres': favoriteGenres,
    };
  }

  // Create from Firestore data
  factory SpotifyUserData.fromMap(Map<String, dynamic> data) {
    return SpotifyUserData(
      uuid: data['uuid'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      accessToken: data['accessToken'] ?? '',
      refreshToken: data['refreshToken'] ?? '',
      favoriteArtists: data['favoriteArtists'] != null
          ? Set<dynamic>.from(data['favoriteArtists'])
          : null,
      favoriteTracks: data['favoriteTracks'] != null
          ? Set<dynamic>.from(data['favoriteTracks'])
          : null,
    );
  }

  // Save to Firestore
  Future<void> save() async {
    await firestoreInstance!.instance
        .collection('spotify_users')
        .doc(uuid)
        .set(toMap());
  }

  List<Map<String, dynamic>> getFavoriteGenres() {
    // Fetch the favorite genres from Firestore or any other source
    // Here, we assume that the genres are stored in the 'favoriteGenres' field
    return favoriteGenres!.map((genre) => {'name': genre}).toList();
  }
}

