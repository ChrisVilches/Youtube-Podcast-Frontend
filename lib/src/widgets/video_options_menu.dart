import 'package:flutter/material.dart';
import '../models/video_item_partial.dart';
import '../services/download_tasks.dart';
import '../services/locator.dart';
import '../services/snackbar_service.dart';
import '../transcriptions/transcriptions_view.dart';
import '../util/storage.dart';
import '../views/video_detail_view.dart';

enum Option { Details, Transcriptions, ClearData }

class _PopupMenuItemContent extends StatelessWidget {
  const _PopupMenuItemContent({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(final BuildContext context) {
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

  Future<void> _seeDetails(final BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute<dynamic>(
          builder: (final BuildContext context) => VideoDetailView(item: item),
        ),
      );

  Future<void> _seeTranscriptions(final BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute<dynamic>(
          builder: (final BuildContext context) =>
              TranscriptionView(item: item),
        ),
      );

  Future<void> _clearData(final BuildContext context) async {
    final int removedTasks = await cleanTasks(item.videoId);

    if (removedTasks > 0) {
      serviceLocator.get<SnackbarService>().info('Data was removed');
    }

    debugPrint('Removed tasks: $removedTasks');
  }

  @override
  Widget build(final BuildContext context) {
    return PopupMenuButton<Option>(
      onSelected: (final Option value) async {
        switch (value) {
          case Option.Details:
            await _seeDetails(context);
            break;
          case Option.Transcriptions:
            await _seeTranscriptions(context);
            break;
          case Option.ClearData:
            await _clearData(context);
            break;
        }
      },
      itemBuilder: (final BuildContext context2) => <PopupMenuEntry<Option>>[
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
        if (usesFlutterDownloader())
          const PopupMenuItem<Option>(
            value: Option.ClearData,
            child: _PopupMenuItemContent(
              icon: Icons.clear_rounded,
              text: 'Clear data',
            ),
          )
      ],
    );
  }
}
