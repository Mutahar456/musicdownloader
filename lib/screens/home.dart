import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:musicdownloaders/screens/Video_Player_Screen.dart';
import 'package:musicdownloaders/screens/setting_page.dart'; // Import the SettingsPage

class Home extends StatefulWidget {
  final Function _miniPlayer;

  Home(this._miniPlayer);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isDarkTheme = true;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchDataFromAPI() async {
    final url = Uri.parse('https://youtube-v2.p.rapidapi.com/trending/');
    final headers = {
      'X-RapidAPI-Key': '0e5c7f9c21msh2abe22a023d60d8p1c80d7jsn0de3dc0d8b14',
      'X-RapidAPI-Host': 'youtube-v2.p.rapidapi.com',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> videoList = responseData['videos'] ?? [];
        final List<Map<String, dynamic>> shuffledList = videoList.cast<Map<String, dynamic>>();
        shuffledList.shuffle(Random());

        final int mid = (shuffledList.length / 2).floor();
        final List<Map<String, dynamic>> madeForYouList = shuffledList.sublist(0, mid);
        final List<Map<String, dynamic>> trendingSongsList = shuffledList.sublist(mid);

        return {
          'madeForYou': madeForYouList,
          'trendingSongs': trendingSongsList,
        };
      } else {
        throw Exception('Failed to load data from API. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data from API: $e');
      return {
        'madeForYou': [],
        'trendingSongs': [],
      };
    }
  }

  Future<String?> fetchAudioURL(String? audioId) async {
    if (audioId == null) return null;

    final url = Uri.parse('https://youtube-v2.p.rapidapi.com/audio/videos');
    final headers = {
      'X-RapidAPI-Key': '0e5c7f9c21msh2abe22a023d60d8p1c80d7jsn0de3dc0d8b14',
      'X-RapidAPI-Host': 'youtube-v2.p.rapidapi.com',
    };
    final params = {
      'audio_id': audioId,
    };

    try {
      final response = await http.get(url.replace(queryParameters: params), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final audioURL = responseData['audio_url'];
        print('Fetched audio URL: $audioURL');
        return audioURL as String?;
      } else {
        throw Exception('Failed to load audio URL from API. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching audio URL from API: $e');
      return null;
    }
  }

  void _playVideoFromURL(String? videoId) async {
    if (videoId == null) return;

    try {
      if (videoId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerPage(videoId: videoId),
          ),
        );
      } else {
        print("Failed to fetch video URL");
      }
    } catch (e, stackTrace) {
      print("Error playing video: $e");
      print(stackTrace);
    }
  }

  Widget createMusicThumbnail(Map<String, dynamic> videoData) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          final videoId = videoData['video_id'] as String?;
          if (videoId != null) {
            print('Thumbnail tapped, video ID: $videoId');
            _playVideoFromURL(videoId);
          } else {
            print('No video ID found for this video');
          }
        },
        child: Container(
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImage(videoData['thumbnails'][0]['url'] as String? ?? ''),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.play_circle_filled,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }


  Widget createMusicList(String label, List<Map<String, dynamic>> apiData) {
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _isDarkTheme ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: apiData.length,
              itemBuilder: (ctx, index) {
                final videoData = apiData[index];
                return createMusicThumbnail(videoData);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else if (hour < 20) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  // Fetch playlists data
  Future<List<Map<String, dynamic>>> fetchPlaylists() async {
    const url = 'https://soundcloud-scraper.p.rapidapi.com/v1/playlist/metadata';
    const headers = {
      'X-RapidAPI-Key': '0e5c7f9c21msh2abe22a023d60d8p1c80d7jsn0de3dc0d8b14',
      'X-RapidAPI-Host': 'soundcloud-scraper.p.rapidapi.com',
    };
    final params = {
      'playlist': 'https://soundcloud.com/edsheeran/sets/tour-edition-1',
    };
    try {
      final response = await http.get(Uri.parse(url).replace(queryParameters: params), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> playlistData = responseData['data'] ?? [];
        final List<Map<String, dynamic>> playlists = playlistData.cast<Map<String, dynamic>>();
        return playlists;
      } else {
        throw Exception('Failed to load playlist data from API. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching playlist data from API: $e');
      return [];
    }
  }

  Widget createPlaylistList(List<Map<String, dynamic>> playlists) {
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Playlists',
            style: TextStyle(
              color: _isDarkTheme ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: playlists.length,
              itemBuilder: (ctx, index) {
                final playlistData = playlists[index];
                return createPlaylistThumbnail(playlistData);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget createPlaylistThumbnail(Map<String, dynamic> playlistData) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          // Handle playlist tap
        },
        child: Container(
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImage(playlistData['thumbnail'] as String? ?? ''),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Text(
              playlistData['title'] as String? ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        backgroundColor: _isDarkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.settings),
            color: _isDarkTheme ? Colors.white : Colors.black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(onTextStyleChanged: (TextStyle) {}),
                ),
              );
            },
          ),
          title: Text(
            _getGreetingMessage(),
            style: TextStyle(
              color: _isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            Switch(
              value: _isDarkTheme,
              onChanged: (value) {
                setState(() {
                  _isDarkTheme = value;
                });
              },
              activeColor: Colors.white,
              inactiveThumbColor: Colors.black,
              inactiveTrackColor: Colors.grey,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: [
                      _createCategoryButton('Today\'s Top Hits'),
                      _createCategoryButton('Dope Labs'),
                      _createCategoryButton('Latina to Latina'),
                      _createCategoryButton('Alan Gogoll'),
                      _createCategoryButton('Chill Hits'),
                      _createCategoryButton('Small Doses with Amanda Seales'),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: fetchDataFromAPI(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final apiData = snapshot.data as Map<String, List<Map<String, dynamic>>>;
                      final madeForYouData = apiData['madeForYou']!;
                      final trendingSongsData = apiData['trendingSongs']!;
                      return Column(
                        children: [
                          createMusicList('Made For You', madeForYouData),
                          createMusicList('Trending Songs', trendingSongsData),
                        ],
                      );
                    }
                  },
                ),
                FutureBuilder(
                  future: fetchPlaylists(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final playlists = snapshot.data as List<Map<String, dynamic>>;
                      return createPlaylistList(playlists);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createCategoryButton(String text) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _isDarkTheme ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

void main() {
  runApp(Home((music, {stop = false}) {}));
}

