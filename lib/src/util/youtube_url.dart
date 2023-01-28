String vQueryParam(String url) {
  final Uri uri = Uri.parse(url);
  return uri.queryParameters['v']!;
}

String? parsePlaylistId(String playlistUrl) {
  final Uri uri = Uri.parse(playlistUrl);
  final bool correctHost = uri.host.toLowerCase().contains('youtube.com');
  final bool correctPath = uri.path.toLowerCase() == '/playlist';

  if (!correctHost || !correctPath) {
    return null;
  }

  return uri.queryParameters['list'];
}

String? parseWatchVideoId(String playlistUrl) {
  final Uri uri = Uri.parse(playlistUrl);
  final bool correctHost = uri.host.toLowerCase().contains('youtube.com');
  final bool correctPath = uri.path.toLowerCase() == '/watch';

  if (!correctHost || !correctPath) {
    return null;
  }

  return uri.queryParameters['v'];
}

/// Basic check.
bool isVideoOrPlaylistUrl(String url) {
  return url.startsWith('https://www.youtube.com/watch?') ||
      url.startsWith('https://youtu.be/') ||
      url.startsWith('https://youtube.com/watch?') ||
      url.startsWith('https://www.youtube.com/shorts/') ||
      url.startsWith('https://m.youtube.com/watch?') ||
      url.startsWith('https://www.youtube.com/playlist?');
  // TODO: I think I have something similar (that detects URLs) somewhere else...
  //       is that code duplicated?
}

String createPlaylistUrl(String playlistId) {
  return 'https://www.youtube.com/playlist?list=$playlistId';
}
