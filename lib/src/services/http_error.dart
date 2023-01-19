import 'dart:convert';
import 'package:http/http.dart';

class HttpException implements Exception {
  HttpException(this.message);

  final String message;

  @override
  String toString() {
    return message;
  }
}

/// Parses a JSON object from a Response object.
/// Throws [HttpException] if the response doesn't have a
/// success status code.
Map<String, dynamic> toJson(Response res) {
  final Map<String, dynamic> parsedBody =
      jsonDecode(res.body) as Map<String, dynamic>;

  if (res.statusCode >= 400) {
    final String message =
        (parsedBody['message'] as String?) ?? 'Unknown error happened';
    throw HttpException(message);
  }

  return parsedBody;
}
