import 'dart:io';

import 'package:ffcache/ffcache.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'android_download.dart';
import 'clipboard_service.dart';
import 'favorite_playlist_service.dart';
import 'snackbar_service.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setUpLocator({
  required GlobalKey<NavigatorState> navigatorKey,
  required int clipboardPollSeconds,
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

  serviceLocator.registerSingleton<ClipboardService>(
    ClipboardService(
      pollSeconds: clipboardPollSeconds,
    ),
  );

  if (Platform.isAndroid) {
    serviceLocator
        .registerSingleton<AndroidDownloadService>(AndroidDownloadService());
    await AndroidDownloadService.init();
  }
}
