import 'dart:async';
import 'package:flutter/material.dart';
import '../models/video_item_partial.dart';
import '../services/download_service.dart';
import '../services/locator.dart';
import '../services/prepare_download_service.dart';
import '../services/snackbar_service.dart';

class PrepareDownloadController extends ChangeNotifier {
  PrepareDownloadController() {
    _subscription = videoPreparedEvents.stream.listen(_handlePreparedEvent);
  }

  final Set<String> _beingPrepared = <String>{};
  late StreamSubscription<VideoPreparedEvent> _subscription;

  bool _canCancelDownload() {
    return serviceLocator.get<DownloadService>().canCancelDownload();
  }

  void showDownloadStatusMessage(
    final String? msg,
    final bool hasError,
    final bool taskExists,
    final VideoID videoId,
  ) {
    if (msg == null) {
      return;
    }

    SnackBarAction? cancelAction;

    if (taskExists && _canCancelDownload()) {
      /*
      TODO: Clicking on "cancel" may make the task become "failed". I'm not sure under what conditions though.
            Is it because I cancel and then remove the task as well? Not sure.

            There are some things to consider, that may not necessarily be related, but I list them anyway:
            * If the download fails, the file may be partially downloaded, and the app will try to open the corrupt file when clicking on
              its "Download" button in the UI. I'm not sure if the corrupt file is cleaned up, though. One way to fix this would be to check if
              the file hash (md5 or whatever) is correct. For this, I'd need to store the hash in the server as well (as metadata in Minio would
              be OK). Summary: fetch the hash, check if it's correct, and open the file (<-- do this everytime I try to open the file from the app).
            * It seems the download is stopped (and fails) when the main app goes into the background (e.g. I change to another app).
            * There are probably other situations where the download fails, and the reason is not apparent, so a more thorough debugging would be necessary.
              How to reproduce: Since it's not clear, the only way would be to just download several videos and see if any download fails.
      */

      cancelAction = SnackBarAction(
        label: 'CANCEL',
        onPressed: () async {
          await serviceLocator
              .get<DownloadService>()
              .cancelVideoDownload(videoId);
          serviceLocator.get<SnackbarService>().info('Canceled');
        },
      );
    }

    if (hasError) {
      serviceLocator.get<SnackbarService>().danger(msg, action: cancelAction);
    } else {
      serviceLocator.get<SnackbarService>().success(msg, action: cancelAction);
    }
  }

  Future<void> _handlePreparedEvent(final VideoPreparedEvent event) async {
    assert(_beingPrepared.contains(event.videoId));

    String? msg;
    bool ok;
    bool taskExists = false;

    if (event.success) {
      // Wait for the download task to be enqueued.
      final DispatchDownloadResult dispatchResult = await serviceLocator
          .get<DownloadService>()
          .downloadVideo(event.videoId);

      msg = dispatchDownloadResultMessage(dispatchResult);
      taskExists = true;
      ok = dispatchDownloadResultSuccess(dispatchResult);
    } else {
      msg = 'Video cannot be downloaded';
      ok = false;
    }

    showDownloadStatusMessage(msg, !ok, taskExists, event.videoId);

    _beingPrepared.remove(event.videoId);
    notifyListeners();
  }

  Set<String> get beingPrepared => _beingPrepared;

  void startPrepareProcess(final VideoID videoId) {
    assert(!_beingPrepared.contains(videoId));
    _beingPrepared.add(videoId);
    notifyListeners();

    // TODO: Optimization for android: we can run _tryOpenCompletedFile and _isAlreadyRunning
    //       before adding to "_beingPrepared" and calling "waitForResult" and the precomputed
    //       result (e.g. file exists, or is already running) without doing these expensive operations.
    //       Remember that "waitForResult" subscribes to a Socket room.

    waitForResult(videoId);
  }

  @override
  void dispose() {
    super.dispose();
    // ignore: discarded_futures
    _subscription.cancel();
  }
}
