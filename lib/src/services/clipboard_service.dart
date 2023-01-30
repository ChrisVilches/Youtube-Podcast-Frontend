import 'dart:async';

import 'package:flutter/services.dart';

class ClipboardService {
  Future<String> getClipboardContent() async {
    if (!(await Clipboard.hasStrings())) {
      return '';
    }

    final ClipboardData? data = await Clipboard.getData('text/plain');
    return data?.text?.toString() ?? '';
  }
}
