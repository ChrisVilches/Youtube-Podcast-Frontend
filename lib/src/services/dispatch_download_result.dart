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
      return 'Task is in an unhandled status (pause)';
    case DispatchDownloadResult.cannotOpenExisting:
      return 'File exists, but cannot be opened';
    case DispatchDownloadResult.canOpenExisting:
      return null;
  }
}
