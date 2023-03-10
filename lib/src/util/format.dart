String formatTimeHHMMSSms(final double time) {
  final Duration duration = Duration(milliseconds: (time * 1000).round());

  final String hhmmss = <int>[
    duration.inHours,
    duration.inMinutes,
    duration.inSeconds
  ]
      .map((final int seg) => seg.remainder(60).toString().padLeft(2, '0'))
      .join(':');
  final String ms =
      ((time - time.floor()) * 10).toString().padLeft(1, '0').substring(0, 1);

  return '$hhmmss.$ms';
}

String formatTimeHHMMSS(final int seconds) {
  final Duration duration = Duration(seconds: seconds);

  return <int>[duration.inHours, duration.inMinutes, duration.inSeconds]
      .map((final int seg) => seg.remainder(60).toString().padLeft(2, '0'))
      .join(':');
}

String removeHour00(final String time) {
  if (time.startsWith('00:')) {
    return time.substring(3);
  }

  return time;
}

String sanitizeChannelHandle(final String s) {
  String res = s.trim().toLowerCase();
  if (!res.startsWith('@')) {
    res = '@$res';
  }
  return res;
}
