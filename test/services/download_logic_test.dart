import 'package:test/test.dart';
import 'package:youtube_podcast/src/services/download_logic.dart';
import 'package:youtube_podcast/src/services/download_logic/download_logic_io.dart';
import 'package:youtube_podcast/src/types.dart';

// TODO: This test would be a bit cleaner if the trace where a tuple (Symbol, arg).
//       I think arg is always a string (must confirm).

class DownloadLogicIOMock implements DownloadLogicIO {
  DownloadLogicIOMock({
    required this.downloadStatusValue,
    required this.hasStoragePermissionValue,
    required this.tryOpenCompletedFileValue,
  });

  final List<String> trace = <String>[];
  final DownloadStatus downloadStatusValue;
  final bool hasStoragePermissionValue;
  final TryOpenResult tryOpenCompletedFileValue;

  @override
  Future<void> cleanDownload(final VideoID _) async => trace.add('clean');

  @override
  Future<DownloadStatus> downloadStatus(final VideoID _) async =>
      downloadStatusValue;

  @override
  Future<void> startDownload(final VideoID _) async => trace.add('started');

  @override
  Future<bool> hasStoragePermission() async => hasStoragePermissionValue;

  @override
  void showErrorMessage(final String msg) => trace.add('show error: $msg');

  @override
  void showSuccessMessage(final String msg, final VideoID _) =>
      trace.add('show success: $msg');

  @override
  Future<TryOpenResult> tryOpenCompletedFile(final VideoID videoId) async {
    trace.add('file attempted to be opened');
    return tryOpenCompletedFileValue;
  }

  @override
  void onFileOpened(final VideoID videoId) => trace.add('file opened');
}

Future<List<String>> _getTrace(
  final bool assertFileOpened, {
  required final DownloadStatus downloadStatus,
  required final bool hasStoragePermission,
  required final TryOpenResult tryOpenCompletedFile,
  required final bool download,
}) async {
  final DownloadLogicIOMock io = DownloadLogicIOMock(
    downloadStatusValue: downloadStatus,
    hasStoragePermissionValue: hasStoragePermission,
    tryOpenCompletedFileValue: tryOpenCompletedFile,
  );
  final DownloadLogic logic = DownloadLogic(io);
  final bool fileOpened = await logic.execute('xyz', download: download);

  expect(fileOpened, assertFileOpened);

  return io.trace;
}

void main() {
  test(
      'always displays the error message and finishes when there are no storage permissions',
      () async {
    for (final bool download in <bool>[false, true]) {
      for (final DownloadStatus downloadStatus in DownloadStatus.values) {
        for (final TryOpenResult tryOpenResult in TryOpenResult.values) {
          final List<String> trace = await _getTrace(
            false,
            downloadStatus: downloadStatus,
            hasStoragePermission: false,
            tryOpenCompletedFile: tryOpenResult,
            download: download,
          );
          expect(trace, <String>[
            'show error: Cannot get permission to download file',
          ]);
        }
      }
    }
  });

  test(
      '(task status complete and file can be opened) file gets opened (no cleaning, no messages). Does not check if the file is corrupt or not.',
      () async {
    for (final bool download in <bool>[false, true]) {
      final List<String> trace = await _getTrace(
        true,
        downloadStatus: DownloadStatus.complete,
        hasStoragePermission: true,
        tryOpenCompletedFile: TryOpenResult.done,
        download: download,
      );
      expect(trace, <String>[
        'file attempted to be opened',
        'file opened',
      ]);
    }
  });

  test(
      '(task status running) "in progress" message is shown (does not attempt to open the file)',
      () async {
    for (final bool download in <bool>[false, true]) {
      for (final TryOpenResult tryOpenResult in TryOpenResult.values) {
        final List<String> trace = await _getTrace(
          false,
          downloadStatus: DownloadStatus.running,
          hasStoragePermission: true,
          tryOpenCompletedFile: tryOpenResult,
          download: download,
        );
        expect(trace, <String>[
          'show success: Already being downloaded',
        ]);
      }
    }
  });

  group('task not started', () {
    test(
        '(with download) starts the download (does not attempt to open the file)',
        () async {
      for (final TryOpenResult tryOpenResult in TryOpenResult.values) {
        final List<String> trace = await _getTrace(
          false,
          downloadStatus: DownloadStatus.notStarted,
          hasStoragePermission: true,
          tryOpenCompletedFile: tryOpenResult,
          download: true,
        );
        expect(trace, <String>[
          'clean',
          'started',
          'show success: Download started',
        ]);
      }
    });

    test('(without download) does nothing', () async {
      for (final TryOpenResult tryOpenResult in TryOpenResult.values) {
        final List<String> trace = await _getTrace(
          false,
          downloadStatus: DownloadStatus.notStarted,
          hasStoragePermission: true,
          tryOpenCompletedFile: tryOpenResult,
          download: false,
        );
        expect(trace, <String>[]);
      }
    });
  });

  group('task status is complete, but cannot open the file', () {
    Future<List<String>> getTraceFor(
      final TryOpenResult tryOpenResult, {
      final bool download = true,
    }) async {
      assert(tryOpenResult != TryOpenResult.done);
      return _getTrace(
        false,
        downloadStatus: DownloadStatus.complete,
        hasStoragePermission: true,
        tryOpenCompletedFile: tryOpenResult,
        download: download,
      );
    }

    test(TryOpenResult.error, () async {
      expect(await getTraceFor(TryOpenResult.error), <String>[
        'file attempted to be opened',
        'show error: Unexpected error',
      ]);
    });

    test(
        'starts download when the file is not found (without error message shown)',
        () async {
      expect(await getTraceFor(TryOpenResult.fileNotFound), <String>[
        'file attempted to be opened',
        'clean',
        'started',
        'show success: Download started',
      ]);
    });

    test(
        '(without download) stops after the "not found" error (without error message shown)',
        () async {
      expect(
          await getTraceFor(TryOpenResult.fileNotFound, download: false),
          <String>[
            'file attempted to be opened',
          ]);
    });

    test(TryOpenResult.noAppToOpen, () async {
      expect(await getTraceFor(TryOpenResult.noAppToOpen), <String>[
        'file attempted to be opened',
        'show error: File exists, but cannot be opened',
      ]);
    });

    test(TryOpenResult.permissionDenied, () async {
      expect(await getTraceFor(TryOpenResult.permissionDenied), <String>[
        'file attempted to be opened',
        'show error: You do not have permission to open the file',
      ]);
    });
  });
}
