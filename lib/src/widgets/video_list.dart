import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/prepare_download_controller.dart';
import '../models/video_item_partial.dart';
import 'video_detail.dart';

class VideoList extends StatelessWidget {
  const VideoList({super.key, required this.items});

  final List<VideoItemPartial> items;

  @override
  Widget build(BuildContext context) {
    return Consumer<PrepareDownloadController>(
      builder: (
        BuildContext context,
        PrepareDownloadController ctrl,
        _,
      ) =>
          ListView.builder(
        restorationId: 'VideoList',
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final VideoItemPartial item = items[index];

          return VideoDetail(
            item: item,
            onDownloadPress: () => ctrl.startPrepareProcess(item.videoId),
            beingPrepared: ctrl.beingPrepared.contains(item.videoId),
          );
        },
      ),
    );
  }
}
