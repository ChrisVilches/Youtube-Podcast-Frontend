import 'dart:convert';

import 'package:http/http.dart';

import '../video_list/video_item.dart';

// TODO: Should be configured from environment variables.
const urlPrefix = 'http://cloud.chrisvilches.com/yt/';

Future<String> prepareVideo(String youtubeVideo) async {
  final url = Uri.parse('$urlPrefix/prepare?v=$youtubeVideo');

  final headers = {"Content-type": "application/json"};

  final response = await post(url, headers: headers);
  final body = jsonDecode(response.body);
  return body['message'];
}

VideoItem parseVideoItem(dynamic obj) {
  final videoId = obj['videoId'];
  final title = obj['title'];
  final thumbnailUrl = obj['thumbnails'][0]['url'];
  return VideoItem(videoId, title, thumbnailUrl);
}

Future<VideoItem> getVideoInfo(String youtubeVideo) async {
  final url = Uri.parse('$urlPrefix/info?v=$youtubeVideo');

  final headers = {"Content-type": "application/json"};

  final response = await get(url, headers: headers);
  final body = jsonDecode(response.body);
  final metadata = body['metadata'];
  return parseVideoItem(metadata);
}

Future<List<VideoItem>> getVideosFromPlaylist(String playlistId) async {
  final url = Uri.parse('$urlPrefix/playlist/$playlistId');

  final headers = {"Content-type": "application/json"};

  final response = await get(url, headers: headers);
  final body = jsonDecode(response.body);
  List<dynamic> items = body['items'];
  return items.map(parseVideoItem).toList();
}

