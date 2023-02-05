import 'package:test/test.dart';
import 'package:youtube_podcast/src/util/youtube_url.dart';

void main() {
  group(parseWatchVideoId, () {
    const String? Function(String url) fn = parseWatchVideoId;

    test('returns null if it cannot be parsed', () {
      expect(fn('https://www.some_host.com/watch?v=qwerty&flag'), null);
      expect(fn('https://www.youtube.com/some_path?flag&v=qwerty'), null);
      expect(fn('https://www.youtube.com/watch?flag&w=qwerty'), null);
    });

    test('parses watch?v= correctly', () {
      expect(
        fn('https://www.youtube.com/watch?v=LrQuTGz7bjQ&ab_channel=mychannel'),
        'LrQuTGz7bjQ',
      );
      expect(
        fn(' https://www.youtube.com/watch?someparam=1234567&v=kCPQUAtMZR4 '),
        'kCPQUAtMZR4',
      );
      expect(
        fn('https://wwW.youtuBe.com/watch?v=LrQuTGz7bjQ&ab_channel=mychannel'),
        'LrQuTGz7bjQ',
      );
      expect(
        fn('https://www.youtubE.com/wAtCh?someparam=1234567&v=kCPQUAtMZR4'),
        'kCPQUAtMZR4',
      );
    });

    test('parses watch?v= (without www.) correctly', () {
      expect(
        fn('https://youtube.com/watch?v=LrQuTGz7bjQ&ab_channel=mychannel'),
        'LrQuTGz7bjQ',
      );
      expect(
        fn(' https://youtube.com/watch?someparam=1234567&v=kCPQUAtMZR4 '),
        'kCPQUAtMZR4',
      );
      expect(
        fn('httpS://youtube.com/watcH?v=LrQuTGz7bjQ&ab_channel=mychannel'),
        'LrQuTGz7bjQ',
      );
      expect(
        fn('https://Youtube.COM/Watch?someparam=1234567&v=kCPQUAtMZR4'),
        'kCPQUAtMZR4',
      );
    });

    test('parses youtu.be correctly', () {
      expect(fn('https://youtu.be/Ntn1-SocNiY'), 'Ntn1-SocNiY');
      expect(fn(' https://youtu.be/WIKqgE4BwAY '), 'WIKqgE4BwAY');
      expect(fn('httpS://youtU.be/Ntn1-SocNiY'), 'Ntn1-SocNiY');
      expect(fn(' hTTps://yOUtu.be/WIKqgE4BwAY '), 'WIKqgE4BwAY');

      expect(fn('https://youtu.be/Ntn1-SocNiY?someparam=1234'), 'Ntn1-SocNiY');
      expect(fn('https://youtu.be/WIKqgE4BwAY?someflag'), 'WIKqgE4BwAY');
    });

    test('parses "short video" url correctly', () {
      expect(
        fn(' https://youtube.com/shorts/5AnWWukyr4w?feature=share '),
        '5AnWWukyr4w',
      );
      expect(fn('https://www.youtube.com/shorts/5YQNW09EHgc'), '5YQNW09EHgc');
    });

    test('parses mobile url correctly', () {
      expect(fn('https://m.youtube.com/embed/ho8fvPH_Ro0'), 'ho8fvPH_Ro0');
      expect(fn(' https://m.youtube.com/shorts/5YQNW09EHgc '), '5YQNW09EHgc');
      expect(
        fn('https://m.youtube.com/watch?v=LrQuTGz7bjQ&ab_channel=mychannel'),
        'LrQuTGz7bjQ',
      );
    });

    test('parses embed url correctly', () {
      expect(fn('https://www.youtube.com/embed/ho8fvPH_Ro0'), 'ho8fvPH_Ro0');
      expect(fn(' https://YOUTUBE.com/eMBED/OLB7JYl34y4 '), 'OLB7JYl34y4');
      expect(
        fn('https://www.youtube.com/embed/ho8fvPH_Ro0?someparam=123'),
        'ho8fvPH_Ro0',
      );
      expect(
        fn('https://YOUTUBE.com/eMBED/OLB7JYl34y4?someflag'),
        'OLB7JYl34y4',
      );
    });
  });

  group(parsePlaylistId, () {
    const String? Function(String url) fn = parsePlaylistId;

    test('returns null if it cannot be parsed', () {
      expect(fn('https://www.some_host.com/watch?v=qwerty&flag'), null);
      expect(fn('https://www.youtube.com/some_path?flag&v=qwerty'), null);
      expect(fn('https://www.youtube.com/watch?flag&w=qwerty'), null);
    });

    test('parses the URL correctly', () {
      expect(fn('https://www.youtube.com/playlist?list=xxyyzz'), 'xxyyzz');
      expect(fn('https://www.Youtube.COM/playlist?list=xxyyzz'), 'xxyyzz');
      expect(fn(' https://www.Youtube.COM/playlist?list=xxyyzz '), 'xxyyzz');
    });
  });

  group(parseUsername, () {
    const String? Function(String url) fn = parseUsername;

    test('returns null if it cannot be parsed', () {
      expect(fn(' some-username '), null);
      expect(fn('     '), null);
      expect(fn('   @ '), null);
      expect(fn(' @some/username  '), null);
      expect(fn(' @some,username  '), null);
      expect(fn(' @name@  '), null);
      expect(fn(' @one@two  '), null);
      expect(fn(' @one @two  '), null);
    });

    test('parses the username correctly', () {
      expect(fn('@some-username'), 'some-username');
      expect(fn(' @some-username  '), 'some-username');
      expect(fn(' @with-numbers123 '), 'with-numbers123');
      expect(
        fn(' @00Some.Amazing_user-NAME11  '),
        '00Some.Amazing_user-NAME11',
      );
    });
  });
}
