class TranscriptionEntry {
  const TranscriptionEntry(this.text, this.start, this.duration);

  final String text;
  final double start;
  final double duration;

  static TranscriptionEntry from(Map<String, dynamic> obj) {
    final String text = obj['text'] as String;
    final double start = double.tryParse(obj['start'].toString())!;
    final double duration = double.tryParse(obj['duration'].toString())!;
    return TranscriptionEntry(text, start, duration);
  }
}
