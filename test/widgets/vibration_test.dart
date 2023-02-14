import 'package:test/test.dart';
import 'package:youtube_podcast/src/widgets/vibration.dart';

void main() {
  group(VibrationController, () {
    test('throws error', () {
      final VibrationController ctrl = VibrationController();
      expect(ctrl.vibrate, throwsA(isA<Exception>()));
    });
  });
}
