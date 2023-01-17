import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_podcast/src/services/download.dart';
import 'package:youtube_podcast/src/video_list/video_list.dart';

import '../video_list/video_item.dart';

class VideoSearch extends StatefulWidget {
  const VideoSearch({super.key});

  @override
  State<VideoSearch> createState() => VideoSearchState();
}

const MY_HARDCODED_PLAYLIST = 'PLGb9oxtniFL5J7fvfctISMnpxfA1pKDAB';

class VideoSearchState extends State<VideoSearch> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final searchController = TextEditingController(text: MY_HARDCODED_PLAYLIST);

  // TODO: This is for debugging only. It should be improved.
  String responseDisplay = '';

  List<VideoItem> videoItems = [];
  VideoItem? selectedVideoItem;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Enter your email',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;

                final input = searchController.value.text;

                List<VideoItem> res = [];

                if (input.contains('watch')) {
                  res = [await getVideoInfo(input)];
                } else {
                  res = await getVideosFromPlaylist(input);
                }

                setState(() {
                  videoItems = res;
                });
              },
              child: const Text('Load video(s)'),
            ),
          ),
          Text(selectedVideoItem == null
              ? 'Not selected'
              : '(${selectedVideoItem!.videoId}) | ${selectedVideoItem!.title}'),
          Row(
            // TODO: Layout sucks.
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
                child: ElevatedButton(
                  onPressed: selectedVideoItem == null
                      ? null
                      : () async {
                          final videoId = selectedVideoItem!.videoId;

                          setState(() {
                            responseDisplay = '';
                          });

                          final message = await prepareVideo(videoId);

                          setState(() {
                            responseDisplay = message;
                          });
                        },
                  child: const Text('Prepare'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: selectedVideoItem == null
                      ? null
                      : () async {
                          final VideoItem item = selectedVideoItem!;

                          // TODO: URL cannot be hardcoded here!!
                          final url = 'http://cloud.chrisvilches.com/yt/download?v=${item.videoId}';
                          final uri = Uri.parse(url);
                          await launchUrl(uri);
                        },
                  child: const Text('Download'),
                ),
              ),
            ],
          ),
          Text(responseDisplay),
          Expanded(
            child: VideoList(
              items: videoItems,
              onVideoSelected: (VideoItem item) {
                setState(() {
                  selectedVideoItem = item;
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
