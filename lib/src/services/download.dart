import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/playlist.dart';
import '../models/video_item.dart';

String urlPrefix() {
  if (defaultTargetPlatform == TargetPlatform.linux) {
    return 'http://localhost:3000';
  }

  // TODO: Should be configured from environment variables.
  return 'http://cloud.chrisvilches.com/yt';
}

Uri uri(String path) {
  final String url = '${urlPrefix()}$path';
  return Uri.parse(url);
}

const Map<String, String> headers = {'Content-type': 'application/json'};

Future<String> prepareVideo(String youtubeVideo) async {
  final Response res =
      await post(uri('/prepare?v=$youtubeVideo'), headers: headers);
  final Map<String, dynamic> body =
      jsonDecode(res.body) as Map<String, dynamic>;
  return body['message'] as String;
}

Future<VideoItem> getVideoInfo(String youtubeVideo) async {
  final Response res =
      await get(uri('/info?v=$youtubeVideo'), headers: headers);
  final Map<String, dynamic> body =
      jsonDecode(res.body) as Map<String, dynamic>;
  final Map<String, dynamic> metadata =
      body['metadata'] as Map<String, dynamic>;
  return VideoItem.from(metadata);
}

Future<Playlist> getVideosFromPlaylist(String id) async {
  final Response res = await get(uri('/playlist/$id'), headers: headers);
  final Map<String, dynamic> body =
      jsonDecode(res.body) as Map<String, dynamic>;

  return Playlist.from(body);
}

Future<void> downloadVideo(VideoItem item) async {
  // TODO: Download has to be more robust.
  await launchUrl(uri('/download?v=${item.videoId}'),
      mode: LaunchMode.externalNonBrowserApplication);
}
