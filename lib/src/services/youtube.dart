import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/playlist.dart';
import '../models/transcription_entry.dart';
import '../models/video_item.dart';
import '../models/video_item_partial.dart';
import 'api_uri.dart';
import 'http_error.dart';
import 'playlist_favorite.dart';

const Map<String, String> headers = <String, String>{
  'Content-type': 'application/json'
};

class DownloadResponse {
  DownloadResponse(this.canDownload, this.progress);

  final bool canDownload;
  final int progress;
}

Future<DownloadResponse> prepareVideo(String youtubeVideo) async {
  final Response res =
      await post(uri('prepare?v=$youtubeVideo'), headers: headers);
  final Map<String, dynamic> body = toJson(res);

  return DownloadResponse(body['canDownload'] as bool, body['progress'] as int);
}

Future<VideoItem> getVideoInfo(String youtubeVideo) async {
  final Response res = await get(uri('info?v=$youtubeVideo'), headers: headers);
  final Map<String, dynamic> body = toJson(res);
  final Map<String, dynamic> metadata =
      body['metadata'] as Map<String, dynamic>;
  return VideoItem.from(metadata);
}

Future<Playlist> getVideosFromPlaylist(String id) async {
  final Response res = await get(uri('playlist/$id'), headers: headers);
  final Map<String, dynamic> body = toJson(res);

  final Playlist playlist = Playlist.from(body);

  // Also update the playlist name if it's saved locally.
  await PlaylistFavoriteService().updateTitle(playlist.title, playlist.id);

  return playlist;
}

Future<List<TranscriptionEntry>> getTranscriptionContent(
    String videoId, String lang) async {
  final Response res =
      await get(uri('transcriptions?v=$videoId&lang=$lang'), headers: headers);

  // TODO: This should be applied to all other API calls.
  final Map<String, dynamic> body = toJson(res);

  print(body['transcription']);

  return (body['transcription'] as List<dynamic>)
      .map((dynamic o) => TranscriptionEntry.from(o as Map<String, dynamic>))
      .toList();
}

Future<void> downloadVideo(VideoItemPartial item) async {
  // TODO: Download has to be more robust.
  await launchUrl(
    uri('download?v=${item.videoId}'),
    mode: LaunchMode.externalNonBrowserApplication,
  );
}
