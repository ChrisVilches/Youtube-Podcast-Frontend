import 'package:flutter/material.dart';
import '../models/video_item_partial.dart';
import '../transcriptions/transcriptions_view.dart';
import '../views/video_detail_view.dart';

enum Option { Details, Transcriptions }

class VideoOptionsMenu extends StatelessWidget {
  const VideoOptionsMenu({super.key, required this.item});

  final VideoItemPartial item;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Option>(
      onSelected: (Option value) {
        switch (value) {
          case Option.Details:
            Navigator.push(
              context,
              MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => VideoDetailView(item),
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
      itemBuilder: (BuildContext context2) => <PopupMenuEntry<Option>>[
        const PopupMenuItem<Option>(
          value: Option.Details,
          child: Text('Details'),
        ),
        const PopupMenuItem<Option>(
          value: Option.Transcriptions,
          child: Text('Transcriptions'),
        ),
      ],
    );
  }
}
