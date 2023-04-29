import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';
import '../../types.dart';
import '../../util/enum_converter.dart';
import '../../util/storage.dart';
import '../api_uri.dart';
import '../download_tasks.dart';
import '../locator.dart';
import '../snackbar_service.dart';
import 'download_logic_io.dart';

class AndroidDownloadLogicIO extends DownloadLogicIO {
  AndroidDownloadLogicIO() : _downloadDir = getValidDownloadDir() {
    // ignore: discarded_futures
    FlutterDownloader.registerCallback(callback);
  }

  final Future<Directory> _downloadDir;

  @pragma('vm:entry-point')
  static void callback(
    final String id,
    final DownloadTaskStatus status,
    final int progress,
  ) {
    debugPrint('Download callback | $id | $status | $progress');
  }

  @override
  Future<void> cleanDownload(final VideoID videoId) => cleanTasks(videoId);

  @override
  Future<DownloadStatus> downloadStatus(final VideoID videoId) async =>
      convertDownloadStatus(await findTask(videoId));

  @override
  Future<void> startDownload(final VideoID videoId) async {
    final Directory dir = await _downloadDir;
    await FlutterDownloader.enqueue(
      url: downloadUri(videoId).toString(),
      savedDir: dir.path,
    );
  }

  @override
  Future<bool> hasStoragePermission() => deviceHasStoragePermission();

  @override
  void showSuccessMessage(final String msg, final VideoID videoId) {
    final SnackBarAction cancelAction = SnackBarAction(
      label: 'CANCEL',
      onPressed: () async {
        await cleanTasks(videoId);

        serviceLocator.get<SnackbarService>().info('Canceled');
      },
    );
    serviceLocator.get<SnackbarService>().success(msg, action: cancelAction);
  }

  // TODO: Consider changing name to "tryOpenFile" since we are not only using
  //       completed files, but also testing against non-completed tasks (which would all fail anyway).
  //       We are not assuming that this function is executed only when the task has been validated to be completed.
  //       If I end up implementing this like this, I don't need the HEAD request anymore (nor the Cache library).
  //       NOTE: Do it in another commit, so I can code review more easily.
  @override
  Future<TryOpenResult> tryOpenCompletedFile(final VideoID videoId) async {
    final Directory dir = await _downloadDir;
    final DownloadTask? task = await findTask(videoId);
    final DownloadStatus status = await downloadStatus(videoId);

    if (task == null || status != DownloadStatus.complete) {
      return TryOpenResult.fileNotFound;
    }

    final String saveFilePath = join(dir.path, task.filename ?? '');
    final OpenResult openResult = await OpenFilex.open(saveFilePath);

    return convertOpenResult(openResult.type);
  }
}
