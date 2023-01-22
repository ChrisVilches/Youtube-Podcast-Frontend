import 'dart:io';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/playlist.dart';
import '../models/transcription_entry.dart';
import '../models/video_item.dart';
import 'android_download.dart';
import 'api_uri.dart';
import 'http_error.dart';
import 'locator.dart';
import 'playlist_favorite.dart';

const Map<String, String> headers = <String, String>{
  'Content-type': 'application/json'
};

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
  await serviceLocator
      .get<PlaylistFavoriteService>()
      .updateMetadata(playlist.title, playlist.author, playlist.id);

  return playlist;
}

Future<List<TranscriptionEntry>> getTranscriptionContent(
  String videoId,
  String lang,
) async {
  final Response res =
      await get(uri('transcriptions?v=$videoId&lang=$lang'), headers: headers);

  // TODO: This should be applied to all other API calls.
  final Map<String, dynamic> body = toJson(res);

  return (body['transcription'] as List<dynamic>)
      .map((dynamic o) => TranscriptionEntry.from(o as Map<String, dynamic>))
      .toList();
}

Future<DispatchDownloadResult> downloadVideoBrowser(Uri videoUri) async {
  await launchUrl(
    videoUri,
    mode: LaunchMode.externalNonBrowserApplication,
  );

  return DispatchDownloadResult.dispatchedCorrectly;
}

// TODO: Move this and it's conversion to String message to a different file.
enum DispatchDownloadResult {
  dispatchedCorrectly,
  inProgress,
  permissionError,
  canOpenExisting,
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
      return 'Task is in an unhandled status (cancelled, failed, pause)';
    case DispatchDownloadResult.canOpenExisting:
      return null;
  }
}

Future<DispatchDownloadResult> downloadVideo(String youtubeVideo) async {
  final Uri videoUri = uri('download?v=$youtubeVideo');

  if (Platform.isAndroid) {
    return serviceLocator.get<AndroidDownloadService>().downloadVideo(videoUri);
  } else {
    return downloadVideoBrowser(videoUri);
  }
}

/*
// TODO: Must dispose. Somewhere. (Probably never, since this is not running on a Widget)
@override
void dispose() {
  IsolateNameServer.removePortNameMapping('downloader_send_port');
  super.dispose();
}
*/
