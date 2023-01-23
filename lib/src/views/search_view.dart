import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import '../controllers/prepare_download_controller.dart';
import '../models/favorite_playlist.dart';
import '../models/playlist.dart';
import '../models/video_item.dart';
import '../models/video_item_partial.dart';
import '../services/favorite_playlist_service.dart';
import '../services/locator.dart';
import '../services/snackbar_service.dart';
import '../services/youtube.dart';
import '../util/youtube_url.dart';
import '../widgets/fav_playlist_menu.dart';
import '../widgets/playlist_info.dart';
import '../widgets/search_bar.dart';
import '../widgets/video_list.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  bool _isLoading = false;
  Playlist? _currentPlaylist;
  List<VideoItemPartial> _videoItems = List<VideoItemPartial>.empty();
  List<FavoritePlaylist> _favoritedPlaylists = List<FavoritePlaylist>.empty();

  @override
  void initState() {
    super.initState();

    // ignore: discarded_futures
    serviceLocator.get<FavoritePlaylistService>().getAll().then(
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

  Future<void> _setLoading(bool loading) async {
    if (loading == _isLoading) {
      return;
    }

    setState(() => _isLoading = loading);

    if (loading) {
      await EasyLoading.show();
    } else {
      await EasyLoading.dismiss();
    }
  }

  Future<void> _executeSearch(String queryText) async {
    await _setLoading(true);

    try {
      final String? playlistId = parsePlaylistId(queryText);

      if (playlistId != null) {
        await _fetchPlaylist(playlistId);
      } else {
        await _fetchSingleVideo(queryText);
      }
    } finally {
      await _setLoading(false);
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
    Widget playlistInfo() => PlaylistInfo(
          favorited: _currentPlaylistIsFavorited(),
          onFavoritePlaylistsChange:
              (List<FavoritePlaylist> newList, bool removed) {
            setState(() => _favoritedPlaylists = newList);

            serviceLocator.get<SnackbarService>().simpleSnackbar(
                  removed ? 'Removed from favorites' : 'Added to favorites',
                );
          },
          playlist: _currentPlaylist!,
        );

    final Widget child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: SearchBar(isLoading: _isLoading, onSearch: _executeSearch),
        ),
        FavPlaylistMenu(
          playlists: _favoritedPlaylists,
          selectedPlaylistId: _currentPlaylist?.id,
          onPressPlaylist: (String playlistId) async =>
              _executeSearch(createPlaylistUrl(playlistId)),
          disableButtons: _isLoading,
        ),
        if (_currentPlaylist != null) playlistInfo(),
        Consumer<PrepareDownloadController>(
          builder: (
            BuildContext context,
            PrepareDownloadController ctrl,
            _,
          ) =>
              Expanded(child: VideoList(items: _videoItems)),
        ),
      ],
    );

    return ChangeNotifierProvider<PrepareDownloadController>(
      create: (_) => PrepareDownloadController(),
      child: child,
    );
  }
}
