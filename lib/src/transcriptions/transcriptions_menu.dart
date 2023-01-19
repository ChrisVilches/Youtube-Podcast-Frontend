import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        // TODO: Note that this is part of the menu. It should be like a disabled dropdown menu.
        //       Although anything works.
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
