import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_filex/open_filex.dart';
import 'package:test/test.dart';
import 'package:youtube_podcast/src/services/download_logic/download_logic_io.dart';
import 'package:youtube_podcast/src/util/enum_converter.dart';

DownloadTask createTask(final DownloadTaskStatus status) => DownloadTask(
      taskId: 'taskId',
      status: status,
      progress: 50,
      url: 'https://www.some-url.com',
      filename: 'some-file',
      savedDir: 'saved/dir/path',
      timeCreated: 500,
      allowCellular: true,
    );

void main() {
  group(convertDownloadStatus, () {
    test('maps the status values from FlutterDownloader to the ones I use',
        () async {
      expect(
        convertDownloadStatus(createTask(DownloadTaskStatus.canceled)),
        DownloadStatus.notStarted,
      );
      expect(
        convertDownloadStatus(createTask(DownloadTaskStatus.complete)),
        DownloadStatus.complete,
      );
      expect(
        convertDownloadStatus(createTask(DownloadTaskStatus.enqueued)),
        DownloadStatus.running,
      );
      expect(
        convertDownloadStatus(createTask(DownloadTaskStatus.failed)),
        DownloadStatus.notStarted,
      );
      expect(
        convertDownloadStatus(createTask(DownloadTaskStatus.paused)),
        DownloadStatus.notStarted,
      );
      expect(
        convertDownloadStatus(createTask(DownloadTaskStatus.running)),
        DownloadStatus.running,
      );
      expect(
        convertDownloadStatus(createTask(DownloadTaskStatus.undefined)),
        DownloadStatus.notStarted,
      );
    });
  });

  group(convertOpenResult, () {
    test('converts the values correctly', () {
      expect(convertOpenResult(ResultType.done), TryOpenResult.done);
      expect(convertOpenResult(ResultType.error), TryOpenResult.error);
      expect(
        convertOpenResult(ResultType.fileNotFound),
        TryOpenResult.fileNotFound,
      );
      expect(
        convertOpenResult(ResultType.noAppToOpen),
        TryOpenResult.noAppToOpen,
      );
      expect(
        convertOpenResult(ResultType.permissionDenied),
        TryOpenResult.permissionDenied,
      );
    });
  });
}
