class TranscriptionMetadata {
  TranscriptionMetadata.fromJson(Map<String, dynamic> obj)
      : name = obj['name'] as String,
        url = obj['url'] as String,
        lang = obj['lang'] as String;

  final String name;
  final String url;
  final String lang;
}
