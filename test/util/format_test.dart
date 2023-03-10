import 'dart:math';

import 'package:test/test.dart';
import 'package:youtube_podcast/src/util/format.dart';

double createTime(final int h, final int m, final int s, final int ms) {
  return (3600 * h) + (60 * m) + s + (ms / 1000);
}

void main() {
  test(removeHour00, () {
    expect(removeHour00(' 00:00:yy'), ' 00:00:yy');
    expect(removeHour00('00:00:xx'), '00:xx');
    expect(removeHour00('00:12:23'), '12:23');
    expect(removeHour00('hello 00:12:23'), 'hello 00:12:23');
  });

  test(formatTimeHHMMSSms, () {
    expect(formatTimeHHMMSSms(0.0), '00:00:00.0');
    expect(formatTimeHHMMSSms(0.9111), '00:00:00.9');
    expect(formatTimeHHMMSSms(0.5), '00:00:00.5');
    expect(formatTimeHHMMSSms(0.56), '00:00:00.5');
    expect(formatTimeHHMMSSms(0.98), '00:00:00.9');
    expect(formatTimeHHMMSSms(60.0), '00:01:00.0');
    expect(formatTimeHHMMSSms(60.123), '00:01:00.1');
    expect(formatTimeHHMMSSms(60.45), '00:01:00.4');
    expect(formatTimeHHMMSSms(60.5), '00:01:00.5');
    expect(formatTimeHHMMSSms(3600), '01:00:00.0');
    expect(formatTimeHHMMSSms(3601), '01:00:01.0');
    expect(formatTimeHHMMSSms(3660), '01:01:00.0');
    expect(formatTimeHHMMSSms(3661), '01:01:01.0');
    expect(formatTimeHHMMSSms(3661.4), '01:01:01.4');
    expect(formatTimeHHMMSSms(3662.499), '01:01:02.4');

    expect(formatTimeHHMMSSms(createTime(2, 5, 15, 123)), '02:05:15.1');
    expect(formatTimeHHMMSSms(createTime(26, 51, 15, 999)), '26:51:15.9');
  });

  test(formatTimeHHMMSS, () {
    expect(formatTimeHHMMSS(createTime(2, 5, 15, 0).round()), '02:05:15');
    expect(formatTimeHHMMSS(createTime(26, 51, 15, 0).round()), '26:51:15');
    expect(formatTimeHHMMSS(createTime(0, 1, 1, 0).round()), '00:01:01');
    expect(formatTimeHHMMSS(createTime(0, 0, 1, 0).round()), '00:00:01');
    expect(formatTimeHHMMSS(createTime(0, 0, 0, 0).round()), '00:00:00');
    expect(formatTimeHHMMSS(createTime(59, 59, 59, 0).round()), '59:59:59');
  });

  test(sanitizeChannelHandle, () {
    final Random rng = Random();

    String idempotentTest(final String s) {
      final String res = sanitizeChannelHandle(s);
      return rng.nextBool() ? idempotentTest(res) : res;
    }

    expect(idempotentTest(' hello '), '@hello');
    expect(idempotentTest('HelloWorld'), '@helloworld');
    expect(idempotentTest(' HelloWorld   '), '@helloworld');
    expect(idempotentTest('   '), '@');
    expect(idempotentTest('  AABBCC '), '@aabbcc');
    expect(idempotentTest(' @hello '), '@hello');
    expect(idempotentTest('@HelloWorld'), '@helloworld');
    expect(idempotentTest(' @HelloWorld   '), '@helloworld');
    expect(idempotentTest(' @  '), '@');
    expect(idempotentTest('  @AABBCC '), '@aabbcc');
  });
}
