import 'package:flutter/material.dart';

import '../models/transcription_entry.dart';
import '../util/format.dart';
import '../widgets/left_right_row.dart';

// TODO: Test this on Android 11 and more on device/PC, because the look changed a bit.

class TranscriptionsList extends StatelessWidget {
  const TranscriptionsList({super.key, required this.transcription});

  final List<TranscriptionEntry> transcription;

  @override
  Widget build(final BuildContext context) {
    return ListView.builder(
      restorationId: 'TranscriptionsList',
      itemCount: transcription.length,
      itemBuilder: (final _, final int index) => LeftRightRow(
        left: removeHour00(formatTimeHHMMSSms(transcription[index].start)),
        right: transcription[index].text,
      ),
    );
  }
}
