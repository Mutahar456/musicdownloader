import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart'; // Add this import
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _videoResult = [];
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;
  bool _isPlaying = false;
  String? _currentStreamUrl;
  double _downloadProgress = 0.0;
  bool _downloading = false;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsDarwin = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsDarwin);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _searchMusic(String query) async {
    setState(() {
      _isLoading = true;
    });

    final url = 'https://youtube-music6.p.rapidapi.com/ytmusic/?query=$query';
    final headers = {
      'X-RapidAPI-Key': '664a4529dcmshb4d445b999cfe83p1a7680jsna3e6433efbef',
      'X-RapidAPI-Host': 'youtube-music6.p.rapidapi.com'
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response: $data'); // Print the JSON response to understand its structure

        setState(() {
          _videoResult = data ?? [];
        });

        print('Video result stored successfully: $_videoResult');
      } else {
        setState(() {
          _videoResult = [];
        });
        print('Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      setState(() {
        _videoResult = [];
      });
      print('Error: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadFile(String videoUrl, String fileName, BuildContext context, int index) async {
    setState(() {
      _videoResult[index]['isDownloading'] = true;
      _downloading = true;
      _downloadProgress = 0.0;
      _cancelToken = CancelToken();
    });

    final storageStatus = await Permission.storage.request();
    if (!storageStatus.isGranted) {
      print('Permission denied');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Permission required'),
            content: Text('This app needs storage permission to download files.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
              ),
            ],
          );
        },
      );
      setState(() {
        _videoResult[index]['isDownloading'] = false;
        _downloading = false;
      });
      return;
    }

    final directory = await getExternalStorageDirectory();
    final downloadDirectory = Directory('/storage/emulated/0/Download');
    if (!(await downloadDirectory.exists())) {
      await downloadDirectory.create(recursive: true);
    }

    final finalVideoPath = join(downloadDirectory.path, '$fileName.mp3');

    try {
      final url = 'https://youtube-mp3-downloader2.p.rapidapi.com/ytmp3/ytmp3/';
      final headers = {
        'X-RapidAPI-Key': 'aa24b6fb09msha2e0d754d3bfb53p1d02ccjsneb10ebabd44e',
        'X-RapidAPI-Host': 'youtube-mp3-downloader2.p.rapidapi.com'
      };
      final params = {'url': videoUrl};

      final response = await http.get(Uri.parse(url).replace(queryParameters: params), headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final downloadUrl = jsonResponse['dlink'];
        print(downloadUrl);

        if (downloadUrl == null) {
          throw Exception('Download URL is null');
        }

        Dio dio = Dio();

        await dio.download(
          downloadUrl,
          finalVideoPath,
          onReceiveProgress: (received, total) {
            setState(() {
              _downloadProgress = received / total;
            });
          },
          cancelToken: _cancelToken, // Use cancel token for download cancellation
        );

        print('File downloaded to: $finalVideoPath');
        _showNotification(fileName);
      } else {
        throw Exception('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        print('Download canceled');
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Download Error'),
              content: Text(e.toString()),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } finally {
      setState(() {
        _videoResult[index]['isDownloading'] = false;
        _downloading = false;
        _cancelToken = null;
      });
    }
  }

  Future<void> _showNotification(String fileName) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'download_channel',
        'Downloads',
        channelDescription: 'Channel for download notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false
    );
    var darwinPlatformChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: darwinPlatformChannelSpecifics
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'Download Complete',
      '$fileName has been downloaded successfully',
      platformChannelSpecifics,
      payload: 'Download complete',
    );
  }

  void _cancelDownload() {
    _cancelToken?.cancel();
  }

  void _initiateDownload(String videoId, String title, BuildContext context, int index) async {
    final storageStatus = await Permission.storage.status;

    if (storageStatus.isGranted) {
      _downloadFile(videoId, title, context, index);
    } else {
      final result = await Permission.storage.request();
      if (result.isGranted) {
        _downloadFile(videoId, title, context, index);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Permission Denied'),
              content: Text('Storage permission is required to download files. Please enable it from settings.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<Directory> getAppDocDirectory() async {
    if (Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    }
    return (await getExternalStorageDirectory())!;
  }

  Future<void> _saveSearchHistory(String query) async {
    print(query);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('searchHistory') ?? [];
    if (!history.contains(query)) {
      // Add new query to history if it's not already there
      history.add(query);
      await prefs.setStringList('searchHistory', history);
      print('Search history saved: $history');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search",
          style: TextStyle(color: Colors.white), // Setting text color to white
        ),
        backgroundColor: Colors.black, // Setting app bar background color to black
      ),
      backgroundColor: Colors.blueGrey.shade300,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.black87, // Setting search bar background color to dark gray
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search, color: Colors.white),
                          onPressed: () {
                            _searchMusic(_searchController.text);
                            _saveSearchHistory(_searchController.text);
                          },
                        ),
                      ),
                      onSubmitted: (_) {
                        _searchMusic(_searchController.text);
                        _saveSearchHistory(_searchController.text);
                      },
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _videoResult.length,
                  itemBuilder: (context, index) {
                    final video = _videoResult[index];
                    final title = video['title'] ?? 'No title';
                    final artists = (video['artists'] as List?)
                        ?.map((artist) => artist['name'] as String?)
                        .where((name) => name != null)
                        .join(', ') ?? 'Unknown artist';
                    final thumbnails = video['thumbnails'] as List?;
                    final thumbnailUrl = thumbnails != null && thumbnails.isNotEmpty
                        ? thumbnails[0]['url'] as String? ?? ''
                        : '';
                    final videoId = video['videoId'] as String?;
                    final isLoading = video['isLoading'] as bool? ?? false;

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      padding: EdgeInsets.all(8.0),
                      color: Colors.black87, // Setting item background color to dark gray
                      child: ListTile(
                        leading: thumbnailUrl.isNotEmpty
                            ? Image.network(
                          thumbnailUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                            : SizedBox(width: 80, height: 80), // Fixed width and height for thumbnail
                        title: Text(
                          title,
                          style: TextStyle(color: Colors.white),
                          maxLines: 2, // Maximum 2 lines for title
                          overflow: TextOverflow.ellipsis, // Overflow ellipsis for long titles
                        ),
                        subtitle: Text(
                          artists,
                          style: TextStyle(color: Colors.white),
                          maxLines: 1, // Maximum 1 line for artists
                          overflow: TextOverflow.ellipsis, // Overflow ellipsis for long artists names
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            isLoading
                                ? CircularProgressIndicator()
                                : IconButton(
                              icon: Icon(
                                _isPlaying && _currentStreamUrl == videoId
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                if (videoId == null) {
                                  print('Error: videoId is null');
                                  return;
                                }

                                if (_isPlaying && _currentStreamUrl == videoId) {
                                  await _audioPlayer.pause();
                                  setState(() {
                                    _isPlaying = false;
                                  });
                                } else {
                                  setState(() {
                                    _videoResult[index]['isLoading'] = true;
                                  });
                                  final streamUrl = await _getStreamUrl(videoId);
                                  if (streamUrl != null) {
                                    await _audioPlayer.play(UrlSource(streamUrl));
                                    setState(() {
                                      _isPlaying = true;
                                      _currentStreamUrl = videoId;
                                      _videoResult[index]['isLoading'] = false;
                                    });
                                  } else {
                                    print('Error: Stream URL is null');
                                  }
                                }
                              },
                            ),
                            _videoResult[index]['isDownloading'] == true
                                ? IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                              onPressed: _cancelDownload,
                            )
                                : IconButton(
                              icon: Icon(
                                Icons.download,
                                color: _downloading ? Colors.grey : Colors.white,
                              ),
                              onPressed: _downloading
                                  ? null
                                  : () {
                                if (videoId != null) {
                                  _initiateDownload(videoId, title, context, index);
                                } else {
                                  print('Error: videoId is null');
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () async {
                          if (videoId != null) {
                            final streamUrl = await _getStreamUrl(videoId);
                            if (streamUrl != null) {
                              await _audioPlayer.play(UrlSource(streamUrl));
                              setState(() {
                                _isPlaying = true;
                                _currentStreamUrl = videoId;
                              });
                            } else {
                              print('Error: Stream URL is null');
                            }
                          } else {
                            print('Error: videoId is null');
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomSheet: _buildMusicPlayer(),
    );
  }

  Widget _buildMusicPlayer() {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (_isPlaying) {
                    _audioPlayer.pause();
                  } else {
                    // Resume playing
                    _audioPlayer.resume();
                  }
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  _currentStreamUrl ?? 'No song playing',
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (_downloading)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _downloadProgress,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Downloading: ${(_downloadProgress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: _cancelDownload,
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<String?> _getStreamUrl(String? videoId) async {
    if (videoId == null) {
      print('Error: videoId is null');
      return null;
    }

    try {
      var yt = YoutubeExplode();
      var video = await yt.videos.get(videoId);
      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var audioStreamInfo = manifest.audioOnly.withHighestBitrate();
      var streamUrl = audioStreamInfo.url.toString();
      yt.close();
      return streamUrl;
    } catch (e) {
      print('Error fetching stream URL: $e');
      return null;
    }
  }
}
