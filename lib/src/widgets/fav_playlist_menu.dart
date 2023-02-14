import 'package:flutter/material.dart';
import '../models/favorite_playlist.dart';
import 'vibration.dart';

class _FavPlaylistMenuItem extends StatelessWidget {
  const _FavPlaylistMenuItem({
    required this.playlist,
    required this.selected,
    required this.onPressPlaylist,
    required this.disabled,
  });

  final FavoritePlaylist playlist;
  final bool selected;
  final void Function(FavoritePlaylist) onPressPlaylist;
  final bool disabled;

  @override
  Widget build(final BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      onPressed: disabled ? null : () => onPressPlaylist(playlist),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              playlist.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              playlist.author,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
          ],
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
    required this.scrollCtrl,
    required this.vibrationController,
  });

  final List<FavoritePlaylist> playlists;
  final String? selectedPlaylistId;
  final void Function(FavoritePlaylist) onPressPlaylist;
  final bool disableButtons;
  final ScrollController scrollCtrl;
  final VibrationController vibrationController;

  @override
  Widget build(final BuildContext context) {
    final Widget list = ListView.builder(
      controller: scrollCtrl,
      itemCount: playlists.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (final _, final int index) {
        final _FavPlaylistMenuItem item = _FavPlaylistMenuItem(
          playlist: playlists[index],
          selected: playlists[index].id == selectedPlaylistId,
          disabled: disableButtons,
          onPressPlaylist: onPressPlaylist,
        );

        final Widget wrappedItem = index == 0
            ? Vibration(
                controller: vibrationController,
                child: item,
              )
            : item;

        return Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: wrappedItem,
        );
      },
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
