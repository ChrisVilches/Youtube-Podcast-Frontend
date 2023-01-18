import 'package:flutter/material.dart';
import '../models/transcription_metadata.dart';
import 'transcriptions_controller.dart';

// TODO: Maybe this view would work well with the controller pattern.
//       Specially because there's the following bug:
//       * The user changes the menu option
//       * This widget starts loading the transcription
//       * The parent doesn't know it's loading (the parent should show the "loading"... not here)
//       * This widget notifies the parent with the transcription content.
//       * The parent updates the content, but never knew it was loading.
//       The parent should know it's loading. So I think the best way to do this would be to create a controller
//       and tie it to this widget and its parent.
//       I think it should work, but I don't remember how the controllers worked.
//
//       OK, I think the above is done.

class TranscriptionMenu extends StatelessWidget {
  const TranscriptionMenu({
    super.key,
    required this.controller,
  });

  final TranscriptionsController controller;

  List<DropdownMenuItem<String>> _transcriptionOptions() {
    return controller.video.transcriptions
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
    // TODO: Note that this is part of the menu. It should be like a disabled dropdown menu.
    //       Although anything works.
    if (controller.video.transcriptions.isEmpty) {
      return const Text('No transcriptions available');
    }

    return DropdownButton<String>(
      value: controller.selectedLanguage,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      onChanged: (String? lang) {
        controller.selectedLanguage = lang;
      },
      items: _transcriptionOptions(),
    );
  }
}
