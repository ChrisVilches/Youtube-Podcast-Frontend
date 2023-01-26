import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'device.dart';

const String ANDROID_DOWNLOAD_DIR = 'storage/emulated/0/Youtube-Podcast';

Future<bool> hasStoragePermission() async {
  final List<Permission> required;

  if (await requiresManageExternalStoragePermission()) {
    required = <Permission>[
      Permission.storage,
      Permission.manageExternalStorage,
    ];
  } else {
    required = <Permission>[
      Permission.storage,
    ];
  }

  final Map<Permission, PermissionStatus> status = await required.request();
  debugPrint(status.toString());
  return status.values
      .every((PermissionStatus p) => p == PermissionStatus.granted);
}

Directory _downloadDir() {
  if (Platform.isAndroid) {
    return Directory(ANDROID_DOWNLOAD_DIR);
  } else {
    throw Exception('Not implemented for this platform');
  }
}

Future<Directory> getValidDownloadDir() async {
  final Directory directory = _downloadDir();

  // ignore: avoid_slow_async_io
  if (await directory.exists()) {
    debugPrint('Download destination path exists: (${directory.path})');
  } else {
    debugPrint('Creating download destination path: ${directory.path}');
    await directory.create();
  }

  return directory;
}
