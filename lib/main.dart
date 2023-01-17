import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  // TODO: Implement this properly. For now, the file reading fails.
  // await dotenv.load(fileName: '../../assets/.env');

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final SettingsController ctrl = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await ctrl.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: ctrl));
}
