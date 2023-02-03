import 'video_item_partial.dart';

List<VideoItemPartial> _parseItems(final List<dynamic> items) => items
    .map<VideoItemPartial>(
      (final dynamic o) => VideoItemPartial.fromJson(o as Map<String, dynamic>),
    )
    .toList();

class Playlist {
  Playlist.fromJson(final Map<String, dynamic> obj)
      : id = obj['id'] as String,
        title = obj['title'] as String,
        author = obj['author'] as String,
        isChannel = obj['isChannel'] as bool,
        items = _parseItems(obj['items'] as List<dynamic>);

  final String id;
  final String title;
  final String author;
  final bool isChannel;
  final List<VideoItemPartial> items;
}
