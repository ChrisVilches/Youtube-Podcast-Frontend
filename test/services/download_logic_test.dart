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
  Future<void> cleanDownload(final VideoID _) async {
    trace.add('clean');
  }

  @override
  Future<DownloadStatus> downloadStatus(final VideoID _) async {
    return downloadStatusValue;
  }

  @override
  Future<void> startDownload(final VideoID _) async {
    trace.add('started');
  }

  @override
  Future<bool> hasStoragePermission() async {
    return hasStoragePermissionValue;
  }

  @override
  void showErrorMessage(final String msg) {
    trace.add('show error: $msg');
  }

  @override
  void showSuccessMessage(final String msg, final VideoID _) {
    trace.add('show success: $msg');
  }

  @override
  Future<TryOpenResult> tryOpenCompletedFile(final VideoID videoId) async {
    trace.add('file attempted to be opened');
    return tryOpenCompletedFileValue;
  }

  @override
  void onFileOpened(final VideoID videoId) {
    trace.add('file opened');
  }
}

Future<List<String>> _getTrace({
  required final DownloadStatus downloadStatus,
  required final bool hasStoragePermission,
  required final TryOpenResult tryOpenCompletedFile,
}) async {
  final DownloadLogicIOMock io = DownloadLogicIOMock(
    downloadStatusValue: downloadStatus,
    hasStoragePermissionValue: hasStoragePermission,
    tryOpenCompletedFileValue: tryOpenCompletedFile,
  );
  final DownloadLogic logic = DownloadLogic(io);
  await logic.execute('xyz', true);
  return io.trace;
}

void main() {
  test('when video cannot be downloaded, an error message is shown', () async {
    final DownloadLogicIOMock io = DownloadLogicIOMock(
      downloadStatusValue: DownloadStatus.complete,
      hasStoragePermissionValue: true,
      tryOpenCompletedFileValue: TryOpenResult.done,
    );
    final DownloadLogic logic = DownloadLogic(io);
    await logic.execute('xyz', false);
    expect(io.trace, <String>['show error: Video cannot be downloaded']);
  });

  test(
      'always displays the error message and finishes when there are no storage permissions',
      () async {
    for (final DownloadStatus downloadStatus in DownloadStatus.values) {
      for (final TryOpenResult tryOpenResult in TryOpenResult.values) {
        final List<String> trace = await _getTrace(
          downloadStatus: downloadStatus,
          hasStoragePermission: false,
          tryOpenCompletedFile: tryOpenResult,
        );
        expect(trace, <String>[
          'show error: Cannot get permission to download file',
        ]);
      }
    }
  });

  test(
      '(task status complete and file can be opened) file gets opened (no cleaning, no messages). Does not check if the file is corrupt or not.',
      () async {
    final List<String> trace = await _getTrace(
      downloadStatus: DownloadStatus.complete,
      hasStoragePermission: true,
      tryOpenCompletedFile: TryOpenResult.done,
    );
    expect(trace, <String>[
      'file attempted to be opened',
      'file opened',
    ]);
  });

  test(
      '(task status running) "in progress" message is shown (does not attempt to open the file)',
      () async {
    for (final TryOpenResult tryOpenResult in TryOpenResult.values) {
      final List<String> trace = await _getTrace(
        downloadStatus: DownloadStatus.running,
        hasStoragePermission: true,
        tryOpenCompletedFile: tryOpenResult,
      );
      expect(trace, <String>[
        'show success: Already being downloaded',
      ]);
    }
  });

  test(
      '(task status not started) starts the download (does not attempt to open the file)',
      () async {
    for (final TryOpenResult tryOpenResult in TryOpenResult.values) {
      final List<String> trace = await _getTrace(
        downloadStatus: DownloadStatus.notStarted,
        hasStoragePermission: true,
        tryOpenCompletedFile: tryOpenResult,
      );
      expect(trace, <String>[
        'clean',
        'started',
        'show success: Download started',
      ]);
    }
  });

  group('task status is complete, but cannot open the file', () {
    Future<List<String>> getTraceFor(final TryOpenResult tryOpenResult) async {
      assert(tryOpenResult != TryOpenResult.done);
      return _getTrace(
        downloadStatus: DownloadStatus.complete,
        hasStoragePermission: true,
        tryOpenCompletedFile: tryOpenResult,
      );
    }

    test(TryOpenResult.error, () async {
      expect(await getTraceFor(TryOpenResult.error), <String>[
        'file attempted to be opened',
        'show error: Unexpected error',
      ]);
    });

    test('starts download when the file is not found', () async {
      expect(await getTraceFor(TryOpenResult.fileNotFound), <String>[
        'file attempted to be opened',
        'clean',
        'started',
        'show success: Download started',
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
