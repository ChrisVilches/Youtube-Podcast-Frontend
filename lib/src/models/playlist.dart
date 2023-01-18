import 'video_item_partial.dart';

class Playlist {
  const Playlist(this.id, this.title, this.items);

  final String id;
  final String title;
  final List<VideoItemPartial> items;

  static Playlist from(Map<String, dynamic> obj) {
    final String id = obj['id'] as String;
    final String title = obj['title'] as String;
    final List<VideoItemPartial> items = (obj['items'] as List<dynamic>)
        .map<VideoItemPartial>(
          (dynamic o) => VideoItemPartial.from(o as Map<String, dynamic>),
        )
        .toList();
    return Playlist(id, title, items);
  }
}
