import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_community_address.dart';

void main() {
  group('VtcCommunityAddress', () {
    test('reads the host and fingerprint of a did:webvh', () {
      final address = VtcCommunityAddress.of(
        'did:webvh:QmScid123456:VTC.Club.org:communities:football',
      )!;

      expect(address.host, 'vtc.club.org');
      expect(address.fingerprint, 'QmScid123456');
    });

    test('keeps the port of a host', () {
      final address = VtcCommunityAddress.of(
        'did:webvh:QmScid:localhost%3A8100',
      );

      expect(address?.host, 'localhost:8100');
    });

    test('reads the host of a did:web, which has no fingerprint', () {
      final address = VtcCommunityAddress.of('did:web:club.org:vtc')!;

      expect(address.host, 'club.org');
      expect(address.fingerprint, isNull);
      expect(address.groupedFingerprint, isNull);
    });

    test('refuses other DIDs and other percent escapes', () {
      for (final did in [
        'did:key:z6Mk',
        'did:webvh:QmScid',
        'did:webvh::club.org',
        'did:web:',
        'did:web:club%2Eorg',
        'https://club.org',
      ]) {
        expect(VtcCommunityAddress.of(did), isNull, reason: did);
      }
    });

    test('groups the fingerprint in fours', () {
      final address = VtcCommunityAddress.of('did:webvh:QmAbCdEfGhI:club.org');

      expect(address?.groupedFingerprint, 'QmAb CdEf GhI');
    });

    group('sharesDomainWith', () {
      const address = VtcCommunityAddress(
        host: 'vtc.club.org',
        fingerprint: 'Qm',
      );

      test('matches the same host, a parent domain and www.', () {
        for (final website in [
          'https://vtc.club.org',
          'https://club.org/about',
          'https://www.club.org',
          'https://shop.vtc.club.org',
        ]) {
          expect(
            address.sharesDomainWith(Uri.parse(website)),
            isTrue,
            reason: website,
          );
        }
      });

      test('does not match another or a lookalike domain', () {
        for (final website in [
          'https://club-org.net',
          'https://evilclub.org',
          'https://org',
          'https://shop.club.org',
        ]) {
          expect(
            address.sharesDomainWith(Uri.parse(website)),
            isFalse,
            reason: website,
          );
        }
      });

      test('ignores the port of the host', () {
        const local = VtcCommunityAddress(host: 'localhost:8100');

        expect(local.sharesDomainWith(Uri.parse('http://localhost')), isTrue);
      });
    });
  });
}
