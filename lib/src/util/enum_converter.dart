import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_filex/open_filex.dart';
import '../services/download_logic/download_logic_io.dart';

DownloadStatus convertDownloadStatus(final DownloadTask? task) =>
    switch (task?.status) {
      DownloadTaskStatus.complete => DownloadStatus.complete,
      DownloadTaskStatus.running ||
      DownloadTaskStatus.enqueued =>
        DownloadStatus.running,
      _ => DownloadStatus.notStarted
    };

TryOpenResult convertOpenResult(final ResultType result) => TryOpenResult.values
    .firstWhere((final TryOpenResult t) => t.name == result.name);
