import 'package:test/test.dart';
import 'package:youtube_podcast/src/util/format.dart';

void main() {
  test(removeHour00, () {
    expect(removeHour00(' 00:00:yy'), ' 00:00:yy');
    expect(removeHour00('00:00:xx'), '00:xx');
    expect(removeHour00('00:12:23'), '12:23');
    expect(removeHour00('hello 00:12:23'), 'hello 00:12:23');
  });

  test(formatTimeHHMMSS, () {
    expect(formatTimeHHMMSS(0.0), '00:00:00.0');
    expect(formatTimeHHMMSS(0.9111), '00:00:00.9');
    expect(formatTimeHHMMSS(0.5), '00:00:00.5');
    expect(formatTimeHHMMSS(0.56), '00:00:00.5');
    expect(formatTimeHHMMSS(0.98), '00:00:00.9');
    expect(formatTimeHHMMSS(60.0), '00:01:00.0');
    expect(formatTimeHHMMSS(60.123), '00:01:00.1');
    expect(formatTimeHHMMSS(60.45), '00:01:00.4');
    expect(formatTimeHHMMSS(60.5), '00:01:00.5');
    expect(formatTimeHHMMSS(3600), '01:00:00.0');
    expect(formatTimeHHMMSS(3601), '01:00:01.0');
    expect(formatTimeHHMMSS(3660), '01:01:00.0');
    expect(formatTimeHHMMSS(3661), '01:01:01.0');
    expect(formatTimeHHMMSS(3661.4), '01:01:01.4');
    expect(formatTimeHHMMSS(3662.499), '01:01:02.4');
  });
}
