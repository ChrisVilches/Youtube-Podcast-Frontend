import 'dart:async';

import '../util/sleep.dart';
import 'youtube.dart';

/// Prepares the video and then downloads it when it's prepared.

// TODO: Doesn't work for videos that never get prepared (e.g. live streams).

Map<String, int> _beingPrepared = <String, int>{};

Future<void> _tryDownload(String youtubeVideo) async {
  final DownloadResponse res = await prepareVideo(youtubeVideo);
  if (res.canDownload) {
    downloadVideo(youtubeVideo);
    _beingPrepared.remove(youtubeVideo);
  }
}

// TODO: Must be called at the start of the program. And then it will sometime be deprecated.
Future<void> initializePollingLoop() async {
  while (true) {
    for (final MapEntry<String, int> entry in _beingPrepared.entries) {
      final String youtubeVideo = entry.key;
      final int remainingPolls = entry.value;

      await _tryDownload(youtubeVideo);
      // TODO: Something about this code is wrong and hangs sometimes (stops polling).
      //       But it's trash anyway and I have to make it using sockets.
      if (remainingPolls > 0) {
        _beingPrepared[youtubeVideo] = _beingPrepared[youtubeVideo]! - 1;
      } else {
        _beingPrepared.remove(youtubeVideo);
      }
    }
    await sleep1();
  }
}

Future<bool> startPrepareProcess(String youtubeVideo) async {
  if (_beingPrepared.containsKey(youtubeVideo)) {
    return false;
  }

  _beingPrepared[youtubeVideo] = 30;
  _tryDownload(youtubeVideo);

  return true;
}
