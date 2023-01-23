import 'video_item_partial.dart';

class Playlist {
  Playlist.fromJson(Map<String, dynamic> obj)
      : id = obj['id'] as String,
        title = obj['title'] as String,
        author = obj['author'] as String {
    items = (obj['items'] as List<dynamic>)
        .map<VideoItemPartial>(
          (dynamic o) => VideoItemPartial.fromJson(o as Map<String, dynamic>),
        )
        .toList();
  }

  final String id;
  final String title;
  final String author;
  late List<VideoItemPartial> items;
}
