import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'src/app.dart';
import 'src/services/locator.dart';
import 'src/services/prepare_download_service.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  if (Platform.isAndroid) {
    final WidgetsBinding widgetsBinding =
        WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  await dotenv.load(
    fileName: kReleaseMode || Platform.isAndroid
        ? 'assets/.env.production'
        : 'assets/.env.development',
  );

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // TODO: I think this crashes on Linux even if it's inside the "if"
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
