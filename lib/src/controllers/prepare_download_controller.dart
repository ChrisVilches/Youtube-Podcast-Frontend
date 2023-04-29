import 'dart:async';
import 'package:flutter/material.dart';
import '../services/download_logic.dart';
import '../services/locator.dart';
import '../services/prepare_download_service.dart';
import '../services/snackbar_service.dart';
import '../types.dart';

class PrepareDownloadController extends ChangeNotifier {
  PrepareDownloadController() {
    _subscription = videoPreparedEvents.stream.listen(_handlePreparedEvent);
  }

  final Set<String> _beingPrepared = <String>{};
  late StreamSubscription<VideoPreparedEvent> _subscription;

  Future<void> _handlePreparedEvent(final VideoPreparedEvent event) async {
    assert(_beingPrepared.contains(event.videoId));

    if (event.success) {
      await serviceLocator
          .get<DownloadLogic>()
          .execute(event.videoId, download: true);
    } else {
      serviceLocator
          .get<SnackbarService>()
          .danger('Video cannot be downloaded');
    }

    _beingPrepared.remove(event.videoId);
    notifyListeners();
  }

  Set<String> get beingPrepared => _beingPrepared;

  Future<void> startPrepareProcess(final VideoID videoId) async {
    assert(!_beingPrepared.contains(videoId));

    if (await serviceLocator
        .get<DownloadLogic>()
        .execute(videoId, download: false)) {
      return;
    }

    _beingPrepared.add(videoId);
    notifyListeners();
    waitForResult(videoId);
  }

  @override
  void dispose() {
    super.dispose();
    // ignore: discarded_futures
    _subscription.cancel();
  }
}
