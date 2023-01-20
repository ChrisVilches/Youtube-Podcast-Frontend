import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart';
import '../models/favorite_playlist.dart';
import '../models/playlist.dart';
import '../models/video_item.dart';
import '../models/video_item_partial.dart';
import '../services/locator.dart';
import '../services/playlist_favorite.dart';
import '../services/snackbar_service.dart';
import '../services/youtube.dart';
import '../video_list/video_list.dart';
import 'fav_playlist_menu.dart';
import 'playlist_info.dart';

class VideoSearch extends StatefulWidget {
  const VideoSearch({super.key});

  @override
  State<VideoSearch> createState() => _VideoSearchState();
}

// TODO: Class is too long.
class _VideoSearchState extends State<VideoSearch> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _searchController = TextEditingController();

  bool isLoading = false;
  // This is for when the user fetched a playlist
  Playlist? currentPlaylist;

  // TODO: Many of these fields should be private. I think.
  List<VideoItemPartial> videoItems = List<VideoItemPartial>.empty();

  List<FavoritePlaylist> favoritedPlaylists = List<FavoritePlaylist>.empty();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    serviceLocator.get<PlaylistFavoriteService>().getAll().then(
          (List<FavoritePlaylist> list) => setState(() {
            favoritedPlaylists = list;

            // TODO: This is temporary.
            if (list.isNotEmpty) {
              _searchController.text =
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
    });
  }

  Future<void> _fetchPlaylist(String id) async {
    final Playlist playlist = await getVideosFromPlaylist(id);
    setState(() {
      currentPlaylist = playlist;
      videoItems = playlist.items;
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

  Future<void> _tryDownloadSelectedVideo(VideoItemPartial item) async {
    final String videoId = item.videoId;
    final DownloadResponse response = await prepareVideo(videoId);

    if (response.canDownload) {
      await downloadVideo(item);
      return;
    }
  }

  Future<void> _executeSearch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    EasyLoading.show();

    try {
      final String input = _searchController.value.text;

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
      EasyLoading.dismiss();
    }
  }

  bool _currentPlaylistIsFavorited() {
    return favoritedPlaylists.firstWhereOrNull(
          (FavoritePlaylist fp) => fp.id == currentPlaylist!.id,
        ) !=
        null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _searchController,
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
              ),
              IconButton(
                onPressed: isLoading ? null : _executeSearch,
                icon: Icon(
                  isLoading ? Icons.more_horiz : Icons.search,
                ),
              )
            ],
          ),
          FavPlaylistMenu(
            playlists: favoritedPlaylists,
            selectedPlaylistId: currentPlaylist?.id,
            onPressPlaylist: (String playlistId) {
              _searchController.text = 'https://www.youtube.com/playlist?list=$playlistId';
              _executeSearch();
            },
            disableButtons: isLoading,
          ),
          if (currentPlaylist != null)
            PlaylistInfo(
              favorited: _currentPlaylistIsFavorited(),
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
          Expanded(
            child: VideoList(
              items: videoItems,
              onDownloadPress: _tryDownloadSelectedVideo,
            ),
          )
        ],
      ),
    );
  }
}
