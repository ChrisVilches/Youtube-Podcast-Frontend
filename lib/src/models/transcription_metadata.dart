class TranscriptionMetadata {
  TranscriptionMetadata(this.name, this.url, this.lang);

  final String name;
  final String url;
  final String lang;

  static TranscriptionMetadata from(Map<String, dynamic> obj) {
    final String name = obj['name'] as String;
    final String url = obj['url'] as String;
    final String lang = obj['lang'] as String;

    return TranscriptionMetadata(name, url, lang);
  }
}
