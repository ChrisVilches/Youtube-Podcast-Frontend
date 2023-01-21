import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_playlist.dart';
import 'locator.dart';

// TODO: Change filename. It's too similar to the models/favorite_playlist.dart, but the words are reversed,
//       which makes it even more confusing.

const String playlistFavoritesKey = 'PLAYLIST_FAVORITE_ID_LIST';

class PlaylistFavoriteService {
  Future<List<FavoritePlaylist>> getAll() async {
    final List<String>? list = serviceLocator
        .get<SharedPreferences>()
        .getStringList(playlistFavoritesKey);

    if (list == null) {
      return List<FavoritePlaylist>.empty();
    }

    return list
        .map(
          (String o) =>
              FavoritePlaylist.fromJson(jsonDecode(o) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> favorite(String title, String author, String id) async {
    final List<FavoritePlaylist> list = await getAll();

    if (list.any((FavoritePlaylist fp) => fp.id == id)) {
      return;
    }

    final FavoritePlaylist newFav = FavoritePlaylist(title, author, id);
    final List<FavoritePlaylist> newList = List<FavoritePlaylist>.from(list)
      ..addAll(<FavoritePlaylist>[newFav]);

    await saveList(newList);
  }

  Future<void> updateMetadata(String title, String author, String id) async {
    final List<FavoritePlaylist> list = await getAll();

    final FavoritePlaylist? item =
        list.firstWhereOrNull((FavoritePlaylist fp) => fp.id == id);

    if (item == null) {
      return;
    }

    item.title = title;
    item.author = author;
    saveList(list);
  }

  Future<void> saveList(List<FavoritePlaylist> list) async {
    serviceLocator.get<SharedPreferences>().setStringList(
          playlistFavoritesKey,
          list.map(jsonEncode).toList(),
        );
  }

  Future<void> remove(String id) async {
    final List<FavoritePlaylist> list = await getAll();

    list.removeWhere((FavoritePlaylist fp) => fp.id == id);

    await saveList(list);
  }

  Future<bool> isFavorite(String id) async {
    final List<FavoritePlaylist> list = await getAll();
    return list.any((FavoritePlaylist fp) => fp.id == id);
  }
}
