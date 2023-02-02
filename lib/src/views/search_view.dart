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
  String? _latestExecutedSearchQuery;

  @override
  void initState() {
    super.initState();

    // ignore: discarded_futures
    serviceLocator.get<FavoritePlaylistService>().getAll().then(
          (final List<FavoritePlaylist> list) => setState(() {
            _favoritedPlaylists = list;
          }),
        );
  }

  Future<void> _fetchSingleVideo(final VideoID videoId) async {
    final List<VideoItem> items = <VideoItem>[await getVideoInfo(videoId)];

    setState(() {
      _currentPlaylist = null;
      _videoItems = items;
    });
  }

  Future<void> _fetchPlaylist(final String id) async {
    final Playlist playlist = await getVideosFromPlaylist(id);
    setState(() {
      _currentPlaylist = playlist;
      _videoItems = playlist.items;
    });
  }

  Future<void> _setLoading(
    final bool loading, {
    final bool showLoader = true,
  }) async {
    if (loading == _isLoading) {
      return;
    }

    setState(() => _isLoading = loading);

    if (loading && showLoader) {
      await EasyLoading.show();
    } else {
      await EasyLoading.dismiss();
    }
  }

  Future<void> _executeSearch(
    final String queryText, {
    final bool showLoader = true,
  }) async {
    await _setLoading(true, showLoader: showLoader);

    try {
      final String? playlistId = parsePlaylistId(queryText);
      final String? videoId = parseWatchVideoId(queryText);

      if (playlistId != null) {
        await _fetchPlaylist(playlistId);
      } else if (videoId != null) {
        await _fetchSingleVideo(videoId);
      } else {
        await _fetchSingleVideo(queryText);
      }

      _latestExecutedSearchQuery = queryText;
    } catch (e) {
      serviceLocator.get<SnackbarService>().danger(e.toString());
    } finally {
      await _setLoading(false);
    }
  }

  bool _currentPlaylistIsFavorited() {
    return _favoritedPlaylists.firstWhereOrNull(
          (final FavoritePlaylist fp) => fp.id == _currentPlaylist!.id,
        ) !=
        null;
  }

  @override
  Widget build(final BuildContext context) {
    Widget playlistInfo() => PlaylistInfo(
          favorited: _currentPlaylistIsFavorited(),
          onFavoritePlaylistsChange:
              (final List<FavoritePlaylist> newList, final bool removed) {
            setState(() => _favoritedPlaylists = newList);

            serviceLocator.get<SnackbarService>().success(
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
          onPressPlaylist: (final String playlistId) async =>
              _executeSearch(createPlaylistUrl(playlistId)),
          disableButtons: _isLoading,
        ),
        if (_currentPlaylist != null) playlistInfo(),
        Expanded(child: VideoList(items: _videoItems)),
      ],
    );

    return ChangeNotifierProvider<PrepareDownloadController>(
      create: (final _) => PrepareDownloadController(),
      child: RefreshIndicator(
        onRefresh: () async {
          if (_isLoading || _latestExecutedSearchQuery == null) {
            return;
          }

          // Uses another loader (provided by the RefreshIndicator), so hide the default one.
          await _executeSearch(_latestExecutedSearchQuery!, showLoader: false);
        },
        child: child,
      ),
    );
  }
}
