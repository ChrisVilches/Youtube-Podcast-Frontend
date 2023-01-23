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

String createPlaylistUrl(String playlistId) {
  return 'https://www.youtube.com/playlist?list=$playlistId';
}
