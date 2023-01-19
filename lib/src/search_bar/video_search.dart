import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../models/favorite_playlist.dart';
import '../models/playlist.dart';
import '../models/video_item.dart';
import '../models/video_item_partial.dart';
import '../services/locator.dart';
import '../services/playlist_favorite.dart';
import '../services/snackbar_service.dart';
import '../services/youtube.dart';
import '../video_list/video_list.dart';
import 'playlist_info.dart';
import 'video_detail.dart';

class VideoSearch extends StatefulWidget {
  const VideoSearch({super.key});

  @override
  State<VideoSearch> createState() => _VideoSearchState();
}

class _VideoSearchState extends State<VideoSearch> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController searchController = TextEditingController();

  // TODO: This is for debugging only. It should be improved.
  String responseDisplay = '';

  bool isLoading = false;
  // This is for when the user fetched a playlist
  Playlist? currentPlaylist;

  List<VideoItemPartial> videoItems = List<VideoItemPartial>.empty();
  VideoItemPartial? selectedVideoItem;

  List<FavoritePlaylist> favoritedPlaylists = List<FavoritePlaylist>.empty();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    PlaylistFavoriteService().getAll().then(
          (List<FavoritePlaylist> list) => setState(() {
            favoritedPlaylists = list;

            // TODO: This is temporary.
            if (list.isNotEmpty) {
              searchController.text =
                  'https://www.youtube.com/playlist?list=${list.first.id}';
            }
          }),
        );
  }

  Future<void> _fetchSingleVideo(String videoId) async {
    final List<VideoItem> items = <VideoItem>[await getVideoInfo(videoId)];

    setState(() {
      currentPlaylist = null;
      videoItems = items;
      selectedVideoItem = items.isEmpty ? null : items[0];
    });
  }

  Future<void> _fetchPlaylist(String id) async {
    final Playlist playlist = await getVideosFromPlaylist(id);
    setState(() {
      currentPlaylist = playlist;
      videoItems = playlist.items;
      selectedVideoItem = null;
    });
  }

  String? _tryParsePlaylistId(String playlistUrl) {
    final Uri uri = Uri.parse(playlistUrl);
    final bool correctHost = uri.host.toLowerCase().contains('youtube.com');
    final bool correctPath = uri.path.toLowerCase() == '/playlist';

    if (!correctHost || !correctPath) {
      return null;
    }

    return uri.queryParameters['list'];
  }

  Future<void> _tryDownloadSelectedVideo() async {
    final String videoId = selectedVideoItem!.videoId;
    final DownloadResponse response = await prepareVideo(videoId);

    setState(() {
      responseDisplay = '';
    });

    if (response.canDownload) {
      await downloadVideo(selectedVideoItem!);
      return;
    }

    setState(() {
      responseDisplay = 'Progress ${response.progress}%';
    });
  }

  Future<void> _executeSearch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final String input = searchController.value.text;

      final String? playlistId = _tryParsePlaylistId(input);

      if (playlistId != null) {
        await _fetchPlaylist(playlistId);
      } else {
        await _fetchSingleVideo(input);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
              onPressed: isLoading ? null : _executeSearch,
              child: Text(isLoading ? 'Loading...' : 'Load video(s)'),
            ),
          ),
          Text('Fav playlist count ${favoritedPlaylists.length}'),
          if (selectedVideoItem == null)
            const Text('Select a video from the list'),
          if (selectedVideoItem != null)
            VideoDetail(
              item: selectedVideoItem!,
              onDownloadPress: _tryDownloadSelectedVideo,
            ),
          if (currentPlaylist != null)
            PlaylistInfo(
              // TODO: This is too long. There should be a simpler way.
              favorited: favoritedPlaylists.firstWhereOrNull(
                    (FavoritePlaylist fp) => fp.id == currentPlaylist!.id,
                  ) !=
                  null,
              onFavoritePlaylistsChange:
                  (List<FavoritePlaylist> newList, bool removed) {
                setState(() {
                  favoritedPlaylists = newList;
                });

                serviceLocator.get<SnackbarService>().simpleSnackbar(
                      removed ? 'Removed from favorites' : 'Added to favorites',
                    );
              },
              playlist: currentPlaylist!,
            ),
          Text(responseDisplay),
          Expanded(
            child: VideoList(
              items: videoItems,
              onVideoSelected: (VideoItemPartial item) {
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
