import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/video_item_partial.dart';
import '../services/android_download.dart';
import '../services/api_uri.dart';
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

  bool _canCancelDownload() {
    return Platform.isAndroid;
  }

  void showDownloadStatusMessage(String? msg, bool taskExists, VideoID videoId) {
    if (msg == null) {
      return;
    }

    if (taskExists && _canCancelDownload()) {
      serviceLocator.get<SnackbarService>().snackbarWithAction(msg, 'CANCEL',
          () async {
        await serviceLocator.get<AndroidDownloadService>().cancelTasks(videoId);
        serviceLocator.get<SnackbarService>().simpleSnackbar('Canceled');
      });
    } else {
      serviceLocator.get<SnackbarService>().simpleSnackbar(msg);
    }
  }

  Future<void> _handlePreparedEvent(VideoPreparedEvent event) async {
    assert(_beingPrepared.contains(event.videoId));

    String? msg;
    bool taskExists = false;

    if (event.success) {
      // Wait for the download task to be enqueued.
      final DispatchDownloadResult dispatchResult =
          await downloadVideo(event.videoId);

      msg = dispatchDownloadResultMessage(dispatchResult);
      taskExists = true;
    } else {
      msg = 'Video cannot be downloaded';
    }

    showDownloadStatusMessage(msg, taskExists, event.videoId);

    _beingPrepared.remove(event.videoId);
    notifyListeners();
  }

  Set<String> get beingPrepared => _beingPrepared;

  Future<void> startPrepareProcess(VideoID videoId) async {
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
