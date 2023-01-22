import 'dart:async';
import 'package:flutter/material.dart';
import '../services/locator.dart';
import '../services/prepare_download_service.dart';
import '../services/snackbar_service.dart';
import '../services/youtube.dart';

class PrepareDownloadController extends ChangeNotifier {
  PrepareDownloadController() {
    _subscription = videoPreparedEvents.stream.listen(_handlePreparedEvent);
  }

  final Set<String> _beingPrepared = <String>{};
  late StreamSubscription<VideoPreparedEvent> _subscription;

  Future<void> _handlePreparedEvent(VideoPreparedEvent event) async {
    assert(_beingPrepared.contains(event.videoId));

    String? msg;

    if (event.success) {
      // Wait for the download task to be enqueued.
      final DispatchDownloadResult dispatchResult =
          await downloadVideo(event.videoId);

      msg = dispatchDownloadResultMessage(dispatchResult);
    } else {
      msg = 'Video cannot be downloaded';
    }

    if (msg != null) {
      serviceLocator.get<SnackbarService>().simpleSnackbar(msg);
    }

    _beingPrepared.remove(event.videoId);
    notifyListeners();
  }

  Set<String> get beingPrepared => _beingPrepared;

  Future<void> startPrepareProcess(String videoId) async {
    assert(!_beingPrepared.contains(videoId));
    _beingPrepared.add(videoId);
    notifyListeners();
    waitForResult(videoId);
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }
}
