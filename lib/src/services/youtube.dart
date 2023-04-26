import 'package:ffcache/ffcache.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../models/playlist.dart';
import '../models/transcription_entry.dart';
import '../models/video_item.dart';
import '../types.dart';
import '../util/format.dart';
import 'api_uri.dart';
import 'favorite_playlist_service.dart';
import 'http_error.dart';
import 'locator.dart';

const Map<String, String> _headers = <String, String>{
  'Content-type': 'application/json'
};

Future<VideoItem> getVideoInfo(final VideoID videoId) async {
  final Response res = await get(uri('info?v=$videoId'), headers: _headers);
  final Map<String, dynamic> body = toJson(res);
  final Map<String, dynamic> metadata =
      body['metadata'] as Map<String, dynamic>;
  return VideoItem.fromJson(metadata);
}

Future<Playlist> getChannelVideosAsPlaylist(final String username) async {
  final Response res = await get(uri('channel/$username'), headers: _headers);
  final Map<String, dynamic> body = toJson(res);
  body['id'] = sanitizeChannelHandle(body['id'].toString());

  final Playlist playlist = Playlist.fromJson(body);

  // Also update the playlist name if it's saved locally.
  await serviceLocator
      .get<FavoritePlaylistService>()
      .updateMetadata(playlist.title, playlist.author, playlist.id);

  return playlist;
}

Future<Playlist> getVideosFromPlaylist(final String id) async {
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
  final VideoID videoId,
  final String lang,
) async {
  final Response res =
      await get(uri('transcriptions?v=$videoId&lang=$lang'), headers: _headers);

  final Map<String, dynamic> body = toJson(res);

  return (body['transcription'] as List<dynamic>)
      .map(
        (final dynamic o) =>
            TranscriptionEntry.fromJson(o as Map<String, dynamic>),
      )
      .toList();
}

final RegExp _filenameRegex = RegExp(r"\s*filename\*=UTF-8''|\s*filename=");

String contentDispositionFilename(final String header) {
  final String filename = header
      .replaceAll('"', '')
      .split(';')
      .firstWhere((final String s) => s.startsWith(_filenameRegex))
      .trim()
      .replaceAll(_filenameRegex, '');
  return Uri.decodeComponent(filename);
}

Future<String> videoFileName(final VideoID videoId) async {
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
