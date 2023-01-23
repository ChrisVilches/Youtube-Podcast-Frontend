import 'package:flutter/material.dart';

import '../models/favorite_playlist.dart';

class _FavPlaylistMenuItem extends StatelessWidget {
  const _FavPlaylistMenuItem({
    required this.playlist,
    required this.selected,
    required this.onPressPlaylist,
    required this.disabled,
  });

  final FavoritePlaylist playlist;
  final bool selected;
  final void Function(String) onPressPlaylist;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      onPressed: disabled ? null : () => onPressPlaylist(playlist.id),
      child: Text(
        playlist.title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class FavPlaylistMenu extends StatelessWidget {
  const FavPlaylistMenu({
    super.key,
    required this.playlists,
    this.selectedPlaylistId,
    required this.onPressPlaylist,
    required this.disableButtons,
  });

  final List<FavoritePlaylist> playlists;
  final String? selectedPlaylistId;
  final void Function(String) onPressPlaylist;
  final bool disableButtons;

  @override
  Widget build(BuildContext context) {
    final Widget list = ListView.builder(
      itemCount: playlists.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (_, int index) => Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: _FavPlaylistMenuItem(
          playlist: playlists[index],
          selected: playlists[index].id == selectedPlaylistId,
          disabled: disableButtons,
          onPressPlaylist: onPressPlaylist,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: SizedBox(
        height: 60,
        child: list,
      ),
    );
  }
}
