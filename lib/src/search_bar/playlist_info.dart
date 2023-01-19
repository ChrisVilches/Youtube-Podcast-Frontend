import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import '../models/favorite_playlist.dart';
import '../models/playlist.dart';
import '../services/playlist_favorite.dart';

class PlaylistInfo extends StatelessWidget {
  const PlaylistInfo({
    super.key,
    required this.playlist,
    required this.favorited,
    required this.onFavoritePlaylistsChange,
  });

  final Playlist playlist;
  final bool favorited;
  final Function(List<FavoritePlaylist>, bool) onFavoritePlaylistsChange;

  Future<bool> onTapLike(bool isFavorite) async {
    final PlaylistFavoriteService serv = PlaylistFavoriteService();

    if (isFavorite) {
      await serv.remove(playlist.id);
    } else {
      await serv.favorite(
        playlist.title,
        playlist.author,
        playlist.id,
      );
    }

    onFavoritePlaylistsChange(await serv.getAll(), favorited);

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final LikeButton likeButton = LikeButton(
      isLiked: favorited,
      onTap: onTapLike,
    );

    final Widget title = Expanded(child: Text(playlist.title));
    final Widget author = Expanded(child: Text(playlist.author));

    final Widget upper = Row(
      children: <Widget>[title, likeButton],
    );

    final Widget lower = Row(
      children: <Widget>[author, Text('${playlist.items.length} videos')],
    );

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.playlist_add_check, size: 40,),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: upper,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: lower,
            ),
          )
        ],
      ),
    );
  }
}
