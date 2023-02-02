import 'package:flutter/material.dart';

import '../models/transcription_entry.dart';
import '../util/format.dart';

class TranscriptionEntryTile extends StatelessWidget {
  const TranscriptionEntryTile({super.key, required this.entry});

  final TranscriptionEntry entry;

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 100.0, // fixed width and height
        child: Align(
          child: Text(removeHour00(formatTimeHHMMSSms(entry.start))),
        ),
      ),
      title: Text(entry.text),
    );
  }
}
