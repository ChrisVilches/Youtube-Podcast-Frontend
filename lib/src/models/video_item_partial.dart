import 'thumbnail.dart';

typedef VideoID = String;

class VideoItemPartial {
  const VideoItemPartial(
    this.videoId,
    this.title,
    this.thumbnails,
    this.author,
    this.duration,
  );

  factory VideoItemPartial.fromJson(final Map<String, dynamic> obj) {
    final String videoId = obj['videoId'] as String;
    final String title = obj['title'] as String;
    final String author = obj['author'] as String;
    final int? duration = obj['duration'] as int?;

    final List<Thumbnail> thumbnails = (obj['thumbnails'] as List<dynamic>)
        .map((final dynamic o) => Thumbnail.fromJson(o as Map<String, dynamic>))
        .toList();
    thumbnails
        .sort((final Thumbnail a, final Thumbnail b) => a.size() - b.size());

    return VideoItemPartial(videoId, title, thumbnails, author, duration);
  }

  final VideoID videoId;
  final String title;
  final String author;
  final int? duration;

  /// Thumbnails sorted by size (width X height)
  final List<Thumbnail> thumbnails;
}
