import 'package:collection/collection.dart';

String? parseUsername(final String username) {
  if (username.startsWith('@')) {
    return username.substring(1);
  }
  return null;
}

String? parsePlaylistId(final String url) {
  final Uri uri = Uri.parse(url);
  final bool correctHost = uri.host.toLowerCase().contains('youtube.com');
  final bool correctPath = uri.path.toLowerCase() == '/playlist';

  if (!correctHost || !correctPath) {
    return null;
  }

  return uri.queryParameters['list'];
}

const List<String> YOUTUBE_HOSTS = <String>[
  'www.youtube.com',
  'm.youtube.com',
  'youtube.com'
];

String? parseWatchVideoId(final String url) {
  final Uri uri = Uri.parse(url);

  final String host = uri.host.toLowerCase();

  if (YOUTUBE_HOSTS.contains(host)) {
    final String? firstPath = uri.pathSegments.firstOrNull?.toLowerCase();

    if (firstPath == 'watch') {
      return uri.queryParameters['v'];
    }

    if (firstPath == 'embed' || firstPath == 'shorts') {
      return uri.pathSegments.elementAtOrNull(1);
    }
  } else if (host == 'youtu.be') {
    return uri.pathSegments.firstOrNull;
  }

  return null;
}

bool isYoutubeContentSearchable(final String s) {
  return parseUsername(s) != null ||
      parsePlaylistId(s) != null ||
      parseWatchVideoId(s) != null;
}

String createPlaylistUrl(final String playlistId) {
  return 'https://www.youtube.com/playlist?list=$playlistId';
}
