import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'src/app.dart';
import 'src/models/favorite_playlist.dart';
import 'src/services/favorite_playlist_service.dart';
import 'src/services/locator.dart';
import 'src/services/prepare_download_service.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/util/dotenv.dart';
import 'src/util/storage.dart';

void main() async {
  if (Platform.isAndroid) {
    final WidgetsBinding widgetsBinding =
        WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  await dotEnvLoad();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  if (Platform.isAndroid) {
    await FlutterDownloader.initialize(
      debug: true,
      ignoreSsl: true,
    );
  }

  final List<String> files = await getFilesStoredShallow();
  debugPrint('---------- FILES ----------');
  for (final String file in files) {
    debugPrint('File: $file');
  }
  debugPrint('---------------------------');

  await setUpLocator(navigatorKey: navigatorKey);
  initSocket();

  EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.dualRing;

  debugPrint('Saved playlists');
  for (final FavoritePlaylist fp
      in await serviceLocator.get<FavoritePlaylistService>().getAll()) {
    debugPrint(
      '${fp.id} | ${fp.author} | ${fp.isChannel ? 'channel' : 'playlist'}',
    );
  }

  final SettingsController ctrl = SettingsController(SettingsService());
  await ctrl.loadSettings();

  runApp(MyApp(settingsController: ctrl, navigatorKey: navigatorKey));
}
