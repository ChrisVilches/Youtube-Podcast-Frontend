import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/video_item.dart';
import '../models/video_item_partial.dart';
import '../services/youtube.dart';

class VideoDetailView extends StatelessWidget {
  const VideoDetailView(VideoItemPartial item, {super.key}) : _item = item;

  final VideoItemPartial _item;

  Future<void> _onOpen(LinkableElement link) async {
    final Uri uri = Uri.parse(link.url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch $link');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_item.title),
      ),
      body: FutureBuilder<VideoItem>(
        // TODO: This may execute multiple times.
        //       https://stackoverflow.com/questions/52249578/how-to-deal-with-unwanted-widget-build
        future: getVideoInfo(_item.videoId),
        builder: (BuildContext context, AsyncSnapshot<VideoItem> snapshot) {
          late Widget content;

          if (snapshot.hasData) {
            content = Linkify(
              onOpen: _onOpen,
              text: snapshot.data!.description,
            );
          } else if (snapshot.hasError) {
            content = Text('Error happened (${snapshot.error})');
          } else {
            content = const Text('Loading...');
          }

          return Container(
            constraints: const BoxConstraints.expand(),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }
}
