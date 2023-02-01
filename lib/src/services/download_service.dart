import '../models/video_item_partial.dart';

enum DispatchDownloadResult {
  dispatchedCorrectly,
  inProgress,
  permissionError,
  canOpenExisting,
  cannotOpenExisting,
  unhandledError
}

String? dispatchDownloadResultMessage(DispatchDownloadResult value) {
  switch (value) {
    case DispatchDownloadResult.dispatchedCorrectly:
      return 'Download started';
    case DispatchDownloadResult.inProgress:
      return 'Already being downloaded';
    case DispatchDownloadResult.permissionError:
      return 'Cannot get permission to download file';
    case DispatchDownloadResult.unhandledError:
      return 'Unexpected error';
    case DispatchDownloadResult.cannotOpenExisting:
      return 'File exists, but cannot be opened';
    case DispatchDownloadResult.canOpenExisting:
      return null;
  }
}

const List<DispatchDownloadResult> _SUCCESS_RESULTS = <DispatchDownloadResult>[
  DispatchDownloadResult.dispatchedCorrectly,
  DispatchDownloadResult.inProgress,
  DispatchDownloadResult.canOpenExisting
];

bool dispatchDownloadResultSuccess(DispatchDownloadResult value) {
  return _SUCCESS_RESULTS.contains(value);
}

abstract class DownloadService {
  Future<DispatchDownloadResult> downloadVideo(VideoID videoId);
  Future<void> cancelVideoDownload(VideoID videoId);
  bool canCancelDownload();
}
