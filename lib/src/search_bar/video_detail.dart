import 'package:flutter/material.dart';
import '../models/video_item_partial.dart';
import '../views/video_detail_view.dart';

class VideoDetail extends StatelessWidget {
  const VideoDetail({
    super.key,
    required this.item,
    required this.onDownloadPress,
  });

  final VideoItemPartial item;
  final Function() onDownloadPress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                // TODO: Make the image larger. Maybe use a custom list tile container.
                foregroundImage: NetworkImage(item.thumbnails.last.url),
              ),
              title: Text(item.title),
              subtitle: Text(item.videoId),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (BuildContext context) =>
                            VideoDetailView(item),
                      ),
                    );
                  },
                  child: const Text('DETAILS'),
                ),
                TextButton(
                  onPressed: onDownloadPress,
                  child: const Text('DOWNLOAD'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
