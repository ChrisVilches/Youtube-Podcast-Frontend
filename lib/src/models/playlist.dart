import 'video_item_partial.dart';

List<VideoItemPartial> _parseItems(List<dynamic> items) => items
    .map<VideoItemPartial>(
      (dynamic o) => VideoItemPartial.fromJson(o as Map<String, dynamic>),
    )
    .toList();

class Playlist {
  Playlist.fromJson(Map<String, dynamic> obj)
      : id = obj['id'] as String,
        title = obj['title'] as String,
        author = obj['author'] as String,
        items = _parseItems(obj['items'] as List<dynamic>);

  final String id;
  final String title;
  final String author;
  final List<VideoItemPartial> items;
}
