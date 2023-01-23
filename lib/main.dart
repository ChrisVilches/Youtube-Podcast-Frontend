import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'src/app.dart';
import 'src/services/locator.dart';
import 'src/services/prepare_download_service.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/util/dotenv.dart';

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

  await setUpLocator(navigatorKey);
  initSocket();

  final SettingsController ctrl = SettingsController(SettingsService());
  await ctrl.loadSettings();

  runApp(MyApp(settingsController: ctrl, navigatorKey: navigatorKey));
}
