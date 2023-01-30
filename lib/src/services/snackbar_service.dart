import 'package:flutter/material.dart';

const double OPACITY = 0.95;

// TODO: Flutter bug? SnackBarAction.textColor should be configurable by using a Color instance,
//       but it only works if a MaterialStateColor is passed.
//       Eventually try setting just a Color instance. If this issue was solved, the snackbar action text label
//       should have the correct (the one specified) color.
final MaterialStateColor actionTextColor =
    MaterialStateColor.resolveWith((_) => Colors.white);

/// Styles (colors, etc) are hardcoded in this class. They look the same for both the dark and light themes.
class SnackbarService {
  const SnackbarService(GlobalKey<NavigatorState> navigatorKey)
      : _navigatorKey = navigatorKey;

  final GlobalKey<NavigatorState> _navigatorKey;

  void _show(String msg, Color backgroundColor, {SnackBarAction? action}) {
    SnackBarAction? actionWithColor;

    if (action != null) {
      actionWithColor = SnackBarAction(
        label: action.label,
        onPressed: action.onPressed,
        textColor: actionTextColor,
      );
    }

    ScaffoldMessenger.of(_navigatorKey.currentContext!).clearSnackBars();
    ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        action: actionWithColor,
      ),
    );
  }

  void success(String msg, {SnackBarAction? action}) {
    _show(msg, const Color.fromRGBO(0, 140, 0, OPACITY), action: action);
  }

  void danger(String msg, {SnackBarAction? action}) {
    _show(msg, const Color.fromRGBO(0xFF, 0x57, 0x33, OPACITY), action: action);
  }

  void info(String msg, {SnackBarAction? action}) {
    _show(msg, const Color.fromRGBO(0x47, 0x89, 0xb3, OPACITY), action: action);
  }
}
