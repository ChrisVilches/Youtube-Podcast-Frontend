import '../types.dart';
import 'download_logic/download_logic_io.dart';

class _Result {
  const _Result(this.msg, this.success);
  final String? msg;
  final bool success;
}

class DownloadLogic {
  DownloadLogic(this._io);
  final DownloadLogicIO _io;

  Future<_Result> _downloadVideo(
    final VideoID videoId,
  ) async {
    if (!(await _io.hasStoragePermission())) {
      return const _Result('Cannot get permission to download file', false);
    }

    final DownloadStatus status = await _io.downloadStatus(videoId);

    if (status == DownloadStatus.running) {
      return const _Result('Already being downloaded', true);
    }

    if (status == DownloadStatus.complete) {
      switch (await _io.tryOpenCompletedFile(videoId)) {
        case TryOpenResult.done:
          _io.onFileOpened(videoId);
          return const _Result(null, true);
        case TryOpenResult.fileNotFound:
          // Should download the file in this case.
          break;
        case TryOpenResult.noAppToOpen:
          return const _Result('File exists, but cannot be opened', false);
        case TryOpenResult.permissionDenied:
          return const _Result(
            'You do not have permission to open the file',
            false,
          );
        case TryOpenResult.error:
          return const _Result('Unexpected error', false);
      }
    }

    // Pre-cleaning to remove canceled/failed tasks.
    await _io.cleanDownload(videoId);

    await _io.startDownload(videoId);

    return const _Result('Download started', true);
  }

  Future<void> execute(
    final VideoID videoId,
    final bool canBeDownloaded,
  ) async {
    assert(!videoId.contains('http'));

    if (!canBeDownloaded) {
      _io.showErrorMessage('Video cannot be downloaded');
      return;
    }

    final _Result result = await _downloadVideo(videoId);

    final String? msg = result.msg;

    if (result.success) {
      if (msg != null) {
        _io.showSuccessMessage(msg, videoId);
      }
    } else {
      _io.showErrorMessage(msg!);
    }
  }
}
