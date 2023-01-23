import 'thumbnail.dart';

typedef VideoID = String;

class VideoItemPartial {
  const VideoItemPartial(this.videoId, this.title, this.thumbnails);

  final VideoID videoId;
  final String title;

  /// Thumbnails sorted by size (width X height)
  final List<Thumbnail> thumbnails;

  static VideoItemPartial from(Map<String, dynamic> obj) {
    final VideoID videoId = obj['videoId'] as VideoID;
    final String title = obj['title'] as String;

    final List<Thumbnail> thumbnails = (obj['thumbnails'] as List<dynamic>)
        .map((dynamic o) => Thumbnail.from(o as Map<String, dynamic>))
        .toList();
    thumbnails.sort((Thumbnail a, Thumbnail b) => a.size() - b.size());

    return VideoItemPartial(videoId, title, thumbnails);
  }
}
