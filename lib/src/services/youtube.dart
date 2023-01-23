import 'dart:io';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/playlist.dart';
import '../models/transcription_entry.dart';
import '../models/video_item.dart';
import '../models/video_item_partial.dart';
import '../util/sleep.dart';
import 'android_download.dart';
import 'api_uri.dart';
import 'dispatch_download_result.dart';
import 'favorite_playlist_service.dart';
import 'http_error.dart';
import 'locator.dart';

const Map<String, String> headers = <String, String>{
  'Content-type': 'application/json'
};

Future<VideoItem> getVideoInfo(VideoID videoId) async {
  final Response res = await get(uri('info?v=$videoId'), headers: headers);
  final Map<String, dynamic> body = toJson(res);
  final Map<String, dynamic> metadata =
      body['metadata'] as Map<String, dynamic>;
  await sleep(1);
  return VideoItem.fromJson(metadata);
}

Future<Playlist> getVideosFromPlaylist(String id) async {
  final Response res = await get(uri('playlist/$id'), headers: headers);
  final Map<String, dynamic> body = toJson(res);

  final Playlist playlist = Playlist.fromJson(body);

  // Also update the playlist name if it's saved locally.
  await serviceLocator
      .get<FavoritePlaylistService>()
      .updateMetadata(playlist.title, playlist.author, playlist.id);

  return playlist;
}

Future<List<TranscriptionEntry>> getTranscriptionContent(
  VideoID videoId,
  String lang,
) async {
  final Response res =
      await get(uri('transcriptions?v=$videoId&lang=$lang'), headers: headers);

  final Map<String, dynamic> body = toJson(res);

  return (body['transcription'] as List<dynamic>)
      .map(
        (dynamic o) => TranscriptionEntry.fromJson(o as Map<String, dynamic>),
      )
      .toList();
}

Future<DispatchDownloadResult> downloadVideoBrowser(VideoID videoId) async {
  assert(!videoId.contains('http'));
  await launchUrl(
    downloadUri(videoId),
    mode: LaunchMode.externalNonBrowserApplication,
  );

  return DispatchDownloadResult.dispatchedCorrectly;
}

Future<DispatchDownloadResult> downloadVideo(VideoID videoId) async {
  if (Platform.isAndroid) {
    return serviceLocator.get<AndroidDownloadService>().downloadVideo(videoId);
  } else {
    return downloadVideoBrowser(videoId);
  }
}
