import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_podcast/src/services/locator.dart';

void init() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  // ignore: discarded_futures
  setUpLocator(navigatorKey: navKey, clipboardPollSeconds: 10);
}
