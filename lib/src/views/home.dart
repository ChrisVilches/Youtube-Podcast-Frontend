import 'package:flutter/material.dart';
import '../search_bar/video_search.dart';

// TODO: I think this should be the video_search.dart file. But I can rearrange the files later.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const String _title = 'Youtube Podcast';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: const VideoSearch(),
      ),
    );
  }
}
