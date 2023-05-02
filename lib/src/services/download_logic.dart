import '../types.dart';
import 'download_logic/download_logic_io.dart';

// TODO: This is very complex. Should simplify more, and test more.

enum _CommandType { error, downloadFile, success }

class _Command {
  const _Command(this.type, this.msg);
  final String? msg;
  final _CommandType type;
}

class DownloadLogic {
  DownloadLogic(this._io);
  final DownloadLogicIO _io;

  final Map<TryOpenResult, String> _errorMap = <TryOpenResult, String>{
    TryOpenResult.error: 'Unexpected error',
    TryOpenResult.permissionDenied:
        'You do not have permission to open the file',
    TryOpenResult.noAppToOpen: 'File exists, but cannot be opened'
  };

  Future<_Command> _tryOpenFile(final VideoID videoId) async {
    final TryOpenResult result = await _io.tryOpenFile(videoId);

    if (result == TryOpenResult.fileNotFound) {
      return const _Command(_CommandType.downloadFile, null);
    }

    if (result == TryOpenResult.done) {
      _io.onFileOpened(videoId);
      return const _Command(_CommandType.success, null);
    }

    return _Command(_CommandType.error, _errorMap[result]);
  }

  Future<_Command> _preCheck(final VideoID videoId) async {
    if (!(await _io.hasStoragePermission())) {
      return const _Command(
        _CommandType.error,
        'Cannot get permission to download file',
      );
    }

    switch (await _io.downloadStatus(videoId)) {
      case DownloadStatus.notStarted:
        return const _Command(_CommandType.downloadFile, null);
      case DownloadStatus.running:
        return const _Command(
          _CommandType.success,
          'Already being downloaded',
        );
      case DownloadStatus.complete:
        return _tryOpenFile(videoId);
    }
  }

  void _showMessages(final _Command command, final VideoID videoId) {
    if (command.msg == null) {
      return;
    }

    if (command.type == _CommandType.success) {
      _io.showSuccessMessage(command.msg!, videoId);
    } else if (command.type == _CommandType.error) {
      _io.showErrorMessage(command.msg!);
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

    final _Command command = await _preCheck(videoId);

    if (command.type != _CommandType.downloadFile) {
      _showMessages(command, videoId);
      return command.type == _CommandType.success;
    }

    if (download) {
      await _startDownload(videoId);
      _io.showSuccessMessage('Download started', videoId);
    }

    return false;
  }
}
