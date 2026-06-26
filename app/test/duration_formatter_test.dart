import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/helpers/duration_formatter.dart';

void main() {
  group('formatDuration', () {
    test('formats zero as 00:00', () {
      expect(formatDuration(0), '00:00');
    });

    test('pads seconds below ten', () {
      expect(formatDuration(5), '00:05');
    });

    test('rolls seconds into minutes at sixty', () {
      expect(formatDuration(60), '01:00');
    });

    test('formats a mixed minutes-and-seconds value', () {
      expect(formatDuration(75), '01:15');
    });

    test('formats exactly one hour as 1:00:00', () {
      expect(formatDuration(3600), '1:00:00');
    });

    test('formats one hour five minutes twenty-five seconds as 1:05:25', () {
      expect(formatDuration(3600 + 5 * 60 + 25), '1:05:25');
    });

    test('pads minutes and seconds below ten when hours are present', () {
      expect(formatDuration(3600 + 60 + 1), '1:01:01');
    });

    test('does not show hours component below 3600 seconds', () {
      expect(formatDuration(3599), '59:59');
    });
  });
}
