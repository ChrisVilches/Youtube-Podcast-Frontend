class Thumbnail {
  const Thumbnail(this.url, this.width, this.height);

  final String url;
  final int width;
  final int height;

  int size() {
    return width * height;
  }

  static Thumbnail from(Map<String, dynamic> obj) {
    final String url = obj['url'] as String;
    final int w = obj['width'] as int;
    final int h = obj['height'] as int;
    return Thumbnail(url, w, h);
  }
}

class VideoItem {
  const VideoItem(
      this.videoId, this.title, this.thumbnails);

  final String videoId;
  final String title;

  /// Thumbnails sorted by size (width X height)
  final List<Thumbnail> thumbnails;

  static VideoItem from(Map<String, dynamic> obj) {
    final String videoId = obj['videoId'] as String;
    final String title = obj['title'] as String;

    final List<Thumbnail> thumbnails = (obj['thumbnails'] as List<dynamic>).map((dynamic o) => Thumbnail.from(o as Map<String, dynamic>)).toList();
    thumbnails.sort((Thumbnail a, Thumbnail b) => a.size() - b.size());

    return VideoItem(videoId, title, thumbnails);
  }
}
