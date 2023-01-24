import 'transcription_metadata.dart';
import 'video_item_partial.dart';

class VideoItem extends VideoItemPartial {
  const VideoItem(
    super.videoId,
    super.title,
    super.thumbnails,
    super.author,
    this.description,
    this.transcriptions,
  );

  factory VideoItem.fromJson(Map<String, dynamic> obj) {
    final VideoItemPartial partial = VideoItemPartial.fromJson(obj);

    final String description = obj['description'] as String;

    final List<TranscriptionMetadata> transcriptions =
        (obj['transcriptions'] as List<dynamic>)
            .map(
              (dynamic o) =>
                  TranscriptionMetadata.fromJson(o as Map<String, dynamic>),
            )
            .toList();

    return VideoItem(
      partial.videoId,
      partial.title,
      partial.thumbnails,
      partial.author,
      description,
      transcriptions,
    );
  }

  final String description;
  final List<TranscriptionMetadata> transcriptions;
}
