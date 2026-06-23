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

    test('formats values beyond an hour without truncating minutes', () {
      expect(formatDuration(3661), '61:01');
    });
  });
}
