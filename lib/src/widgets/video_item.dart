import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/video_item_partial.dart';
import 'video_options_menu.dart';
import 'weak_text.dart';

// TODO: Pictures look good (size) but the text gets fucked up (the title gets stacked on top of the "DOWNLOAD" button)

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
  Widget build(BuildContext context) {
    final Widget picture = Container(
      height: CARD_HEIGHT,
      width: THUMBNAIL_WIDTH,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox.fromSize(
          size: const Size.fromRadius(48),
          child: Image(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(
              item.thumbnails.first.url,
            ),
          ),
        ),
      ),
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
        height: CARD_HEIGHT * 1.1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[picture, content],
        ),
      ),
    );

    return card;
  }
}
