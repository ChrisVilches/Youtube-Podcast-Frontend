import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_playlist.dart';
import 'locator.dart';

const String playlistFavoritesKey = 'PLAYLIST_FAVORITE_ID_LIST';

class FavoritePlaylistService {
  Future<List<FavoritePlaylist>> getAll() async {
    final List<String>? list = serviceLocator
        .get<SharedPreferences>()
        .getStringList(playlistFavoritesKey);

    if (list == null) {
      return List<FavoritePlaylist>.empty();
    }

    return list
        .map(
          (final String o) =>
              FavoritePlaylist.fromJson(jsonDecode(o) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> favorite(
    final String title,
    final String author,
    final String id,
    final bool isChannel,
  ) async {
    final List<FavoritePlaylist> list = await getAll();

    if (list.any((final FavoritePlaylist fp) => fp.id == id)) {
      return;
    }

    final List<FavoritePlaylist> newList = List<FavoritePlaylist>.from(list)
      ..add(FavoritePlaylist(title, author, id, isChannel));

    await saveList(newList);
  }

  Future<void> updateMetadata(
    final String title,
    final String author,
    final String id,
  ) async {
    final List<FavoritePlaylist> list = await getAll();

    final int index =
        list.indexWhere((final FavoritePlaylist fp) => fp.id == id);

    if (index == -1) {
      return;
    }

    list[index] = FavoritePlaylist(title, author, id, list[index].isChannel);
    return saveList(list);
  }

  Future<void> saveList(final List<FavoritePlaylist> list) async {
    await serviceLocator.get<SharedPreferences>().setStringList(
          playlistFavoritesKey,
          list.map(jsonEncode).toList(),
        );
  }

  Future<void> remove(final String id) async {
    final List<FavoritePlaylist> list = await getAll();

    list.removeWhere((final FavoritePlaylist fp) => fp.id == id);

    await saveList(list);
  }

  Future<bool> isFavorite(final String id) async {
    final List<FavoritePlaylist> list = await getAll();
    return list.any((final FavoritePlaylist fp) => fp.id == id);
  }
}
