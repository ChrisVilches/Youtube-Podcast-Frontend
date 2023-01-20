import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'playlist_favorite.dart';
import 'snackbar_service.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setUpLocator(GlobalKey<NavigatorState> navigatorKey) async {
  serviceLocator
      .registerSingleton<SnackbarService>(SnackbarService(navigatorKey));
  serviceLocator.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );
  serviceLocator.registerSingleton<PlaylistFavoriteService>(
    PlaylistFavoriteService(),
  );
}
