import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'src/app.dart';
import 'src/services/locator.dart';
import 'src/services/prepare_download_service.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  await dotenv.load(
    fileName: kReleaseMode || Platform.isAndroid
        ? 'assets/.env.production'
        : 'assets/.env.development',
  );
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // TODO: Add platforms once they are tested.
  // TODO: I think this crashes on Linux even if it's inside the "if"
  if (Platform.isAndroid) {
    await FlutterDownloader.initialize(
      debug: true,
      ignoreSsl: true,
    );
  }

  await setUpLocator(navigatorKey);
  initSocket();

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final SettingsController ctrl = SettingsController(SettingsService());
  await ctrl.loadSettings();

  // TODO: What this comment says... use a splash screen.
  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: ctrl, navigatorKey: navigatorKey));
}
