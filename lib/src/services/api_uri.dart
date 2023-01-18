import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;

String _urlPrefix() {
  return dotenv.env['API_URL']!;
}

Uri uri(String address) {
  final String url = path.join(_urlPrefix(), address);
  return Uri.parse(url);
}
