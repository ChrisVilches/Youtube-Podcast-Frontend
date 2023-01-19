import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transcription_metadata.dart';
import 'transcriptions_controller.dart';

class TranscriptionMenu extends StatelessWidget {
  const TranscriptionMenu({super.key});

  List<DropdownMenuItem<String>> _transcriptionOptions(
    List<TranscriptionMetadata> transcriptions,
  ) {
    return transcriptions
        .map<DropdownMenuItem<String>>(
          (TranscriptionMetadata value) => DropdownMenuItem<String>(
            value: value.lang,
            child: Text(value.name),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TranscriptionsController>(
      builder: (
        BuildContext context,
        TranscriptionsController ctrl,
        _,
      ) {
        if (ctrl.video.transcriptions.isEmpty) {
          return const Text('No transcriptions available');
        }

        return DropdownButton<String>(
          value: ctrl.selectedLanguage,
          icon: const Icon(Icons.arrow_downward),
          elevation: 16,
          onChanged: (String? lang) {
            ctrl.selectedLanguage = lang;
          },
          items: _transcriptionOptions(ctrl.video.transcriptions),
        );
      },
    );
  }
}
