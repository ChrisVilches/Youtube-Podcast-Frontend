import 'package:url_launcher/url_launcher.dart';
import '../../types.dart';
import '../api_uri.dart';
import '../locator.dart';
import '../snackbar_service.dart';
import 'download_logic_io.dart';

class PCDownloadLogicIO extends DownloadLogicIO {
  @override
  Future<void> cleanDownload(final VideoID videoId) async {}

  @override
  Future<DownloadStatus> downloadStatus(final VideoID videoId) async =>
      DownloadStatus.notStarted;

  @override
  Future<void> startDownload(final VideoID videoId) async {
    await launchUrl(
      downloadUri(videoId),
      mode: LaunchMode.externalNonBrowserApplication,
    );
  }

  @override
  Future<bool> hasStoragePermission() async => true;

  @override
  void showSuccessMessage(final String msg, final VideoID videoId) {
    serviceLocator.get<SnackbarService>().success(msg);
  }

  @override
  Future<TryOpenResult> tryOpenFile(final VideoID videoId) async =>
      TryOpenResult.fileNotFound;
}
