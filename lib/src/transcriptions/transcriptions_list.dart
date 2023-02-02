import 'package:flutter/material.dart';

import '../models/transcription_entry.dart';
import 'transcription_entry_tile.dart';

class TranscriptionsList extends StatelessWidget {
  const TranscriptionsList({super.key, required this.transcription});

  final List<TranscriptionEntry> transcription;

  @override
  Widget build(final BuildContext context) {
    return ListView.builder(
      restorationId: 'TranscriptionsList',
      itemCount: transcription.length,
      itemBuilder: (final _, final int index) =>
          TranscriptionEntryTile(entry: transcription[index]),
    );
  }
}
