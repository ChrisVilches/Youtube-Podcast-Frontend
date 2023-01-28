import 'dart:async';

import 'package:flutter/services.dart';

// TODO: If the polling frequency is too low, it may not work as expected. (e.g. The user clicks on the "paste" button, but gets
//       a different text).
class ClipboardService {
  ClipboardService({required int pollSeconds}) : assert(pollSeconds >= 1) {
    poll = Timer.periodic(Duration(milliseconds: pollSeconds * 1000),
        (Timer timer) async {
      await _handlePolling();
    });
  }

  String _currentValue = '';
  final StreamController<String> _clipboardEvents = StreamController<String>();
  late final Timer poll;

  String get currentValue => _currentValue;

  StreamController<String> get clipboardEvents => _clipboardEvents;

  Future<String?> _getClipboardContent() async {
    if (!(await Clipboard.hasStrings())) {
      return null;
    }

    final ClipboardData? data = await Clipboard.getData('text/plain');
    return data?.text?.toString() ?? '';
  }

  Future<void> _handlePolling() async {
    final String? content = await _getClipboardContent();
    if (content == null || content == _currentValue) {
      return;
    }

    _currentValue = content;
    _clipboardEvents.add(_currentValue);
  }
}
