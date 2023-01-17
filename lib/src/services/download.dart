import 'dart:convert';

import 'package:http/http.dart';

import '../video_list/video_item.dart';

// TODO: Should be configured from environment variables.
const String urlPrefix = 'http://cloud.chrisvilches.com/yt/';
const Map<String, String> headers = {'Content-type': 'application/json'};

Future<String> prepareVideo(String youtubeVideo) async {
  final Uri url = Uri.parse('$urlPrefix/prepare?v=$youtubeVideo');
  final Response res = await post(url, headers: headers);
  final Map<String, dynamic> body =
      jsonDecode(res.body) as Map<String, dynamic>;
  return body['message'] as String;
}

VideoItem parseVideoItem(dynamic obj) {
  final String videoId = obj['videoId'] as String;
  final String title = obj['title'] as String;
  final String thumbnailUrl = obj['thumbnails'][0]['url'] as String;
  return VideoItem(videoId, title, thumbnailUrl);
}

Future<VideoItem> getVideoInfo(String youtubeVideo) async {
  final Uri url = Uri.parse('$urlPrefix/info?v=$youtubeVideo');

  final Response res = await get(url, headers: headers);
  final Map<String, dynamic> body =
      jsonDecode(res.body) as Map<String, dynamic>;
  final Map<String, dynamic> metadata =
      body['metadata'] as Map<String, dynamic>;
  return parseVideoItem(metadata);
}

Future<List<VideoItem>> getVideosFromPlaylist(String playlistId) async {
  final Uri url = Uri.parse('$urlPrefix/playlist/$playlistId');

  final Response res = await get(url, headers: headers);
  final Map<String, dynamic> body =
      jsonDecode(res.body) as Map<String, dynamic>;
  final List<dynamic> items = body['items'] as List<dynamic>;
  return items.map<VideoItem>(parseVideoItem).toList();
}
