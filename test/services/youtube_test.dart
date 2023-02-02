import 'package:test/test.dart';
import 'package:youtube_podcast/src/services/youtube.dart';

void main() {
  test(contentDispositionFilename, () {
    expect(
      contentDispositionFilename(
        "attachment; filename*=UTF-8''Some video.m4a",
      ),
      'Some video.m4a',
    );

    const String long =
        "attachment; filename*=UTF-8''%E3%80%90%E3%82%82%E3%82%82%E3%82%AF%E3%83%ADMV%E3%80%91Chai%20Maxx%20_%20%E3%82%82%E3%82%82%E3%81%84%E3%82%8D%E3%82%AF%E3%83%AD%E3%83%BC%E3%83%90%E3%83%BCZ%EF%BC%88MOMOIRO%20CLOVER%EF%BC%8FChai%20Maxx%EF%BC%89.m4a";
    const String longRes =
        '【ももクロMV】Chai Maxx _ ももいろクローバーZ（MOMOIRO CLOVER／Chai Maxx）.m4a';
    expect(contentDispositionFilename(long), longRes);

    expect(
      contentDispositionFilename(
        "attachment; filename*=\"UTF-8''some video.m4a\"",
      ),
      'some video.m4a',
    );
    expect(
      contentDispositionFilename(
        "attachment;  filename*=\"UTF-8''some video.m4a\"  ",
      ),
      'some video.m4a',
    );
    expect(
      contentDispositionFilename(
        " filename*=\"UTF-8''some video.m4a\" ; attachment;   ",
      ),
      'some video.m4a',
    );
    expect(
      contentDispositionFilename('attachment; filename="filename.jpg"'),
      'filename.jpg',
    );
  });
}
