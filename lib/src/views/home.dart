import 'package:flutter/material.dart';
import 'package:youtube_podcast/src/search_bar/video_search.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const String _title = 'Flutter Code Sample';

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
