import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import '../models/favorite_playlist.dart';
import '../models/playlist.dart';
import '../models/video_item.dart';
import '../models/video_item_partial.dart';
import '../search_bar/fav_playlist_menu.dart';
import '../search_bar/playlist_info.dart';
import '../search_bar/prepare_download_controller.dart';
import '../services/locator.dart';
import '../services/playlist_favorite.dart';
import '../services/snackbar_service.dart';
import '../services/youtube.dart';
import '../video_list/video_list.dart';

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

  // TODO: When the widget builds, the current status should be obtained from the service.
  //       Or better, simply obtain the data from the service (or a wrapping controller) and let the controller
  //       notifies. There's no need to duplicate the data here because we can store this _beingPrepared in the service.
  //       And in that case we probably don't need RxDart anymore.
  // final Set<String> _beingPrepared = <String>{};

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
            _favoritedPlaylists = list;

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

  // TODO: Note that "canDownload = false" doesn't mean "try until the video is prepared".
  //       It may mean the video can never be downloaded (e.g. because it's a stream). So I think
  //       The fields should be renamed... alreadyPrepared (boolean), downloadable (boolean)
  //       Note that currently there's no way to know (backend side) if the video has already been
  //       tried to be downloaded, and it failed once (or at least it's not fully implemented).
  // Future<void> _tryDownloadSelectedVideo(VideoItemPartial item) async {}

  Future<void> _executeSearch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
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
        _isLoading = false;
      });
      EasyLoading.dismiss();
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
                onPressed: _isLoading ? null : _executeSearch,
                icon: Icon(
                  _isLoading ? Icons.more_horiz : Icons.search,
                ),
              )
            ],
          ),
          FavPlaylistMenu(
            playlists: _favoritedPlaylists,
            selectedPlaylistId: _currentPlaylist?.id,
            onPressPlaylist: (String playlistId) {
              _searchController.text =
                  'https://www.youtube.com/playlist?list=$playlistId';
              _executeSearch();
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
