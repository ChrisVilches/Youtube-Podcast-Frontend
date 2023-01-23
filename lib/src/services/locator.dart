import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'android_download.dart';
import 'favorite_playlist_service.dart';
import 'snackbar_service.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setUpLocator(GlobalKey<NavigatorState> navigatorKey) async {
  serviceLocator
      .registerSingleton<SnackbarService>(SnackbarService(navigatorKey));
  serviceLocator.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );
  serviceLocator.registerSingleton<FavoritePlaylistService>(
    FavoritePlaylistService(),
  );

  if (Platform.isAndroid) {
    final AndroidDownloadService instance = AndroidDownloadService();
    await instance.init();
    serviceLocator.registerSingleton<AndroidDownloadService>(instance);
  }
}
