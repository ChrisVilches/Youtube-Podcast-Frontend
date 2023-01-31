import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'device.dart';

Future<String> _filename() async {
  if (await isAndroidEmulator()) {
    return 'emulator';
  }

  if (Platform.isAndroid) {
    return 'production';
  }

  return kReleaseMode ? 'production' : 'development';
}

Future<void> dotEnvLoad() async {
  await dotenv.load(fileName: 'assets/.env.${await _filename()}');
}
