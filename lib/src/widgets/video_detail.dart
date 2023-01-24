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
    // TODO: Dimensions may be slightly incorrect, but it looks good for now anyway.
    final Widget picture = Container(
      width: 180,
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
                  child: Text(item.title, overflow: TextOverflow.ellipsis, maxLines: 4,),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.author,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Color.fromRGBO(200, 200, 200, 1),
                    ),
                  ),
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
        height: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[picture, content],
        ),
      ),
    );

    return card;
  }
}
