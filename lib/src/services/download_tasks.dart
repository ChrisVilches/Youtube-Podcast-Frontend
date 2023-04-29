import 'package:collection/collection.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import '../types.dart';
import 'locator.dart';
import 'snackbar_service.dart';

Future<List<DownloadTask>> _allTasks() async {
  return await FlutterDownloader.loadTasks() ?? List<DownloadTask>.empty();
}

Future<void> clearAllDownloadTaskData({
  required final bool shouldDeleteContent,
}) async {
  final List<DownloadTask> tasks = await _allTasks();

  final int prevCount = tasks.length;

  for (final DownloadTask t in tasks) {
    await FlutterDownloader.remove(
      taskId: t.taskId,
      shouldDeleteContent: shouldDeleteContent,
    );
  }

  assert((await _allTasks()).isEmpty);
  serviceLocator.get<SnackbarService>().success('Removed $prevCount items');
}

bool _urlHasId(final String url, final VideoID videoId) {
  return Uri.parse(url).queryParameters['v'] == videoId;
}

Future<int> cleanTasks(final VideoID videoId) async {
  final List<DownloadTask> tasks = await _allTasks();

  int removedTasks = 0;

  for (final DownloadTask task in tasks) {
    if (!_urlHasId(task.url, videoId)) {
      continue;
    }

    await FlutterDownloader.cancel(taskId: task.taskId);
    await FlutterDownloader.remove(
      taskId: task.taskId,
      shouldDeleteContent: true,
    );
    removedTasks++;
  }

  return removedTasks;
}

Future<DownloadTask?> findTask(final VideoID videoId) async =>
    (await _allTasks())
        .firstWhereOrNull((final DownloadTask t) => _urlHasId(t.url, videoId));
