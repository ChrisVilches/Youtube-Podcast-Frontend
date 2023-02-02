import 'dart:io';

import 'package:ffcache/ffcache.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'android_download_service.dart';
import 'clipboard_service.dart';
import 'download_service.dart';
import 'favorite_playlist_service.dart';
import 'pc_download_service.dart';
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

  serviceLocator.registerSingleton<FFCache>(FFCache());

  serviceLocator.registerSingleton<ClipboardService>(ClipboardService());

  final DownloadService dlServ =
      Platform.isAndroid ? AndroidDownloadService() : PcDownloadService();
  serviceLocator.registerSingleton<DownloadService>(dlServ);
}
