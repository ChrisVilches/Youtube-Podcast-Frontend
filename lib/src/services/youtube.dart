import 'dart:convert';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/playlist.dart';
import '../models/video_item.dart';
import '../models/video_item_partial.dart';
import 'api_uri.dart';
import 'playlist_favorite.dart';

const Map<String, String> headers = <String, String>{
  'Content-type': 'application/json'
};

Future<String> prepareVideo(String youtubeVideo) async {
  final Response res =
      await post(uri('prepare?v=$youtubeVideo'), headers: headers);
  final Map<String, dynamic> body =
      jsonDecode(res.body) as Map<String, dynamic>;
  return body['message'] as String;
}

Future<VideoItem> getVideoInfo(String youtubeVideo) async {
  final Response res = await get(uri('info?v=$youtubeVideo'), headers: headers);
  final Map<String, dynamic> body =
      jsonDecode(res.body) as Map<String, dynamic>;
  final Map<String, dynamic> metadata =
      body['metadata'] as Map<String, dynamic>;
  return VideoItem.from(metadata);
}

Future<Playlist> getVideosFromPlaylist(String id) async {
  final Response res = await get(uri('playlist/$id'), headers: headers);
  final Map<String, dynamic> body =
      jsonDecode(res.body) as Map<String, dynamic>;

  final Playlist playlist = Playlist.from(body);

  // Also update the playlist name if it's saved locally.
  await PlaylistFavoriteService().updateTitle(playlist.title, playlist.id);

  return playlist;
}

Future<String> getTranscriptionContent(String videoId, String lang) async {
  final Response res = await get(uri('transcriptions?v=$videoId&lang=$lang'));
  return res.body;
}

Future<void> downloadVideo(VideoItemPartial item) async {
  // TODO: Download has to be more robust.
  await launchUrl(
    uri('download?v=${item.videoId}'),
    mode: LaunchMode.externalNonBrowserApplication,
  );
}
