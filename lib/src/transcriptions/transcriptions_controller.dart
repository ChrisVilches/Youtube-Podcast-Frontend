import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../models/transcription_entry.dart';
import '../models/video_item.dart';
import '../services/youtube.dart';
import '../util/sleep.dart';

// TODO: Compare this controller with the settings_controller to check if it looks good.
//       At least it works.

// TODO: Check that it does the right amount of queries.

class TranscriptionsController extends ChangeNotifier {
  TranscriptionsController(this.video) {
    if (video.transcriptions.isNotEmpty) {
      _selectedLanguage = video.transcriptions.first.lang;
      _fetchTranscription();
    }
  }

  final VideoItem video;
  String? _selectedLanguage;

  String? get selectedLanguage => _selectedLanguage;

  set selectedLanguage(String? newLang) {
    if (_selectedLanguage != newLang && _selectedLanguage != null) {
      _selectedLanguage = newLang;
      notifyListeners();
      _fetchTranscription();
    }
  }

  List<TranscriptionEntry> result = List<TranscriptionEntry>.empty();
  bool loading = false;
  String? error;

  Future<void> _fetchTranscription() async {
    loading = true;
    EasyLoading.show(status: 'Loading transcription');
    notifyListeners();

    // TODO: Debug only (REMOVE)
    await sleep1();
    try {
      error = null;
      result = await getTranscriptionContent(video.videoId, _selectedLanguage!);
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    EasyLoading.dismiss();
    notifyListeners();
  }
}
