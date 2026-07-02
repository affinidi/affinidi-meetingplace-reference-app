import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/duration_extensions.dart';

void main() {
  group('CallDurationFormatter.label', () {
    test('formats seconds only', () {
      expect(const Duration(seconds: 5).label, '00:05');
    });

    test('formats minutes and seconds', () {
      expect(const Duration(minutes: 2, seconds: 34).label, '02:34');
    });

    test('pads single-digit minutes', () {
      expect(const Duration(minutes: 1, seconds: 0).label, '01:00');
    });

    test('formats exactly one hour', () {
      expect(const Duration(hours: 1).label, '1:00:00');
    });

    test('formats hours, minutes, and seconds', () {
      expect(
        const Duration(hours: 1, minutes: 25, seconds: 7).label,
        '1:25:07',
      );
    });

    test('zero duration is 00:00', () {
      expect(Duration.zero.label, '00:00');
    });
  });
}
