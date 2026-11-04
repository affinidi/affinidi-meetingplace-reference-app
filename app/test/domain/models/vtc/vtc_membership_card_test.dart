import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_membership_card.dart';

void main() {
  Map<String, dynamic> card({
    List<String> types = const [
      'VerifiableCredential',
      'DTGCredential',
      'MembershipCredential',
    ],
    Object? issuer = 'did:webvh:community',
    Object? subject = const {'id': 'did:webvh:persona'},
  }) => {
    'id': 'urn:uuid:vmc',
    'type': types,
    'issuer': ?issuer,
    'validFrom': '2026-11-04T10:00:00Z',
    'validUntil': '2027-11-04T10:00:00Z',
    'credentialSubject': ?subject,
  };

  group('VtcMembershipCard', () {
    test('reads a membership card', () {
      final credential = card();

      final read = VtcMembershipCard.fromCredential(credential)!;

      expect(read.issuer, 'did:webvh:community');
      expect(read.memberDid, 'did:webvh:persona');
      expect(read.validFrom, DateTime.utc(2026, 11, 4, 10));
      expect(read.validUntil, DateTime.utc(2027, 11, 4, 10));
      expect(read.personhood, isFalse);
      expect(read.credential, same(credential));
    });

    test('says when the card states personhood', () {
      final read = VtcMembershipCard.fromCredential(
        card(
          types: const [
            'VerifiableCredential',
            'MembershipCredential',
            'PersonhoodCredential',
          ],
        ),
      );

      expect(read?.personhood, isTrue);
    });

    test('reads an issuer and subject in their other forms', () {
      final read = VtcMembershipCard.fromCredential(
        card(
          issuer: const {'id': 'did:webvh:community'},
          subject: const [
            {'id': 'did:webvh:persona'},
          ],
        ),
      );

      expect(read?.issuer, 'did:webvh:community');
      expect(read?.memberDid, 'did:webvh:persona');
    });

    test('reads no role credential', () {
      expect(
        VtcMembershipCard.fromCredential(
          card(types: const ['VerifiableCredential', 'AuthorityCredential']),
        ),
        isNull,
      );
    });

    test('reads no card without an issuer or a subject', () {
      expect(VtcMembershipCard.fromCredential(card(issuer: null)), isNull);
      expect(VtcMembershipCard.fromCredential(card(subject: null)), isNull);
    });
  });
}
