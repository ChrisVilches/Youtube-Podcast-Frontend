class Thumbnail {
  Thumbnail.fromJson(Map<String, dynamic> obj)
      : url = obj['url'] as String,
        width = obj['width'] as int,
        height = obj['height'] as int;

  final String url;
  final int width;
  final int height;

  int size() {
    return width * height;
  }
}
