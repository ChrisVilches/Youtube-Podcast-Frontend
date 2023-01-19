import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/locator.dart';

const String themeKey = 'THEME';

class SettingsService {
  Future<ThemeMode> themeMode() async {
    final String? themeValue =
        serviceLocator.get<SharedPreferences>().getString(themeKey);

    if (themeValue == 'dark') {
      return ThemeMode.dark;
    }

    if (themeValue == 'light') {
      return ThemeMode.light;
    }

    return ThemeMode.system;
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    await serviceLocator
        .get<SharedPreferences>()
        .setString(themeKey, theme.name);
  }
}
