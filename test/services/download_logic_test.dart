import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:youtube_podcast/src/services/download_logic.dart';
import 'package:youtube_podcast/src/services/download_logic/download_logic_io.dart';

@GenerateNiceMocks(<MockSpec<dynamic>>[MockSpec<DownloadLogicIO>()])
import 'download_logic_test.mocks.dart';

const String VIDEO_ID = 'xyz123';

Future<MockDownloadLogicIO> _createMock({
  required final DownloadStatus downloadStatus,
  required final bool hasStoragePermission,
  required final TryOpenResult tryOpenCompletedFile,
}) async {
  final MockDownloadLogicIO mock = MockDownloadLogicIO();
  when(mock.hasStoragePermission())
      .thenAnswer((final _) async => hasStoragePermission);
  when(mock.downloadStatus(VIDEO_ID))
      .thenAnswer((final _) async => downloadStatus);
  when(mock.tryOpenCompletedFile(VIDEO_ID)).thenAnswer(
    (final _) async => tryOpenCompletedFile,
  );

  return mock;
}

Future<MockDownloadLogicIO> _executeMock(
  final bool assertFileOpened, {
  required final DownloadStatus downloadStatus,
  required final bool hasStoragePermission,
  required final TryOpenResult tryOpenCompletedFile,
  required final bool download,
}) async {
  final MockDownloadLogicIO ioMock = await _createMock(
    downloadStatus: downloadStatus,
    hasStoragePermission: hasStoragePermission,
    tryOpenCompletedFile: tryOpenCompletedFile,
  );

  final DownloadLogic logic = DownloadLogic(ioMock);
  final bool fileOpened = await logic.execute(VIDEO_ID, download: download);

  expect(fileOpened, assertFileOpened);

  return ioMock;
}

void main() {
  test(
      'always displays the error message and finishes when there are no storage permissions',
      () async {
    for (final bool download in <bool>[false, true]) {
      for (final DownloadStatus downloadStatus in DownloadStatus.values) {
        for (final TryOpenResult tryOpenResult in TryOpenResult.values) {
          final MockDownloadLogicIO mock = await _executeMock(
            false,
            downloadStatus: downloadStatus,
            hasStoragePermission: false,
            tryOpenCompletedFile: tryOpenResult,
            download: download,
          );

          verifyInOrder(<void>[
            mock.hasStoragePermission(),
            mock.showErrorMessage('Cannot get permission to download file'),
          ]);
          verifyNoMoreInteractions(mock);
        }
      }
    }
  });

  test(
      '(task status complete and file can be opened) file gets opened (no cleaning, no messages). Does not check if the file is corrupt or not.',
      () async {
    for (final bool download in <bool>[false, true]) {
      final MockDownloadLogicIO mock = await _executeMock(
        true,
        downloadStatus: DownloadStatus.complete,
        hasStoragePermission: true,
        tryOpenCompletedFile: TryOpenResult.done,
        download: download,
      );

      verifyInOrder(<void>[
        mock.hasStoragePermission(),
        mock.downloadStatus(VIDEO_ID),
        mock.tryOpenCompletedFile(VIDEO_ID),
        mock.onFileOpened(VIDEO_ID),
      ]);
      verifyNoMoreInteractions(mock);
    }
  });

  test(
      '(task status running) "in progress" message is shown (does not attempt to open the file)',
      () async {
    for (final bool download in <bool>[false, true]) {
      for (final TryOpenResult tryOpenResult in TryOpenResult.values) {
        final MockDownloadLogicIO mock = await _executeMock(
          false,
          downloadStatus: DownloadStatus.running,
          hasStoragePermission: true,
          tryOpenCompletedFile: tryOpenResult,
          download: download,
        );

        verifyInOrder(<void>[
          mock.hasStoragePermission(),
          mock.downloadStatus(VIDEO_ID),
          mock.showSuccessMessage('Already being downloaded', VIDEO_ID)
        ]);
        verifyNoMoreInteractions(mock);
      }
    }
  });

  group('task not started', () {
    test(
        '(with download) starts the download (does not attempt to open the file)',
        () async {
      for (final TryOpenResult tryOpenResult in TryOpenResult.values) {
        final MockDownloadLogicIO mock = await _executeMock(
          false,
          downloadStatus: DownloadStatus.notStarted,
          hasStoragePermission: true,
          tryOpenCompletedFile: tryOpenResult,
          download: true,
        );

        verifyInOrder(<void>[
          mock.hasStoragePermission(),
          mock.downloadStatus(VIDEO_ID),
          mock.cleanDownload(VIDEO_ID),
          mock.startDownload(VIDEO_ID),
          mock.showSuccessMessage('Download started', VIDEO_ID)
        ]);
        verifyNoMoreInteractions(mock);
      }
    });

    test('(without download) does nothing', () async {
      for (final TryOpenResult tryOpenResult in TryOpenResult.values) {
        final MockDownloadLogicIO mock = await _executeMock(
          false,
          downloadStatus: DownloadStatus.notStarted,
          hasStoragePermission: true,
          tryOpenCompletedFile: tryOpenResult,
          download: false,
        );

        verifyInOrder(<void>[
          mock.hasStoragePermission(),
          mock.downloadStatus(VIDEO_ID),
        ]);
        verifyNoMoreInteractions(mock);
      }
    });
  });

  group('task status is complete, but cannot open the file', () {
    Future<MockDownloadLogicIO> executeCompleteMock(
      final TryOpenResult tryOpenResult, {
      final bool download = true,
    }) async {
      assert(tryOpenResult != TryOpenResult.done);
      return _executeMock(
        false,
        downloadStatus: DownloadStatus.complete,
        hasStoragePermission: true,
        tryOpenCompletedFile: tryOpenResult,
        download: download,
      );
    }

    test(TryOpenResult.error, () async {
      for (final bool download in <bool>[false, true]) {
        final MockDownloadLogicIO mock = await executeCompleteMock(
          TryOpenResult.error,
          download: download,
        );
        verifyInOrder(<void>[
          mock.hasStoragePermission(),
          mock.downloadStatus(VIDEO_ID),
          mock.tryOpenCompletedFile(VIDEO_ID),
          mock.showErrorMessage('Unexpected error')
        ]);
        verifyNoMoreInteractions(mock);
      }
    });

    test(
        'starts download when the file is not found (without error message shown)',
        () async {
      final MockDownloadLogicIO mock =
          await executeCompleteMock(TryOpenResult.fileNotFound);
      verifyInOrder(<void>[
        mock.hasStoragePermission(),
        mock.downloadStatus(VIDEO_ID),
        mock.tryOpenCompletedFile(VIDEO_ID),
        mock.cleanDownload(VIDEO_ID),
        mock.startDownload(VIDEO_ID),
        mock.showSuccessMessage('Download started', VIDEO_ID)
      ]);
      verifyNoMoreInteractions(mock);
    });

    test(
        '(without download, file not found) stops after the "not found" error (without error message shown)',
        () async {
      final MockDownloadLogicIO mock = await executeCompleteMock(
        TryOpenResult.fileNotFound,
        download: false,
      );
      verifyInOrder(<void>[
        mock.hasStoragePermission(),
        mock.downloadStatus(VIDEO_ID),
        mock.tryOpenCompletedFile(VIDEO_ID),
      ]);
      verifyNoMoreInteractions(mock);
    });

    test(TryOpenResult.noAppToOpen, () async {
      final MockDownloadLogicIO mock = await executeCompleteMock(
        TryOpenResult.noAppToOpen,
      );

      verifyInOrder(<void>[
        mock.hasStoragePermission(),
        mock.downloadStatus(VIDEO_ID),
        mock.tryOpenCompletedFile(VIDEO_ID),
        mock.showErrorMessage('File exists, but cannot be opened')
      ]);
      verifyNoMoreInteractions(mock);
    });

    test(TryOpenResult.permissionDenied, () async {
      final MockDownloadLogicIO mock = await executeCompleteMock(
        TryOpenResult.permissionDenied,
      );

      verifyInOrder(<void>[
        mock.hasStoragePermission(),
        mock.downloadStatus(VIDEO_ID),
        mock.tryOpenCompletedFile(VIDEO_ID),
        mock.showErrorMessage('You do not have permission to open the file')
      ]);
      verifyNoMoreInteractions(mock);
    });
  });
}
