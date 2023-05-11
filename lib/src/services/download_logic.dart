import '../types.dart';
import 'download_logic/download_logic_io.dart';

// TODO: This is very complex. Should simplify more, and test more.

enum _Result { error, downloadFile, success }

class DownloadLogic {
  DownloadLogic(this._io);
  final DownloadLogicIO _io;

  final Map<TryOpenResult, String> _errorMap = <TryOpenResult, String>{
    TryOpenResult.error: 'Unexpected error',
    TryOpenResult.permissionDenied:
        'You do not have permission to open the file',
    TryOpenResult.noAppToOpen: 'File exists, but cannot be opened'
  };

  Future<(_Result, String?)> _tryOpenFile(final VideoID videoId) async {
    final TryOpenResult result = await _io.tryOpenFile(videoId);

    if (result == TryOpenResult.fileNotFound) {
      return (_Result.downloadFile, null);
    }

    if (result == TryOpenResult.done) {
      _io.onFileOpened(videoId);
      return (_Result.success, null);
    }

    return (_Result.error, _errorMap[result]);
  }

  Future<(_Result, String?)> _preCheck(final VideoID videoId) async {
    if (!(await _io.hasStoragePermission())) {
      return (_Result.error, 'Cannot get permission to download file');
    }

    switch (await _io.downloadStatus(videoId)) {
      case DownloadStatus.notStarted:
        return (_Result.downloadFile, null);
      case DownloadStatus.running:
        return (_Result.success, 'Already being downloaded');
      case DownloadStatus.complete:
        return _tryOpenFile(videoId);
    }
  }

  void _showMessages(
    final _Result type,
    final String? msg,
    final VideoID videoId,
  ) {
    if (msg == null) {
      return;
    }

    if (type == _Result.success) {
      _io.showSuccessMessage(msg, videoId);
    } else if (type == _Result.error) {
      _io.showErrorMessage(msg);
    }
  }

  Future<void> _startDownload(final VideoID videoId) async {
    await _io.cleanDownload(videoId);
    await _io.startDownload(videoId);
  }

  /// This function has several responsibilities:
  /// * Checks storage permissions (shows a message if it fails, and finishes).
  /// * Checks whether the file is already being downloaded (if it is, show a message and finish).
  /// * If the task is not `DownloadStatus.complete`, a download will start, but only if `download` was set to `true`
  /// * If the task is `DownloadStatus.complete`, it will be attempted to be opened, which may fail (and show an error
  /// if it does).
  /// * It returns `false` if the file needs to be downloaded, or if the call started the download (note: it
  /// returns `true` if the file could be opened or if it's currently being downloaded).
  Future<bool> execute(
    final VideoID videoId, {
    required final bool download,
  }) async {
    assert(!videoId.contains('http://'));
    assert(!videoId.contains('https://'));

    final (_Result type, String? msg) = await _preCheck(videoId);

    if (type != _Result.downloadFile) {
      _showMessages(type, msg, videoId);
      return type == _Result.success;
    }

    if (download) {
      await _startDownload(videoId);
      _io.showSuccessMessage('Download started', videoId);
    }

    return false;
  }
}
