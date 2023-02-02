import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/prepare_download_controller.dart';
import '../models/video_item_partial.dart';
import 'video_item.dart';

class VideoList extends StatelessWidget {
  const VideoList({super.key, required this.items});

  final List<VideoItemPartial> items;

  @override
  Widget build(final BuildContext context) {
    return Consumer<PrepareDownloadController>(
      builder: (
        final BuildContext context,
        final PrepareDownloadController ctrl,
        final _,
      ) =>
          ListView.builder(
        restorationId: 'VideoList',
        itemCount: items.length,
        itemBuilder: (final BuildContext context, final int index) {
          final VideoItemPartial item = items[index];

          return VideoItem(
            item: item,
            onDownloadPress: () => ctrl.startPrepareProcess(item.videoId),
            beingPrepared: ctrl.beingPrepared.contains(item.videoId),
          );
        },
      ),
    );
  }
}
