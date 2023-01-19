class Thumbnail {
  const Thumbnail(this.url, this.width, this.height);

  final String url;
  final int width;
  final int height;

  int size() {
    return width * height;
  }

  // TODO: Applies to all models. I think the "fromJson" method is a standard and gets
  //       called by jsonDecode. I'm not sure though.
  static Thumbnail from(Map<String, dynamic> obj) {
    final String url = obj['url'] as String;
    final int w = obj['width'] as int;
    final int h = obj['height'] as int;
    return Thumbnail(url, w, h);
  }
}
