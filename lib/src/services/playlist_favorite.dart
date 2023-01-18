import 'package:shared_preferences/shared_preferences.dart';

// TODO: Maybe this could be only functions instead of a class.

const String playlistFavoritesKey = 'PLAYLIST_FAVORITE_ID_LIST';

class PlaylistFavoriteService {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<List<String>> getAll() async {
    return (await _prefs).getStringList(playlistFavoritesKey) ??
        List<String>.empty();
  }

  Future<void> favorite(String id) async {
    final List<String> list = await getAll();
    if (list.contains(id)) {
      return;
    }

    final List<String> newList = List<String>.from(list)..addAll([id]);

    (await _prefs).setStringList(playlistFavoritesKey, newList);
  }

  Future<void> remove(String id) async {
    final List<String> list = await getAll();

    if (!list.remove(id)) {
      return;
    }

    (await _prefs).setStringList(playlistFavoritesKey, list);
  }

  Future<bool> isFavorite(String id) async {
    final List<String> list = await getAll();
    return list.contains(id);
  }
}
