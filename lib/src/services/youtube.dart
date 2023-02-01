import 'package:ffcache/ffcache.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import '../models/playlist.dart';
import '../models/transcription_entry.dart';
import '../models/video_item.dart';
import '../models/video_item_partial.dart';
import '../util/sleep.dart';
import 'api_uri.dart';
import 'favorite_playlist_service.dart';
import 'http_error.dart';
import 'locator.dart';

const Map<String, String> _headers = <String, String>{
  'Content-type': 'application/json'
};

Future<VideoItem> getVideoInfo(VideoID videoId) async {
  final Response res = await get(uri('info?v=$videoId'), headers: _headers);
  final Map<String, dynamic> body = toJson(res);
  final Map<String, dynamic> metadata =
      body['metadata'] as Map<String, dynamic>;
  await sleep(1);
  return VideoItem.fromJson(metadata);
}

Future<Playlist> getVideosFromPlaylist(String id) async {
  final Response res = await get(uri('playlist/$id'), headers: _headers);
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
      await get(uri('transcriptions?v=$videoId&lang=$lang'), headers: _headers);

  final Map<String, dynamic> body = toJson(res);

  return (body['transcription'] as List<dynamic>)
      .map(
        (dynamic o) => TranscriptionEntry.fromJson(o as Map<String, dynamic>),
      )
      .toList();
}

// TODO: Not very good. It doesn't handle all formats.
String contentDispositionFilename(String header) {
  return Uri.decodeComponent(header.substring(29));
}

Future<String> videoFileName(VideoID videoId) async {
  final FFCache cache = serviceLocator.get<FFCache>();
  final String? cached = await cache.getString(videoId);
  if (cached != null) {
    debugPrint('Obtaining title. Cache hit');
    return cached;
  }
  debugPrint('Obtaining title. Cache miss (must use HEAD method)');

  final Response res =
      await head(uri('download?v=$videoId'), headers: _headers);

  final String contentDispositionHeader = res.headers['content-disposition']!;
  debugPrint(contentDispositionHeader);

  final String fileName = contentDispositionFilename(contentDispositionHeader);

  await cache.setString(videoId, fileName);

  return fileName;
}
