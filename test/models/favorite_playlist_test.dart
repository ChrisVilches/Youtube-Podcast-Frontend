import 'package:test/test.dart';
import 'package:youtube_podcast/src/models/favorite_playlist.dart';

void main() {
  group(FavoritePlaylist.fromEncoded, () {
    test('Encoded string is decoded correctly', () {
      const String s = 'plGb9fxtn3FL537fvfcdISMnpxfAdpK_As,this is the title';
      final FavoritePlaylist result = FavoritePlaylist.fromEncoded(s);

      expect(result.id, 'plGb9fxtn3FL537fvfcdISMnpxfAdpK_As');
      expect(result.title, 'this is the title');
    });

    test('Encoded string is decoded correctly (multiple commas)', () {
      const String s = 'aaaabbbbcccc,cat, rabbit and hamsters';
      final FavoritePlaylist result = FavoritePlaylist.fromEncoded(s);

      expect(result.id, 'aaaabbbbcccc');
      expect(result.title, 'cat, rabbit and hamsters');
    });
  });
}
