import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/duration_extensions.dart';

void main() {
  group('Duration.label', () {
    test('formats zero as 00:00', () {
      expect(Duration.zero.label, '00:00');
    });

    test('pads seconds below ten', () {
      expect(const Duration(seconds: 5).label, '00:05');
    });

    test('rolls seconds into minutes at sixty', () {
      expect(const Duration(seconds: 60).label, '01:00');
    });

    test('formats a mixed minutes-and-seconds value', () {
      expect(const Duration(seconds: 75).label, '01:15');
    });

    test('formats exactly one hour as 1:00:00', () {
      expect(const Duration(seconds: 3600).label, '1:00:00');
    });

    test('formats one hour five minutes twenty-five seconds as 1:05:25', () {
      expect(const Duration(seconds: 3600 + 5 * 60 + 25).label, '1:05:25');
    });

    test('pads minutes and seconds below ten when hours are present', () {
      expect(const Duration(seconds: 3600 + 60 + 1).label, '1:01:01');
    });

    test('does not show hours component below 3600 seconds', () {
      expect(const Duration(seconds: 3599).label, '59:59');
    });
  });
}
