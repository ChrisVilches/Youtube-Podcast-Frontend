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
import 'locator.dart';
import 'snackbar_service.dart';

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

  Future<DispatchDownloadResult> downloadVideo(VideoID videoId) async {
    assert(!videoId.contains('http'));

    final DownloadTask? task = (await allTasks()).firstWhereOrNull(
      (DownloadTask t) => vQueryParam(t.url) == videoId,
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

    // Pre-cleaning to remove canceled/failed tasks.
    await cancelTasks(videoId);

    final PermissionStatus permission = await Permission.storage.request();

    if (!permission.isGranted) {
      return DispatchDownloadResult.permissionError;
    }

    await FlutterDownloader.enqueue(
      url: downloadUri(videoId).toString(),
      savedDir: _DOWNLOAD_DIR,
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
