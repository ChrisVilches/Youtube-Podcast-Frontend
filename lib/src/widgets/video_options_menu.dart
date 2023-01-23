import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/video_item_partial.dart';
import '../transcriptions/transcriptions_view.dart';
import '../views/video_detail_view.dart';

enum Option { Details, Transcriptions, OpenVideo }

class _PopupMenuItemContent extends StatelessWidget {
  const _PopupMenuItemContent({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(height: 50, width: 50, child: Icon(icon)),
        Text(text)
      ],
    );
  }
}

class VideoOptionsMenu extends StatelessWidget {
  const VideoOptionsMenu({super.key, required this.item});

  final VideoItemPartial item;

  Future<void> _seeDetails(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => VideoDetailView(item: item),
        ),
      );

  Future<void> _seeTranscriptions(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => TranscriptionView(item: item),
        ),
      );

  Future<void> _openVideo() =>
      launchUrl(Uri.parse('https://www.youtube.com/watch?v=${item.videoId}'));

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Option>(
      onSelected: (Option value) async {
        switch (value) {
          case Option.Details:
            await _seeDetails(context);
            break;
          case Option.Transcriptions:
            await _seeTranscriptions(context);
            break;
          case Option.OpenVideo:
            await _openVideo();
            break;
        }
      },
      itemBuilder: (BuildContext context2) => <PopupMenuEntry<Option>>[
        const PopupMenuItem<Option>(
          value: Option.Details,
          child: _PopupMenuItemContent(
            icon: Icons.info,
            text: 'Details',
          ),
        ),
        const PopupMenuItem<Option>(
          value: Option.Transcriptions,
          child: _PopupMenuItemContent(
            icon: Icons.text_fields,
            text: 'Transcriptions',
          ),
        ),
        const PopupMenuItem<Option>(
          value: Option.OpenVideo,
          child: _PopupMenuItemContent(
            icon: Icons.ondemand_video,
            text: 'Open video',
          ),
        )
      ],
    );
  }
}
