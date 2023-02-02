import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_item.dart';
import '../models/video_item_partial.dart';
import '../services/youtube.dart';
import 'transcriptions_controller.dart';
import 'transcriptions_list.dart';
import 'transcriptions_menu.dart';

class TranscriptionView extends StatefulWidget {
  const TranscriptionView({super.key, required this.item});
  final VideoItemPartial item;

  @override
  State<TranscriptionView> createState() => _TranscriptionViewState();
}

class _TranscriptionViewState extends State<TranscriptionView> {
  late final Future<VideoItem> _future;

  @override
  void initState() {
    // ignore: discarded_futures
    _future = getVideoInfo(widget.item.videoId);
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
      ),
      body: FutureBuilder<VideoItem>(
        future: _future,
        builder: (
          final BuildContext context,
          final AsyncSnapshot<VideoItem> snapshot,
        ) {
          if (snapshot.hasData) {
            final VideoItem detail = snapshot.data!;

            return ChangeNotifierProvider<TranscriptionsController>(
              create: (final BuildContext context) =>
                  TranscriptionsController(detail),
              child: Column(
                children: <Widget>[
                  const Center(child: TranscriptionMenu()),
                  Consumer<TranscriptionsController>(
                    builder: (
                      final BuildContext context,
                      final TranscriptionsController ctrl,
                      final _,
                    ) {
                      if (ctrl.result.isNotEmpty &&
                          ctrl.selectedLanguage != null) {
                        return Expanded(
                          child: TranscriptionsList(transcription: ctrl.result),
                        );
                      } else if (ctrl.error != null) {
                        return Text(ctrl.error!);
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error happened (${snapshot.error})');
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
