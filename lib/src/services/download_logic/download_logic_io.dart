import 'package:flutter/foundation.dart';
import '../../types.dart';
import '../locator.dart';
import '../snackbar_service.dart';

enum TryOpenResult {
  done,
  fileNotFound,
  noAppToOpen,
  permissionDenied,
  error,
}

enum DownloadStatus { notStarted, running, complete }

// TODO: Document and explain well this class??
abstract class DownloadLogicIO {
  Future<DownloadStatus> downloadStatus(final VideoID videoId);
  Future<bool> hasStoragePermission();
  Future<void> startDownload(final VideoID videoId);
  Future<void> cleanDownload(final VideoID videoId);
  Future<TryOpenResult> tryOpenCompletedFile(final VideoID videoId);

  void onFileOpened(final VideoID videoId) {
    debugPrint('File was opened (id: $videoId)');
  }

  void showSuccessMessage(final String msg, final VideoID videoId);

  void showErrorMessage(final String msg) {
    serviceLocator.get<SnackbarService>().danger(msg);
  }
}
