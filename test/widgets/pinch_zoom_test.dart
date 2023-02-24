import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:youtube_podcast/src/widgets/pinch_zoom.dart';

void main() {
  group(PinchZoom, () {
    test('throws error', () {
      expect(
        () => PinchZoom(
          backgroundColor: Colors.green,
          maxScale: 0.5,
          child: const Text(''),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
