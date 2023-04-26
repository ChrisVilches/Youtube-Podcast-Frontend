import 'dart:async';
import 'package:flutter/material.dart';
import '../services/download_logic.dart';
import '../services/locator.dart';
import '../services/prepare_download_service.dart';
import '../types.dart';

class PrepareDownloadController extends ChangeNotifier {
  PrepareDownloadController() {
    _subscription = videoPreparedEvents.stream.listen(_handlePreparedEvent);
  }

  final Set<String> _beingPrepared = <String>{};
  late StreamSubscription<VideoPreparedEvent> _subscription;

  Future<void> _handlePreparedEvent(final VideoPreparedEvent event) async {
    assert(_beingPrepared.contains(event.videoId));

    await serviceLocator
        .get<DownloadLogic>()
        .execute(event.videoId, event.success);

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
    //       This comment may be a bit outdated, but the idea remains (only the function names may have been changed).
    //       The idea is to open the file (if possible) without showing "Preparing..."

    waitForResult(videoId);
  }

  @override
  void dispose() {
    super.dispose();
    // ignore: discarded_futures
    _subscription.cancel();
  }
}
