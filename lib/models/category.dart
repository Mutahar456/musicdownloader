import 'music.dart'; // Import the Music model

class Category {
  String name;
  String imageURL;
  List<Music> songs;

  Category(this.name, this.imageURL, this.songs);
}
