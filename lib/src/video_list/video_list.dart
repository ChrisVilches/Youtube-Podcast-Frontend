import 'package:flutter/material.dart';
import '../models/video_item_partial.dart';

class VideoList extends StatelessWidget {
  const VideoList({
    super.key,
    required this.items,
    required this.onVideoSelected,
  });
  final Function(VideoItemPartial) onVideoSelected;

  final List<VideoItemPartial> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      restorationId: 'VideoList',
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final VideoItemPartial item = items[index];

        return ListTile(
          title: Text(item.title),
          leading: CircleAvatar(
            foregroundImage: NetworkImage(item.thumbnails[0].url),
          ),
          onTap: () => onVideoSelected(item),
        );
      },
    );
  }
}
