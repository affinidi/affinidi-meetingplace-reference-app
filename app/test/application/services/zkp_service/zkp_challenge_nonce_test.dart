import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/zkp_service/zkp_challenge_nonce.dart';

void main() {
  group('generateZkpChallengeNonce', () {
    test('returns 32 bytes', () {
      expect(generateZkpChallengeNonce(), hasLength(zkpChallengeNonceByteLength));
    });
  });

  group('zkpChallengeNonceToHex', () {
    test('encodes bytes as 64 lowercase hex characters', () {
      final bytes = List<int>.generate(32, (index) => index);

      expect(
        zkpChallengeNonceToHex(bytes),
        '000102030405060708090a0b0c0d0e0f'
        '101112131415161718191a1b1c1d1e1f',
      );
    });

    test('throws when length is not 32', () {
      expect(
        () => zkpChallengeNonceToHex([1, 2, 3]),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('32'),
          ),
        ),
      );
    });
  });
}
