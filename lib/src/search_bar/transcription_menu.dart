import 'package:flutter/material.dart';

import '../models/transcription_metadata.dart';
import '../services/youtube.dart';

class TranscriptionMenu extends StatefulWidget {
  const TranscriptionMenu({
    super.key,
    required this.videoId,
    required this.availableTranscriptions,
  });

  final String videoId;
  final List<TranscriptionMetadata> availableTranscriptions;

  @override
  State<TranscriptionMenu> createState() => _TranscriptionMenuState();
}

class _TranscriptionMenuState extends State<TranscriptionMenu> {
  TranscriptionMetadata? _transcription;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<TranscriptionMetadata>(
      value: _transcription,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (TranscriptionMetadata? value) async {
        // This is called when the user selects an item.
        setState(() {
          _transcription = value;
        });

        if (_transcription != null) {
          await getTranscriptionContent(widget.videoId, _transcription!.lang);
        }
      },
      items: widget.availableTranscriptions
          .map<DropdownMenuItem<TranscriptionMetadata>>(
              (TranscriptionMetadata value) {
        return DropdownMenuItem<TranscriptionMetadata>(
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }
}
