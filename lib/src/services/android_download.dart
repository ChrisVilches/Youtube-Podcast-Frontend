import 'dart:isolate';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/video_item_partial.dart';
import 'android_download_tasks.dart';
import 'api_uri.dart';
import 'dispatch_download_result.dart';
import 'locator.dart';
import 'snackbar_service.dart';

// TODO: Should be able to cancel downloads (and then be able to trigger them again).
//       (should be done by removing the notification, I guess... does that cancel the task
// /      and remove the file and task entry in the database??)

// TODO: Check how much my implementation differs from the memo (Google Keep) note.

// TODO: (Very low priority) If the downloader converts the name to a valid name, then try removing the
//       "removeSlashes" on the backend. Does it work when downloading a file with / on browser and android?
//       (must add the / manually). If it doesn't work, just leave it as it is.

const String _DOWNLOAD_DIR = '/storage/emulated/0/Download/';

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

  // TODO: Should be called "download or open". Or simplify the scope/responsability of this method
  //       and make it "only download", and then force the caller to open it if it's already downloaded.
  Future<DispatchDownloadResult> downloadVideo(VideoID videoId) async {
    assert(!videoId.contains('http'));

    final String url = downloadUri(videoId).toString();

    final DownloadTask? task = (await allTasks()).firstWhereOrNull(
      (DownloadTask element) => element.url == url,
    );

    if (_isAlreadyRunning(task)) {
      return DispatchDownloadResult.inProgress;
    }

    if (await _tryOpenCompletedFile(task)) {
      return DispatchDownloadResult.canOpenExisting;
    }

    // TODO: Unhandled for now.
    if (task != null && task.status == DownloadTaskStatus.paused) {
      return DispatchDownloadResult.unhandledError;
    }

    // Pre-cleaning to remove cancelled/failed tasks.
    await cancelTasks(videoId);

    final PermissionStatus permission = await Permission.storage.request();

    if (!permission.isGranted) {
      return DispatchDownloadResult.permissionError;
    }

    await FlutterDownloader.enqueue(
      url: url,
      savedDir: _DOWNLOAD_DIR,
    );

    return DispatchDownloadResult.dispatchedCorrectly;
  }

  Future<void> cancelTasks(VideoID videoId) async {
    assert(!videoId.contains('http'));
    // TODO: There's a rare case where the video ID exists but it's also a substring of another ID,
    //       and therefore there are two matches. This is extremely rare though.
    //       And there's a much more common situation in which there are multiple tasks for the same URL
    //       but the tasks are actually different tasks.
    //
    //       Re-implement for task arrays. (The problem of substring matching remains though... so use a Regex)

    final List<DownloadTask> tasks = (await allTasks())
        .where((DownloadTask t) => t.url.contains(videoId))
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

  Future<bool> _tryOpenCompletedFile(DownloadTask? task) async {
    if (task == null || task.status != DownloadTaskStatus.complete) {
      return false;
    }

    if (await FlutterDownloader.open(taskId: task.taskId)) {
      return true;
    }

    serviceLocator.get<SnackbarService>().simpleSnackbar(
          'Cannot open the file (trying to download again...)',
        );
    await FlutterDownloader.remove(taskId: task.taskId);

    return false;
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
