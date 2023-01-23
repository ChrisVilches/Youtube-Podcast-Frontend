import 'thumbnail.dart';

typedef VideoID = String;

class VideoItemPartial {
  const VideoItemPartial(this.videoId, this.title, this.thumbnails);

  factory VideoItemPartial.fromJson(Map<String, dynamic> obj) {
    final String videoId = obj['videoId'] as String;
    final String title = obj['title'] as String;

    final List<Thumbnail> thumbnails = (obj['thumbnails'] as List<dynamic>)
        .map((dynamic o) => Thumbnail.fromJson(o as Map<String, dynamic>))
        .toList();
    thumbnails.sort((Thumbnail a, Thumbnail b) => a.size() - b.size());

    return VideoItemPartial(videoId, title, thumbnails);
  }

  final VideoID videoId;
  final String title;

  /// Thumbnails sorted by size (width X height)
  final List<Thumbnail> thumbnails;
}
