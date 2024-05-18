import 'package:flutter/material.dart';
import 'package:youtube_api/youtube_api.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  static String key =
      'YOUR_YOUTUBE_API_KEY_HERE'; // Replace with your actual API key
  YoutubeAPI ytApi = YoutubeAPI(key);
  List<YouTubeVideo> videoResult = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Uncomment the line below if you want to perform a default search when the widget initializes
    // performSearch('Flutter');
  }

  Future<void> performSearch(String query) async {
    try {
      List<YouTubeVideo>? result = await ytApi.search(query);

      if (result != null) {
        setState(() {
          videoResult = result;
        });
      } else {
        print('No search results found.');
      }
    } catch (e) {
      print('Error fetching data: $e');
      if (e is FormatException) {
        print('There was an issue parsing the response data.');
      } else {
        print('An unknown error occurred.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      String query = _searchController.text.trim();
                      performSearch(query);
                    },
                  ),
                ),
                onSubmitted: (value) {
                  String query = _searchController.text.trim();
                  performSearch(query);
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: videoResult.length,
                itemBuilder: (context, index) {
                  YouTubeVideo video = videoResult[index];
                  return ListTile(
                    title: Text(video.title),
                    subtitle: Text(video.channelTitle),
                    onTap: () {
                      // Handle tapping on the video
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
