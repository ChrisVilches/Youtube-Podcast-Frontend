import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromRGBO(0xaa, 0x01, 0x01, 1),
    brightness: Brightness.dark,
  ),
  fontFamily: 'WorkSans',
  popupMenuTheme: const PopupMenuThemeData(
    color: Color.fromRGBO(0xaa, 0x00, 0x00, 0.8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
    ),
  ),
);
