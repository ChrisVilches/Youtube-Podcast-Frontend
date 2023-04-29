import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'clipboard_service.dart';
import 'download_logic.dart';
import 'download_logic/android_download_logic_io.dart';
import 'download_logic/download_logic_io.dart';
import 'download_logic/pc_download_logic_io.dart';
import 'favorite_playlist_service.dart';
import 'snackbar_service.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setUpLocator({
  required final GlobalKey<NavigatorState> navigatorKey,
}) async {
  serviceLocator
      .registerSingleton<SnackbarService>(SnackbarService(navigatorKey));
  serviceLocator.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );
  serviceLocator.registerSingleton<FavoritePlaylistService>(
    FavoritePlaylistService(),
  );

  serviceLocator.registerSingleton<ClipboardService>(ClipboardService());

  final DownloadLogicIO downloadLogicIO =
      Platform.isAndroid ? AndroidDownloadLogicIO() : PCDownloadLogicIO();
  final DownloadLogic downloadLogic = DownloadLogic(downloadLogicIO);
  serviceLocator.registerSingleton<DownloadLogic>(downloadLogic);
}
