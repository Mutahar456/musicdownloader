import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:musicdownloaders/models/category.dart';
import 'package:musicdownloaders/models/music.dart';
import 'package:musicdownloaders/services/music_operations.dart';
import '../services/catergory_operations.dart';

class Home extends StatefulWidget {
  final Function _miniPlayer;

  Home(this._miniPlayer);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  Music? _currentMusic;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playPauseMusic(Music music) async {
    if (music == null) {
      print("Music not found");
      return; // Exit the method if music is null
    }

    print("Audio Url: ${music.audioURL}");

    try {
      if (_isPlaying && _currentMusic == music) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        await _audioPlayer.play(UrlSource(music.audioURL)); // Play the audio
        setState(() {
          _isPlaying = true;
          _currentMusic = music;
        });
      }
    } catch (e, stackTrace) {
      print("Error playing audio: $e");
      print(stackTrace);
    }

    // Notify mini player widget about the current state
    widget._miniPlayer(music, stop: !_isPlaying);
  }

  // Widget to create a single category card
  Widget createCategory(Category category) {
    return Container(
      color: Colors.blueGrey.shade400,
      child: Row(
        children: [
          Image.network(category.imageURL, fit: BoxFit.cover),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              category.name,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Function to create a list of category widgets
  List<Widget> createListOfCategories() {
    List<Category> categoryList = CategoryOperations.getCategories();
    return categoryList.map((category) => createCategory(category)).toList();
  }

  // Widget to create a single music card
  Widget createMusic(Music music) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: 200,
            child: InkWell(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    music.image,
                    fit: BoxFit.cover,
                  ),
                  IconButton(
                    icon: _currentMusic == music && _isPlaying
                        ? Icon(Icons.pause_circle_filled)
                        : Icon(Icons.play_circle_filled),
                    onPressed: () {
                      _playPauseMusic(music);
                    },
                  ),
                ],
              ),
            ),
          ),
          Text(
            music.name,
            style: TextStyle(color: Colors.white),
          ),
          Text(
            music.desc,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }


  // Function to create a horizontal list of music cards
  Widget createMusicList(String label) {
    List<Music> musicList = MusicOperations.getMusic();
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: musicList.length,
              itemBuilder: (ctx, index) {
                return createMusic(musicList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget to create a grid of categories
  Widget createGrid() {
    return Container(
      padding: EdgeInsets.all(10),
      height: 280,
      child: GridView.count(
        childAspectRatio: 5 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        children: createListOfCategories(),
      ),
    );
  }

  // Widget to create an AppBar with a given title
  Widget createAppBar(String message) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      title: Text(message),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: Icon(Icons.settings),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade300, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.1, 0.3],
            ),
          ),
          child: Column(
            children: [
              createAppBar('Music'),
              SizedBox(height: 10),
              createGrid(),
              SizedBox(height: 10),
              createMusicList('Made for you'),
              createMusicList('Popular playlists'),
            ],
          ),
        ),
      ),
    );
  }
}
