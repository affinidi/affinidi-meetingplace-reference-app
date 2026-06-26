import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_livekit_flutter/src/delegates/flutter_matrix_rtc_delegate.dart';

import '../fakes/fake_base_key_provider.dart';

void main() {
  group('FlutterMatrixRTCDelegate', () {
    late FlutterMatrixRTCDelegate delegate;

    setUp(() {
      delegate = FlutterMatrixRTCDelegate();
    });

    test('keyProvider is null when no key provider has been set', () {
      expect(delegate.keyProvider, isNull);
    });

    test('keyProvider is non-null after updateKeyProvider is called', () {
      delegate.updateKeyProvider(FakeKeyProvider());
      expect(delegate.keyProvider, isNotNull);
    });

    test('keyProvider returns null after updateKeyProvider(null)', () {
      delegate.updateKeyProvider(FakeKeyProvider());
      delegate.updateKeyProvider(null);
      expect(delegate.keyProvider, isNull);
    });

    test('isWeb is false', () {
      expect(delegate.isWeb, isFalse);
    });

    test('canHandleNewCall is false', () {
      expect(delegate.canHandleNewCall, isFalse);
    });
  });
}
