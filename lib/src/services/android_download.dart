import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';
import '../models/video_item_partial.dart';
import '../util/storage.dart';
import '../util/youtube_url.dart';
import 'android_download_tasks.dart';
import 'api_uri.dart';
import 'dispatch_download_result.dart';
import 'youtube.dart';

class AndroidDownloadService {
  static bool _init = false;

  static void callback(String _, DownloadTaskStatus __, int ___) {}

  static Future<void> init() async {
    if (_init) {
      return;
    }
    _init = true;
    await FlutterDownloader.registerCallback(callback);
  }

  Future<DispatchDownloadResult> downloadVideo(VideoID videoId) async {
    if (!(await hasStoragePermission())) {
      return DispatchDownloadResult.permissionError;
    }

    if (await _isAlreadyRunning(videoId)) {
      return DispatchDownloadResult.inProgress;
    }

    final OpenResult openResult = await _tryOpenCompletedFile(videoId);
    debugPrint('Result of trying to open the file: ${openResult.type}');

    switch (openResult.type) {
      case ResultType.done:
        return DispatchDownloadResult.canOpenExisting;
      case ResultType.fileNotFound:
        // Should download the file in this case.
        break;
      case ResultType.noAppToOpen:
        return DispatchDownloadResult.cannotOpenExisting;
      case ResultType.permissionDenied:
        return DispatchDownloadResult.permissionError;
      case ResultType.error:
        return DispatchDownloadResult.unhandledError;
    }

    // Pre-cleaning to remove canceled/failed tasks.
    await cleanVideoTasks(videoId);

    // TODO: Sometimes (Android 10) the file is download as ".m4a (2)". When clicking on the notification,
    //       the file fails to open (clicking on it does nothing).
    //       This should not happen (in a normal situation) anymore, because the file will be attempted to be opened
    //       if it already exists.
    //       If this problem doesn't happen in a while, remove this todo.

    await FlutterDownloader.enqueue(
      url: downloadUri(videoId).toString(),
      savedDir: (await getValidDownloadDir()).path,
    );

    return DispatchDownloadResult.dispatchedCorrectly;
  }

  Future<void> cleanVideoTasks(VideoID videoId) async {
    assert(!videoId.contains('http'));

    final List<DownloadTask> tasks = (await allTasks())
        .where((DownloadTask t) => vQueryParam(t.url) == videoId)
        .toList();

    for (final DownloadTask task in tasks) {
      await FlutterDownloader.cancel(taskId: task.taskId);
      await FlutterDownloader.remove(
        taskId: task.taskId,
        shouldDeleteContent: true,
      );
    }
  }

  Future<bool> _isAlreadyRunning(VideoID videoId) async {
    final DownloadTask? runningTask = (await allTasks()).firstWhereOrNull(
      (DownloadTask t) =>
          t.status == DownloadTaskStatus.running &&
          vQueryParam(t.url) == videoId,
    );
    return runningTask != null;
  }

  // TODO: This seems to work.
  //       Clean & Refactor
  //       Test on Android 11
  //
  //       How to test:
  //       Download a file
  //       Remove the task
  //       Try to open the file. It should open it without downloading it.
  Future<OpenResult> _tryOpenCompletedFile(VideoID videoId) async {
    final String fileName = await videoFileName(videoId);
    debugPrint('Trying to open file $fileName');

    final String savedDir = Directory(ANDROID_DOWNLOAD_DIR).path;
    final String saveFilePath = join(savedDir, fileName);
    return OpenFilex.open(saveFilePath);
  }
}
