import 'package:flutter_downloader/flutter_downloader.dart';
import 'locator.dart';
import 'snackbar_service.dart';

Future<List<DownloadTask>> allTasks() async {
  return await FlutterDownloader.loadTasks() ?? List<DownloadTask>.empty();
}

Future<void> clearAllDownloadTaskData({
  required bool shouldDeleteContent,
}) async {
  final List<DownloadTask> tasks = await allTasks();

  final int prevCount = tasks.length;

  for (final DownloadTask t in tasks) {
    await FlutterDownloader.remove(
      taskId: t.taskId,
      shouldDeleteContent: shouldDeleteContent,
    );
  }

  assert((await allTasks()).isEmpty);
  serviceLocator.get<SnackbarService>().success('Removed $prevCount items');
}
