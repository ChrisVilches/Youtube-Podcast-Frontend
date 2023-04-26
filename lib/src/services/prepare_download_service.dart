import 'dart:async';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import '../types.dart';

late final socket_io.Socket _socket;

final StreamController<VideoPreparedEvent> _videoPreparedEvents =
    StreamController<VideoPreparedEvent>();

class VideoPreparedEvent {
  VideoPreparedEvent(this.videoId, this.success);

  final VideoID videoId;
  final bool success;
}

StreamController<VideoPreparedEvent> get videoPreparedEvents =>
    _videoPreparedEvents;

void _onPreparedResult(final dynamic raw) {
  final Map<String, dynamic> data =
      jsonDecode(raw as String) as Map<String, dynamic>;
  final VideoID videoId = data['videoId'] as VideoID;
  final bool success = data['success'] as bool;
  videoPreparedEvents.add(VideoPreparedEvent(videoId, success));
}

void initSocket() {
  final Map<String, dynamic> opts = socket_io.OptionBuilder()
      .enableForceNew()
      .setPath(dotenv.env['SOCKET_IO_ENDPOINT_PATH']!)
      .setTransports(<String>['websocket', 'polling']).build();

  _socket = socket_io.io(dotenv.env['SOCKET_IO_ENDPOINT_BASE'], opts);

  _socket.onError((final dynamic data) => debugPrint(data.toString()));
  _socket.on('prepared-result', _onPreparedResult);
  _socket.onConnect((final _) => debugPrint('Connected to sockets correctly'));
  _socket.onDisconnect((final _) => debugPrint('Disconnected from Socket.IO'));
}

void waitForResult(final VideoID videoId) {
  _socket.emit('execute-prepare', videoId);
}
