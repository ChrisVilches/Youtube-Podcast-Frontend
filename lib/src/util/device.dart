import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

Future<bool> _isAndroid11OrHigher() async {
  if (!Platform.isAndroid) {
    return false;
  }

  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final int version = int.parse(androidInfo.version.release);
  return version >= 11;
}

Future<bool> requiresManageExternalStoragePermission() {
  return _isAndroid11OrHigher();
}

Future<bool> isAndroidEmulator() async {
  if (!Platform.isAndroid) {
    return false;
  }

  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  return !androidInfo.isPhysicalDevice;
}
