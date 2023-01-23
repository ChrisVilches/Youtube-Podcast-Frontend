import 'package:flutter/material.dart';
import 'package:youtube_podcast/src/services/locator.dart';

void init() {
  final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  // ignore: discarded_futures
  setUpLocator(navKey);
}
