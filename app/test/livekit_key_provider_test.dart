import 'package:flutter_test/flutter_test.dart';

void main() {
  // MatrixLiveKitKeyProvider now uses per-participant LiveKit FrameCryptor
  // key management. The shared-key deriveSharedKey helper has been removed
  // in favour of the Matrix SDK distributing keys via to-device messages.
  // Integration-level testing for E2EE should be done via the Matrix E2EE
  // workflow integration tests.
  test('placeholder — see integration tests for E2EE coverage', () {});
}
