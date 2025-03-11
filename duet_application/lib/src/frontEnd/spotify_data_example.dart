


import 'package:duet_application/src/backend/spotifyUserData.dart';
import 'package:flutter/material.dart';


class SpotifyAuthWidget extends StatefulWidget {
  final String uuid;

  SpotifyAuthWidget({super.key, required this.uuid});

  @override
  _SpotifyAuthWidgetState createState() => _SpotifyAuthWidgetState();
}

class _SpotifyAuthWidgetState extends State<SpotifyAuthWidget> {
  bool _isLoading = false;
  SpotifyUserData? _spotifyUserData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Attempt to create the Spotify profile on app load.
    _attemptToGetUserProfile();
  }

  Future<void> _attemptToGetUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _spotifyUserData = await SpotifyUserData.createSpotifyProfile(widget.uuid);
      // After creating the profile, update user data (fetch top artists & saved tracks).
      await _spotifyUserData!.updateSpotifyData();
      setState(() {});
      debugPrint("Got Spotify user: ${_spotifyUserData!.username}");
    } catch (e) {
      print(e);
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshData() async {
    if (_spotifyUserData != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _spotifyUserData!.updateSpotifyData();
        setState(() {});
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleSignIn() async {
    await _attemptToGetUserProfile();
  }

  /// Builds a section to display the user's top artists.
  Widget _buildTopArtists() {
    if (_spotifyUserData?.favoriteArtists == null ||
        _spotifyUserData!.favoriteArtists!.isEmpty) {
      return Text("No top artists available. Try refreshing.");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Top Artists",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ..._spotifyUserData!.favoriteArtists!.map((artist) {
          String name = artist['name'] ?? 'Unknown';
          String imageUrl = "";
          if (artist['images'] != null &&
              artist['images'] is List &&
              artist['images'].isNotEmpty) {
            imageUrl = artist['images'][0]['url'] ?? "";
          }
          return ListTile(
            leading: imageUrl.isNotEmpty
                ? Image.network(imageUrl,
                    width: 50, height: 50, fit: BoxFit.cover)
                : SizedBox(width: 50, height: 50),
            title: Text(name),
          );
        }).toList(),
      ],
    );
  }

  /// Builds a section to display the user's saved tracks.
  Widget _buildSavedTracks() {
    if (_spotifyUserData?.favoriteTracks == null ||
        _spotifyUserData!.favoriteTracks!.isEmpty) {
      return Text("No saved tracks available. Try refreshing.");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Saved Tracks",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ..._spotifyUserData!.favoriteTracks!.map((item) {
          // Each item is expected to have a 'track' key.
          var track = item['track'];
          String trackName = track['name'] ?? 'Unknown';
          String artists = "";
          if (track['artists'] != null) {
            artists = (track['artists'] as List)
                .map((artist) => artist['name'])
                .join(", ");
          }
          String albumImageUrl = "";
          if (track['album'] != null &&
              track['album']['images'] != null &&
              track['album']['images'] is List &&
              track['album']['images'].isNotEmpty) {
            albumImageUrl = track['album']['images'][0]['url'] ?? "";
          }
          return ListTile(
            leading: albumImageUrl.isNotEmpty
                ? Image.network(albumImageUrl,
                    width: 50, height: 50, fit: BoxFit.cover)
                : SizedBox(width: 50, height: 50),
            title: Text(trackName),
            subtitle: Text(artists),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    // If user data is found, display profile details and fetched Spotify data.
    if (_spotifyUserData != null) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: ${_spotifyUserData!.username}',
                style: TextStyle(fontSize: 18)),
            Text('Email: ${_spotifyUserData!.email}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: Text('Refresh Spotify Data'),
            ),
            SizedBox(height: 20),
            _buildTopArtists(),
            SizedBox(height: 20),
            _buildSavedTracks(),
          ],
        ),
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_errorMessage != null) Text("Error: $_errorMessage"),
          ElevatedButton(
            onPressed: _handleSignIn,
            child: Text('Connect with Spotify'),
          ),
        ],
      ),
    );
  }
}