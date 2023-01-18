import 'video_item.dart';

class Playlist {
  const Playlist(this.id, this.title, this.items);

  final String id;
  final String title;
  final List<VideoItem> items;

  static Playlist from(Map<String, dynamic> obj) {
    final String id = obj['id'] as String;
    final String title = obj['title'] as String;
    final List<VideoItem> items = (obj['items'] as List<dynamic>)
        .map<VideoItem>(
            (dynamic o) => VideoItem.from(o as Map<String, dynamic>))
        .toList();
    return Playlist(id, title, items);
  }
}
