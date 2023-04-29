import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/video_item_partial.dart';
import '../util/format.dart';
import 'video_options_menu.dart';
import 'weak_text.dart';

const double CARD_HEIGHT = 100;

// Assumes thumbnail ratio is 16:9 for all pictures.
const double THUMBNAIL_WIDTH = CARD_HEIGHT * 16 / 9;

class VideoItem extends StatelessWidget {
  const VideoItem({
    super.key,
    required this.item,
    required this.onDownloadPress,
    required this.beingPrepared,
  });

  final VideoItemPartial item;
  final Function() onDownloadPress;
  final bool beingPrepared;

  @override
  Widget build(final BuildContext context) {
    final Widget picture = Align(
      // ignore: avoid_redundant_argument_values
      alignment: Alignment.center,
      child: Image(
        fit: BoxFit.cover,
        image: CachedNetworkImageProvider(
          item.thumbnails.first.url,
        ),
      ),
    );

    final Widget duration = Opacity(
      opacity: 0.9,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          boxShadow: <BoxShadow>[BoxShadow(blurRadius: 2)],
        ),
        child: Text(
          removeHour00(formatTimeHHMMSS(item.duration ?? 0)),
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );

    final Widget thumbnailContainer = Stack(
      children: <Widget>[
        Container(
          height: CARD_HEIGHT,
          width: THUMBNAIL_WIDTH,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox.fromSize(
              size: const Size.fromRadius(48),
              child: picture,
            ),
          ),
        ),
        if (item.duration != null)
          Container(
            height: CARD_HEIGHT,
            width: THUMBNAIL_WIDTH,
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.only(right: 10, bottom: 5),
            child: ClipRRect(
              child: SizedBox.fromSize(
                child: duration,
              ),
            ),
          ),
      ],
    );

    final Widget top = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 5, left: 2),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: WeakText(item.author),
                )
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: VideoOptionsMenu(item: item),
        )
      ],
    );

    final Widget bottom = Align(
      alignment: Alignment.bottomRight,
      child: beingPrepared
          ? const TextButton(
              onPressed: null,
              // TODO: bug, sometimes this text gets stuck.
              //       One way to reproduce: Click on 'DOWNLOAD', then go to Details right away.
              //       Then go back, and the button should be stuck.
              //       One way to fix it would be to remove all prepared flags when the page is shown,
              //       but another way would be to: when the page is shown, query the data (which I think
              //       is a global store that triggers events to views) for the current prepared data.
              //       Data comes from PrepareDownloadController, but even the controller gets the data (events)
              //       from another component.
              child: Text('PREPARING...'),
            )
          : TextButton(
              onPressed: onDownloadPress,
              child: const Text('DOWNLOAD'),
            ),
    );

    final Widget content = Expanded(
      child: Column(
        children: <Widget>[Expanded(child: top), bottom],
      ),
    );

    final Widget card = Card(
      child: SizedBox(
        height: CARD_HEIGHT,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[thumbnailContainer, content],
        ),
      ),
    );

    return card;
  }
}
