import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/video_item.dart';
import '../models/video_item_partial.dart';
import '../services/youtube.dart';
import '../widgets/weak_text.dart';

class VideoDetailView extends StatefulWidget {
  const VideoDetailView({super.key, required this.item});
  final VideoItemPartial item;

  @override
  State<VideoDetailView> createState() => _VideoDetailViewState();
}

class _VideoDetailViewState extends State<VideoDetailView> {
  late Future<VideoItem> _future;

  @override
  void initState() {
    super.initState();
    // ignore: discarded_futures
    _future = getVideoInfo(widget.item.videoId);
  }

  Future<void> _onOpen(LinkableElement link) async {
    final Uri uri = Uri.parse(link.url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch $link');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
      ),
      body: FutureBuilder<VideoItem>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<VideoItem> snapshot) {
          late Widget content;

          if (snapshot.hasData) {
            content = Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    snapshot.data!.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: WeakText(snapshot.data!.author),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Linkify(
                    onOpen: _onOpen,
                    text: snapshot.data!.description,
                  ),
                )
              ],
            );
          } else if (snapshot.hasError) {
            content = Text('Error happened (${snapshot.error})');
          } else {
            content = const Center(child: CircularProgressIndicator());
          }

          return Container(
            constraints: const BoxConstraints.expand(),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }
}
