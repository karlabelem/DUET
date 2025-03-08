import 'package:flutter/material.dart';
import 'package:duet_application/src/backend/spotifyUserData.dart';

class ProfileCreationStep4 extends StatefulWidget {
  const ProfileCreationStep4({super.key, required this.nextStep});
  final Function nextStep;

  @override
  State<ProfileCreationStep4> createState() => _ProfileCreationStep4State();
}

class _ProfileCreationStep4State extends State<ProfileCreationStep4> {
  Set<MusicGenre> _selectedGenres = {};

  Set<dynamic> getSelectedGenresAsDynamic() {
    return _selectedGenres.map((genre) => genre.toString().split('.').last).toSet();
  }

  void _navigateAndSelectGenres(BuildContext context) async {
    final selectedGenres = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectMusicGenres()),
    );
    if (selectedGenres != null) {
      setState(() {
        _selectedGenres = Set<MusicGenre>.from(selectedGenres);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0CFF2),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose your favorite music genres",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                "Step 4 of 4",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  minimumSize: Size(double.infinity, 48.0),
                ),
                onPressed: () {
                  _navigateAndSelectGenres(context);
                },
                child: Text(
                  "Select Music Genres",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  minimumSize: Size(double.infinity, 48.0),
                ),
                onPressed: () {
                  widget.nextStep({'genres': getSelectedGenresAsDynamic()});
                },
                child: Text(
                  "Next",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16.0),
              Wrap(
                spacing: 8.0,
                children: _selectedGenres
                    .map((genre) => Chip(label: Text(genre.toString().split('.').last)))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectMusicGenres extends StatefulWidget {
  const SelectMusicGenres({super.key});

  @override
  State<SelectMusicGenres> createState() => _SelectMusicGenresState();
}

class _SelectMusicGenresState extends State<SelectMusicGenres> {
  final List<MusicGenre> _selectedGenres = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Music Genres'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _selectedGenres);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: MusicGenre.values.length,
              itemBuilder: (context, index) {
                final genre = MusicGenre.values[index];
                final isSelected = _selectedGenres.contains(genre);
                return ListTile(
                  title: Text(genre.toString().split('.').last),
                  trailing: isSelected
                      ? Icon(Icons.check_box, color: Colors.green)
                      : Icon(Icons.check_box_outline_blank),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedGenres.remove(genre);
                      } else if (_selectedGenres.length < 5) {
                        _selectedGenres.add(genre);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Genres:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8.0,
                  children: _selectedGenres
                      .map((genre) => Chip(label: Text(genre.toString().split('.').last)))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
