import 'dart:io';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'sleep.dart';

Future<void> waitAndRemoveSplash() async {
  if (Platform.isAndroid) {
    await sleep(const Duration(seconds: 2));
    FlutterNativeSplash.remove();
  }
}
