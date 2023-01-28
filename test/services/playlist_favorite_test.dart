import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:youtube_podcast/src/models/favorite_playlist.dart';
import 'package:youtube_podcast/src/services/favorite_playlist_service.dart';
import '../init.dart';

void main() {
  init();

  group(FavoritePlaylistService, () {
    setUp(() async {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.clear();
    });

    final FavoritePlaylistService serv = FavoritePlaylistService();

    test('is initially empty', () async {
      expect((await serv.getAll()).length, 0);
    });

    test('adds a favorite', () async {
      await serv.favorite('some playlist', 'someauthor', 'aaabbbbcccc');
      final List<FavoritePlaylist> list = await serv.getAll();
      expect(list.length, 1);
      expect(list.first.id, 'aaabbbbcccc');
      expect(list.first.title, 'some playlist');
      expect(list.first.author, 'someauthor');
    });

    group('pre-populated', () {
      setUp(() async {
        await serv.favorite('some playlist', 'auth1', 'aaabbbbcccc1');
        await serv.favorite('another playlist', 'auth2', 'aaabbbbcccc2');
        await serv.favorite('yet another playlist', 'auth3', 'aaabbbbcccc3');
      });

      test('correct length', () async {
        expect((await serv.getAll()).length, 3);
      });

      test('updates a title', () async {
        await serv.updateMetadata(
          'another playlist modified!!',
          'newauth',
          'aaabbbbcccc2',
        );

        final List<FavoritePlaylist> list = await serv.getAll();
        expect(list.length, 3);
        expect(list[0].title, 'some playlist');
        expect(list[0].author, 'auth1');
        expect(list[0].id, 'aaabbbbcccc1');
        expect(list[1].title, 'another playlist modified!!');
        expect(list[1].author, 'newauth');
        expect(list[1].id, 'aaabbbbcccc2');
        expect(list[2].title, 'yet another playlist');
        expect(list[2].author, 'auth3');
        expect(list[2].id, 'aaabbbbcccc3');
      });

      test('updates a title (when the playlist has not been saved)', () async {
        await serv.updateMetadata(
          'another playlist modified!!',
          'newauth',
          'aaabbbbcccc777',
        );

        final List<FavoritePlaylist> list = await serv.getAll();
        expect(list.length, 3);
        expect(list[0].title, 'some playlist');
        expect(list[0].author, 'auth1');
        expect(list[0].id, 'aaabbbbcccc1');
        expect(list[1].title, 'another playlist');
        expect(list[1].author, 'auth2');
        expect(list[1].id, 'aaabbbbcccc2');
        expect(list[2].title, 'yet another playlist');
        expect(list[2].author, 'auth3');
        expect(list[2].id, 'aaabbbbcccc3');
      });

      test('removes a playlist', () async {
        await serv.remove('aaabbbbcccc2');

        final List<FavoritePlaylist> list = await serv.getAll();
        expect(list.length, 2);
        expect(list[0].title, 'some playlist');
        expect(list[0].id, 'aaabbbbcccc1');
        expect(list[1].title, 'yet another playlist');
        expect(list[1].id, 'aaabbbbcccc3');
      });
    });
  });
}
