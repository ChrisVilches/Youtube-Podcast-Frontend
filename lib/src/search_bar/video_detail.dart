import 'package:flutter/material.dart';
import '../models/video_item_partial.dart';
import '../transcriptions/transcriptions_view.dart';
import '../views/video_detail_view.dart';

enum Option { Detail, Transcriptions }

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
                PopupMenuButton<Option>(
                  onSelected: (Option value) {
                    switch (value) {
                      case Option.Detail:
                        Navigator.push(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) =>
                                VideoDetailView(item),
                          ),
                        );
                        break;
                      case Option.Transcriptions:
                        Navigator.push(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) =>
                                TranscriptionView(item: item),
                          ),
                        );
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context2) =>
                      <PopupMenuEntry<Option>>[
                    const PopupMenuItem<Option>(
                      value: Option.Detail,
                      child: Text('Detail'),
                    ),
                    const PopupMenuItem<Option>(
                      value: Option.Transcriptions,
                      child: Text('Transcriptions'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
