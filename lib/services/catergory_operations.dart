import 'package:musicdownloaders/models/category.dart';
import 'package:musicdownloaders/models/music.dart';

class CategoryOperations {
  CategoryOperations._() {}

  static List<Category> getCategories() {
    return <Category>[
      Category(
        'Top Songs',
        'https://is1-ssl.mzstatic.com/image/thumb/Purple123/v4/0e/09/c4/0e09c462-c0cd-0a6c-d748-ea69b70442b7/source/256x256bb.jpg',
        [
          Music('Song 1', 'https://example.com/image1.jpg', 'Description 1', 'https://example.com/audio1.mp3'),
          Music('Song 2', 'https://example.com/image2.jpg', 'Description 2', 'https://example.com/audio2.mp3'),
          // Add more songs
        ],
      ),
      Category(
        'MJ Hits',
        'https://is1-ssl.mzstatic.com/image/thumb/Purple71/v4/d1/ba/85/d1ba8582-972e-7e02-6f3b-cc47adfc055f/source/256x256bb.jpg',
        [
          Music('Beat It', 'https://example.com/image3.jpg', 'Description 3', 'https://example.com/audio3.mp3'),
          Music('Billie Jean', 'https://example.com/image4.jpg', 'Description 4', 'https://example.com/audio4.mp3'),
          // Add more songs
        ],
      ),
      Category(
        'Smile',
        'https://c-cl.cdn.smule.com/rs-s78/arr/30/d7/5a82d9ae-9589-443c-b950-25c139abae89_256.jpg',
        [
          Music('Smile Song 1', 'https://example.com/image5.jpg', 'Description 5', 'https://example.com/audio5.mp3'),
          Music('Smile Song 2', 'https://example.com/image6.jpg', 'Description 6', 'https://example.com/audio6.mp3'),
          // Add more songs
        ],
      ),
      // Add more categories with songs
    ];
  }
}
