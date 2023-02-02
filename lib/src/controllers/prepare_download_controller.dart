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
      // TODO: Clicking on "cancel" may make the task become "failed". I'm not sure under what conditions though.
      //       Is it because I cancel and then remove the task as well? Not sure.

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
