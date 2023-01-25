import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/video_item_partial.dart';
import '../util/youtube_url.dart';
import 'android_download_tasks.dart';
import 'api_uri.dart';
import 'dispatch_download_result.dart';

const String _DOWNLOAD_DIR = '/storage/emulated/0/Download';

enum TryOpenFileResult {
  SHOULD_PROCEED_DOWNLOAD,
  COULD_OPEN_FILE,
  FILE_EXISTS_BUT_CANNOT_OPEN
}

class AndroidDownloadService {
  AndroidDownloadService() {
    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );

    _port.listen((dynamic data) {
      final String id = (data as List<dynamic>)[0] as String;
      final DownloadTaskStatus status = data[1] as DownloadTaskStatus;
      final int progress = data[2] as int;
      debugPrint('Download status: $id | $status ($progress%)');
    });
  }

  Future<void> init() => FlutterDownloader.registerCallback(downloadCallback);

  final ReceivePort _port = ReceivePort();

  Future<DispatchDownloadResult> downloadVideo(VideoID videoId) async {
    assert(!videoId.contains('http'));

    final DownloadTask? task = (await allTasks()).firstWhereOrNull(
      (DownloadTask t) => vQueryParam(t.url) == videoId,
    );

    if (_isAlreadyRunning(task)) {
      return DispatchDownloadResult.inProgress;
    }

    final TryOpenFileResult tryOpenResult = await _tryOpenCompletedFile(task);

    switch (tryOpenResult) {
      case TryOpenFileResult.SHOULD_PROCEED_DOWNLOAD:
        // Continue downloading file
        break;
      case TryOpenFileResult.COULD_OPEN_FILE:
        return DispatchDownloadResult.canOpenExisting;
      case TryOpenFileResult.FILE_EXISTS_BUT_CANNOT_OPEN:
        return DispatchDownloadResult.cannotOpenExisting;
    }

    // TODO: Unhandled for now.
    if (task != null && task.status == DownloadTaskStatus.paused) {
      return DispatchDownloadResult.unhandledError;
    }

    // Pre-cleaning to remove canceled/failed tasks.
    await cancelTasks(videoId);

    final PermissionStatus permission = await Permission.storage.request();

    if (!permission.isGranted) {
      return DispatchDownloadResult.permissionError;
    }

    // TODO: Sometimes (Android 10) the file is download as ".m4a (2)". When clicking on the notification,
    //       the file fails to open (clicking on it does nothing).

    final Directory downloadsDirectory = Directory(_DOWNLOAD_DIR);
    // ignore: avoid_slow_async_io
    assert(await downloadsDirectory.exists());

    await FlutterDownloader.enqueue(
      url: downloadUri(videoId).toString(),
      savedDir: downloadsDirectory.path,
      saveInPublicStorage: true,
      // TODO: Error:
      //       It looks like you are trying to save file in public storage but not setting 'saveInPublicStorage' to 'true'
      //  However this error only happens when doing this:
      //  Download file
      //  Remove its associated task (or all tasks)
      //  Download the file again (<---- error happens here, and the download fails)
      //  Try to download again (it works perfectly and the download completes)
      //  So maybe it's not a logic error.
      //
      //  And by looking at the Kotlin code, the message is printed for other reasons as well.
      //
      //  I think this is fixed by adding "saveInPublicStorage: true" (I tried a few times after adding this and it works)
      //  Must test on Android 11 as well.
    );

    return DispatchDownloadResult.dispatchedCorrectly;
  }

  Future<void> cancelTasks(VideoID videoId) async {
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

  bool _isAlreadyRunning(DownloadTask? task) {
    return task?.status == DownloadTaskStatus.running ||
        task?.status == DownloadTaskStatus.enqueued;
  }

  Future<TryOpenFileResult> _tryOpenCompletedFile(DownloadTask? task) async {
    if (task == null || task.status != DownloadTaskStatus.complete) {
      return TryOpenFileResult.SHOULD_PROCEED_DOWNLOAD;
    }

    final String saveFilePath = '${task.savedDir}/${task.filename!}';
    // ignore: avoid_slow_async_io
    final bool fileExists = await File(saveFilePath).exists();

    // When the task is completed, but the file doesn't exist.
    if (!fileExists) {
      await FlutterDownloader.remove(taskId: task.taskId);
      return TryOpenFileResult.SHOULD_PROCEED_DOWNLOAD;
    }

    return (await FlutterDownloader.open(taskId: task.taskId))
        ? TryOpenFileResult.COULD_OPEN_FILE
        : TryOpenFileResult.FILE_EXISTS_BUT_CANNOT_OPEN;
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send(<dynamic>[id, status, progress]);
  }
}
