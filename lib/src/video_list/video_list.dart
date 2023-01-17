import 'package:flutter/material.dart';
import 'video_item.dart';

class VideoList extends StatelessWidget {
  const VideoList(
      {super.key, required this.items, required this.onVideoSelected});
  final Function(VideoItem) onVideoSelected;

  final List<VideoItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Providing a restorationId allows the ListView to restore the
      // scroll position when a user leaves and returns to the app after it
      // has been killed while running in the background.
      restorationId: 'VideoList',
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = items[index];

        return ListTile(
          title: Text(item.title),
          leading: CircleAvatar(
            // TODO: Load thumbnail.
            foregroundImage: NetworkImage(item
                .thumbnailUrl), // AssetImage('assets/images/flutter_logo.png'),
          ),
          onTap: () => onVideoSelected(item),
        );
      },
    );
  }
}
