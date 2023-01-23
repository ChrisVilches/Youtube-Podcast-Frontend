import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<bool> _isAndroidEmulator() async {
  if (!Platform.isAndroid) {
    return false;
  }

  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  return !androidInfo.isPhysicalDevice;
}

Future<String> _filename() async {
  if (await _isAndroidEmulator()) {
    return 'emulator';
  }

  return kReleaseMode ? 'production' : 'development';
}

Future<void> dotEnvLoad() async {
  await dotenv.load(fileName: 'assets/.env.${await _filename()}');
}
