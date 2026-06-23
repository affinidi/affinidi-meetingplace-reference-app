import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/secure_storage/secure_storage.dart';

void main() {
  group('SecureStorage.provideDeviceId', () {
    late SecureStorage storage;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      storage = SecureStorage();
    });

    test('generates a UUID v4 on first call', () async {
      final deviceId = await storage.provideDeviceId();

      expect(deviceId, isNotEmpty);
      expect(
        deviceId,
        matches(
          RegExp(
            // ignore: lines_longer_than_80_chars
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    });

    test('returns the same ID on subsequent calls', () async {
      final first = await storage.provideDeviceId();
      final second = await storage.provideDeviceId();

      expect(second, equals(first));
    });

    test('returns pre-existing ID from storage without overwriting', () async {
      const existingId = 'pre-existing-device-id';
      FlutterSecureStorage.setMockInitialValues({'deviceId': existingId});
      storage = SecureStorage();

      final deviceId = await storage.provideDeviceId();

      expect(deviceId, equals(existingId));
    });

    test(
      'new storage instance reads same ID persisted by earlier instance',
      () async {
        final id = await storage.provideDeviceId();

        final storage2 = SecureStorage();
        final id2 = await storage2.provideDeviceId();

        expect(id2, equals(id));
      },
    );
  });
}
