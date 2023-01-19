import 'package:flutter/material.dart';
import '../models/video_item_partial.dart';
import '../search_bar/video_detail.dart';

class VideoList extends StatelessWidget {
  const VideoList({
    super.key,
    required this.items,
    required this.onDownloadPress,
  });
  final Function(VideoItemPartial) onDownloadPress;

  final List<VideoItemPartial> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      restorationId: 'VideoList',
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final VideoItemPartial item = items[index];

        return VideoDetail(
          item: item,
          onDownloadPress: () => onDownloadPress(item),
        );
      },
    );
  }
}
