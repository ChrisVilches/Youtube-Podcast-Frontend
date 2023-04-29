import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'device.dart';

const String _ANDROID_DOWNLOAD_DIR = 'storage/emulated/0/Youtube-Podcast';

Future<bool> deviceHasStoragePermission() async {
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
      .every((final PermissionStatus p) => p == PermissionStatus.granted);
}

Directory _downloadDir() {
  if (Platform.isAndroid) {
    return Directory(_ANDROID_DOWNLOAD_DIR);
  } else {
    throw Exception('Not implemented for this platform');
  }
}

Future<String> getFileSHA1(final String filePath) async {
  final File file = File(filePath);
  final Uint8List contents = await file.readAsBytes();
  return sha1.convert(contents).toString();
}

bool usesFlutterDownloader() => Platform.isAndroid;

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

MethodChannel? _platform;

Future<List<String>> getFilesStoredShallow() async {
  if (!Platform.isAndroid) {
    return List<String>.empty();
  }

  _platform ??= const MethodChannel('youtube_podcast_methods_channel');

  try {
    final List<Object?>? files = await _platform!.invokeMethod(
      'getFileList',
      <String, String>{'path': _ANDROID_DOWNLOAD_DIR},
    );
    return List<String>.from(files ?? <Object?>[]);
  } catch (e) {
    debugPrint('Kotlin error');
    debugPrint(e.toString());
    rethrow;
  }
}
