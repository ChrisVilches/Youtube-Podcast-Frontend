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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(playlist.title),
        LikeButton(
          isLiked: favorited,
          onTap: (bool isFavorite) async {
            final PlaylistFavoriteService serv = PlaylistFavoriteService();

            if (isFavorite) {
              await serv.remove(playlist.id);
            } else {
              await serv.favorite(playlist.title, playlist.id);
            }

            onFavoritePlaylistsChange(await serv.getAll(), favorited);

            return true;
          },
        ),
      ],
    );
  }
}
