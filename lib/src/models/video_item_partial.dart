import 'thumbnail.dart';

typedef VideoID = String;

class VideoItemPartial {
  const VideoItemPartial(
    this.videoId,
    this.title,
    this.thumbnails,
    this.author,
  );

  factory VideoItemPartial.fromJson(Map<String, dynamic> obj) {
    final String videoId = obj['videoId'] as String;
    final String title = obj['title'] as String;
    final String author = obj['author'] as String;

    final List<Thumbnail> thumbnails = (obj['thumbnails'] as List<dynamic>)
        .map((dynamic o) => Thumbnail.fromJson(o as Map<String, dynamic>))
        .toList();
    thumbnails.sort((Thumbnail a, Thumbnail b) => a.size() - b.size());

    return VideoItemPartial(videoId, title, thumbnails, author);
  }

  final VideoID videoId;
  final String title;
  final String author;

  /// Thumbnails sorted by size (width X height)
  final List<Thumbnail> thumbnails;
}
