import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;

import '../models/video_item_partial.dart';

String _urlPrefix() {
  return dotenv.env['API_URL']!;
}

Uri uri(String address) {
  final String url = path.join(_urlPrefix(), address);
  return Uri.parse(url);
}

Uri downloadUri(VideoID videoId) {
  return uri('download?v=$videoId');
}
