import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import '../controllers/prepare_download_controller.dart';
import '../models/favorite_playlist.dart';
import '../models/playlist.dart';
import '../models/video_item.dart';
import '../models/video_item_partial.dart';
import '../services/locator.dart';
import '../services/playlist_favorite.dart';
import '../services/snackbar_service.dart';
import '../services/youtube.dart';
import '../video_list/video_list.dart';
import '../widgets/fav_playlist_menu.dart';
import '../widgets/playlist_info.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

// TODO: Class is too long.
class _SearchViewState extends State<SearchView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  Playlist? _currentPlaylist;
  List<VideoItemPartial> _videoItems = List<VideoItemPartial>.empty();
  List<FavoritePlaylist> _favoritedPlaylists = List<FavoritePlaylist>.empty();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // ignore: discarded_futures
    serviceLocator.get<PlaylistFavoriteService>().getAll().then(
          (List<FavoritePlaylist> list) => setState(() {
            _favoritedPlaylists = list;
          }),
        );
  }

  Future<void> _fetchSingleVideo(VideoID videoId) async {
    final List<VideoItem> items = <VideoItem>[await getVideoInfo(videoId)];

    setState(() {
      _currentPlaylist = null;
      _videoItems = items;
    });
  }

  Future<void> _fetchPlaylist(String id) async {
    final Playlist playlist = await getVideosFromPlaylist(id);
    setState(() {
      _currentPlaylist = playlist;
      _videoItems = playlist.items;
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

  Future<void> _executeSearch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await EasyLoading.show();

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
        _isLoading = false;
      });
      await EasyLoading.dismiss();
    }
  }

  bool _currentPlaylistIsFavorited() {
    return _favoritedPlaylists.firstWhereOrNull(
          (FavoritePlaylist fp) => fp.id == _currentPlaylist!.id,
        ) !=
        null;
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Row(
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
                  onPressed: _isLoading ? null : _executeSearch,
                  icon: Icon(
                    _isLoading ? Icons.more_horiz : Icons.search,
                  ),
                )
              ],
            ),
          ),
          FavPlaylistMenu(
            playlists: _favoritedPlaylists,
            selectedPlaylistId: _currentPlaylist?.id,
            onPressPlaylist: (String playlistId) async {
              _searchController.text =
                  'https://www.youtube.com/playlist?list=$playlistId';
              await _executeSearch();
            },
            disableButtons: _isLoading,
          ),
          if (_currentPlaylist != null)
            PlaylistInfo(
              favorited: _currentPlaylistIsFavorited(),
              onFavoritePlaylistsChange:
                  (List<FavoritePlaylist> newList, bool removed) {
                setState(() {
                  _favoritedPlaylists = newList;
                });

                serviceLocator.get<SnackbarService>().simpleSnackbar(
                      removed ? 'Removed from favorites' : 'Added to favorites',
                    );
              },
              playlist: _currentPlaylist!,
            ),
          Consumer<PrepareDownloadController>(
            builder: (
              BuildContext context,
              PrepareDownloadController ctrl,
              _,
            ) =>
                Expanded(
              child: VideoList(
                items: _videoItems,
                onDownloadPress: (VideoItemPartial item) =>
                    ctrl.startPrepareProcess(item.videoId),
                beingPrepared: ctrl.beingPrepared,
              ),
            ),
          ),
        ],
      ),
    );

    return ChangeNotifierProvider<PrepareDownloadController>(
      create: (_) => PrepareDownloadController(),
      child: child,
    );
  }
}
