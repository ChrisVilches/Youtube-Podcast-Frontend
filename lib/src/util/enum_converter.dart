import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_filex/open_filex.dart';
import '../services/download_logic/download_logic_io.dart';

DownloadStatus convertDownloadStatus(final DownloadTask? task) {
  final DownloadTaskStatus? status = task?.status;

  if (status == DownloadTaskStatus.complete) {
    return DownloadStatus.complete;
  }

  if (status == DownloadTaskStatus.running ||
      status == DownloadTaskStatus.enqueued) {
    return DownloadStatus.running;
  }

  return DownloadStatus.notStarted;
}

TryOpenResult convertOpenResult(final ResultType result) => TryOpenResult.values
    .firstWhere((final TryOpenResult t) => t.name == result.name);
