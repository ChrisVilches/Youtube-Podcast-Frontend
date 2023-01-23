import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/video_item_partial.dart';
import '../views/video_detail_view.dart';
import 'video_options_menu.dart';

class VideoDetail extends StatelessWidget {
  const VideoDetail({
    super.key,
    required this.item,
    required this.onDownloadPress,
    required this.beingPrepared,
  });

  final VideoItemPartial item;
  final Function() onDownloadPress;
  final bool beingPrepared;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                foregroundImage: CachedNetworkImageProvider(
                  item.thumbnails.first.url,
                ),
              ),
              title: Text(item.title),
              subtitle: Text(item.videoId),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (BuildContext context) =>
                            VideoDetailView(item: item),
                      ),
                    );
                  },
                  child: const Text('DETAILS'),
                ),
                if (beingPrepared)
                  const TextButton(
                    onPressed: null,
                    child: Text('PREPARING...'),
                  ),
                if (!beingPrepared)
                  TextButton(
                    onPressed: onDownloadPress,
                    child: const Text('DOWNLOAD'),
                  ),
                VideoOptionsMenu(item: item)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
