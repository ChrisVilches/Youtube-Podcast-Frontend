import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/video_item.dart';
import '../services/download.dart';
import '../services/playlist_favorite.dart';
import '../video_list/video_list.dart';

class VideoSearch extends StatefulWidget {
  const VideoSearch({super.key});

  @override
  State<VideoSearch> createState() => VideoSearchState();
}

// TODO: Remove this.
const myHardcodedPlaylist =
    'https://www.youtube.com/playlist?list=PLGb9oxtniFL5J7fvfctISMnpxfA1pKDAB';

class VideoSearchState extends State<VideoSearch> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final searchController = TextEditingController(text: myHardcodedPlaylist);

  // TODO: This is for debugging only. It should be improved.
  String responseDisplay = '';

  // This is for when the user fetched a playlist
  String? playlistTitle;
  String? playlistId;

  int playlistFavoriteCount = 0;

  List<VideoItem> videoItems = List<VideoItem>.empty();
  VideoItem? selectedVideoItem;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    PlaylistFavoriteService().getAll().then((List<String> list) => setState(() {
          playlistFavoriteCount = list.length;
        }));
  }

  Future<void> prepareSelectedVideo() async {
    final String videoId = selectedVideoItem!.videoId;

    setState(() {
      responseDisplay = '';
    });

    final String message = await prepareVideo(videoId);

    setState(() {
      responseDisplay = message;
    });
  }

  Future<void> fetchSingleVideo(String videoId) async {
    final List<VideoItem> items = [await getVideoInfo(videoId)];

    setState(() {
      playlistTitle = null;
      playlistId = null;
      videoItems = items;
      selectedVideoItem = items.isEmpty ? null : items[0];
    });
  }

  Future<void> fetchPlaylist(String id) async {
    final Playlist playlist = await getVideosFromPlaylist(id);
    setState(() {
      playlistTitle = playlist.title;
      playlistId = playlist.id;
      videoItems = playlist.items;
      selectedVideoItem = null;
    });
  }

  String? tryParsePlaylistId(String playlistUrl) {
    final Uri uri = Uri.parse(playlistUrl);
    final bool correctHost = uri.host.toLowerCase().contains('youtube.com');
    final bool correctPath = uri.path.toLowerCase() == '/playlist';

    if (!correctHost || !correctPath) {
      return null;
    }

    return uri.queryParameters['list'];
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
            ),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a video or playlist URL';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                final String input = searchController.value.text;

                final String? playlistId = tryParsePlaylistId(input);

                if (playlistId != null) {
                  await fetchPlaylist(playlistId);
                } else {
                  await fetchSingleVideo(input);
                }
              },
              child: const Text('Load video(s)'),
            ),
          ),
          Text('Fav playlist count $playlistFavoriteCount'),
          Text(selectedVideoItem == null
              ? 'Select a video from the list'
              : '(${selectedVideoItem!.videoId}) | ${selectedVideoItem!.title}'),
          Row(
            // TODO: Layout sucks.
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
                child: ElevatedButton(
                  onPressed:
                      selectedVideoItem == null ? null : prepareSelectedVideo,
                  child: const Text('Prepare'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: selectedVideoItem == null
                      ? null
                      : () => downloadVideo(selectedVideoItem!),
                  child: const Text('Download'),
                ),
              ),
            ],
          ),
          if (playlistTitle != null)
            Row(
              children: [
                Text(playlistTitle!),
                ElevatedButton(
                    onPressed: () async {
                      final PlaylistFavoriteService serv =
                          PlaylistFavoriteService();
                      await serv.favorite(playlistId!);

                      final int newCount = (await serv.getAll()).length;
                      setState(() {
                        playlistFavoriteCount = newCount;
                      });
                    },
                    child: const Text('Fav'))
              ],
            ),
          Text(responseDisplay),
          Expanded(
            child: VideoList(
              items: videoItems,
              onVideoSelected: (VideoItem item) {
                setState(() {
                  selectedVideoItem = item;
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
