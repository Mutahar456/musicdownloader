import 'package:flutter/material.dart';
import 'package:musicdownloaders/models/category.dart';
import 'category.dart';
import 'package:musicdownloaders/models/music.dart';

class SongListScreen extends StatelessWidget {
  final Category category;

  SongListScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${category.name} Songs')),
      body: ListView.builder(
        itemCount: category.songs.length,
        itemBuilder: (ctx, index) {
          var song = category.songs[index];
          return ListTile(
            leading: Image.network(song.image, width: 50, height: 50, fit: BoxFit.cover),
            title: Text(song.name),
            subtitle: Text(song.desc),
            onTap: () {
              // Handle song tap, e.g., play the song or show song details.
            },
          );
        },
      ),
    );
  }
}
