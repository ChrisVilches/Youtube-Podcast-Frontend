import 'package:flutter/material.dart';
import '../models/video_item.dart';
import '../models/video_item_partial.dart';
import '../services/youtube.dart';

class VideoDetailView extends StatelessWidget {
  const VideoDetailView(VideoItemPartial item, {super.key}) : _item = item;

  final VideoItemPartial _item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_item.title),
      ),
      body: FutureBuilder<VideoItem>(
        future: getVideoInfo(_item.videoId),
        builder: (BuildContext context, AsyncSnapshot<VideoItem> snapshot) {
          if (snapshot.hasData) {
            final VideoItem detail = snapshot.data!;

            return Column(
              children: <Widget>[
                SingleChildScrollView(
                  child: Text(detail.description),
                )
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error happened (${snapshot.error})');
          }

          return const Text('Loading...');
        },
      ),
    );
  }
}
