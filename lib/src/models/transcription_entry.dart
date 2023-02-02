class TranscriptionEntry {
  TranscriptionEntry.fromJson(final Map<String, dynamic> obj)
      : text = obj['text'] as String,
        start = double.tryParse(obj['start'].toString())!,
        duration = double.tryParse(obj['duration'].toString())!;

  final String text;
  final double start;
  final double duration;
}
