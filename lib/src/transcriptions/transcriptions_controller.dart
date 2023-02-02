import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../models/transcription_entry.dart';
import '../models/video_item.dart';
import '../services/youtube.dart';

class TranscriptionsController extends ChangeNotifier {
  TranscriptionsController(this.video) {
    if (video.transcriptions.isNotEmpty) {
      _selectedLanguage = video.transcriptions.first.lang;
      // ignore: discarded_futures
      _fetchTranscription();
    }
  }

  final VideoItem video;
  String? _selectedLanguage;

  String? get selectedLanguage => _selectedLanguage;

  /// Make sure to use this setter when it's not loading another transcription, otherwise it will crash.
  set selectedLanguage(final String? newLang) {
    assert(!loading);

    if (_selectedLanguage != newLang && _selectedLanguage != null) {
      _selectedLanguage = newLang;
      notifyListeners();
      // ignore: discarded_futures
      _fetchTranscription();
    }
  }

  List<TranscriptionEntry> result = List<TranscriptionEntry>.empty();
  bool loading = false;
  String? error;

  Future<void> _fetchTranscription() async {
    loading = true;

    await EasyLoading.show(status: 'Loading transcription');
    notifyListeners();

    try {
      error = null;
      result = await getTranscriptionContent(video.videoId, _selectedLanguage!);
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    await EasyLoading.dismiss();
    notifyListeners();
  }
}
