import 'package:flutter/material.dart';

import '../models/video_item.dart';
import '../services/youtube.dart';
import '../util/sleep.dart';

// TODO: Compare this controller with the settings_controller to check if it looks good.
//       At least it works.

// TODO: Check that it does the right amount of queries.

class TranscriptionsController extends ChangeNotifier {
  TranscriptionsController(this.video) {
    if (video.transcriptions.isNotEmpty) {
      selectedLanguage = video.transcriptions.first.lang;
      fetchTranscription(selectedLanguage!);
    }
  }

  final VideoItem video;
  String? selectedLanguage;
  String result = '';
  bool loading = false;

  Future<void> fetchTranscription(String lang) async {
    loading = true;
    notifyListeners();

    // TODO: Debug only (REMOVE)
    await sleep1();
    result = await getTranscriptionContent(video.videoId, lang);
    loading = false;
    notifyListeners();
  }
}
