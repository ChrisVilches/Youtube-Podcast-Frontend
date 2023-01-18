import 'transcription_metadata.dart';
import 'video_item_partial.dart';

class VideoItem extends VideoItemPartial {
  const VideoItem(
    super.videoId,
    super.title,
    super.thumbnails,
    this.description,
    this.transcriptions,
  );

  final String description;
  final List<TranscriptionMetadata> transcriptions;

  static VideoItem from(Map<String, dynamic> obj) {
    final VideoItemPartial partial = VideoItemPartial.from(obj);

    final String description = obj['description'] as String;

    final List<TranscriptionMetadata> transcriptions =
        (obj['transcriptions'] as List<dynamic>)
            .map(
              (dynamic o) =>
                  TranscriptionMetadata.from(o as Map<String, dynamic>),
            )
            .toList();

    return VideoItem(
      partial.videoId,
      partial.title,
      partial.thumbnails,
      description,
      transcriptions,
    );
  }
}
