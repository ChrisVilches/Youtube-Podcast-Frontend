import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/video_item_partial.dart';
import 'api_uri.dart';
import 'download_service.dart';

class PcDownloadService implements DownloadService {
  @override
  Future<void> cancelVideoDownload(final VideoID videoId) async {
    debugPrint('Canceled a download on PC version (nothing happened)');
  }

  @override
  Future<DispatchDownloadResult> downloadVideo(final VideoID videoId) async {
    assert(!videoId.contains('http'));
    await launchUrl(
      downloadUri(videoId),
      mode: LaunchMode.externalNonBrowserApplication,
    );

    return DispatchDownloadResult.dispatchedCorrectly;
  }

  @override
  bool canCancelDownload() {
    return false;
  }
}
