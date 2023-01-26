import 'package:test/test.dart';
import 'package:youtube_podcast/src/util/youtube_url.dart';

void main() {
  test(vQueryParam, () {
    expect(
      vQueryParam('http://somehost.com/?w=34343&v=qwertyuq1234'),
      'qwertyuq1234',
    );
    expect(
      vQueryParam('https://www.youtube.com/?v=ABCDEFGH&someflag'),
      'ABCDEFGH',
    );
    // TODO: Test the error when the URL doesn't contain the "v" parameter
    // expect(() => vQueryParam('https://www.youtube.com/?w=ABCDEFGH&someflag'), ...);
  });
}
