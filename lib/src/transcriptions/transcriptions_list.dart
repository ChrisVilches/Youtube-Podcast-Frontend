import 'package:flutter/material.dart';

import '../models/transcription_entry.dart';
import 'transcription_entry_tile.dart';

class TranscriptionsList extends StatelessWidget {
  const TranscriptionsList({super.key, required this.transcription});

  final List<TranscriptionEntry> transcription;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      restorationId: 'TranscriptionsList',
      itemCount: transcription.length,
      itemBuilder: (_, int index) =>
          TranscriptionEntryTile(entry: transcription[index]),
    );
  }
}
