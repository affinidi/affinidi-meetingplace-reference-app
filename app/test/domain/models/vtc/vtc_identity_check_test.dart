import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_identity_check.dart';

void main() {
  const community = 'did:webvh:community';

  Map<String, dynamic> statement({
    Object? issuer = community,
    String predicate = 'https://registry.trustoverip.org/dtg/vsc/vetted/1',
    Map<String, dynamic>? value,
    List<String> types = const [
      'VerifiableCredential',
      'DTGCredential',
      'StatementCredential',
    ],
  }) => {
    'id': 'urn:uuid:check',
    'type': types,
    'issuer': ?issuer,
    'issuerScope': 'public',
    'validFrom': '2026-11-04T10:00:00Z',
    'validUntil': '2027-11-04T10:00:00Z',
    'credentialSubject': {
      'id': 'did:webvh:persona',
      'predicate': predicate,
      'object': {
        'value':
            value ??
            {
              'community': community,
              'method': 'inPerson',
              'documentClasses': ['nationalId'],
              'claimsVerified': ['name.legal'],
              'livenessConfirmed': true,
            },
      },
    },
  };

  group('VtcIdentityCheck', () {
    test('reads the community identity check', () {
      final credential = statement();

      final check = VtcIdentityCheck.fromCredential(
        credential,
        communityDid: community,
      )!;

      expect(check.memberDid, 'did:webvh:persona');
      expect(check.method, 'inPerson');
      expect(check.documentClasses, ['nationalId']);
      expect(check.claimsVerified, ['name.legal']);
      expect(check.livenessConfirmed, isTrue);
      expect(check.validFrom, DateTime.utc(2026, 11, 4, 10));
      expect(check.validUntil, DateTime.utc(2027, 11, 4, 10));
      expect(check.credential, same(credential));
    });

    test('reads an issuer as an object and a method it does not know', () {
      final check = VtcIdentityCheck.fromCredential(
        statement(
          issuer: const {'id': community},
          value: const {
            'community': community,
            'method': 'byCarrierPigeon',
            'claimsVerified': <String>[],
            'livenessConfirmed': false,
          },
        ),
        communityDid: community,
      );

      expect(check?.method, 'byCarrierPigeon');
      expect(check?.documentClasses, isEmpty);
      expect(check?.livenessConfirmed, isFalse);
    });

    test('reads no endorsement as an identity check', () {
      expect(
        VtcIdentityCheck.fromCredential(
          statement(
            predicate: 'https://registry.trustoverip.org/dtg/vsc/endorses/1',
          ),
          communityDid: community,
        ),
        isNull,
      );
    });

    test('reads no check of another community or by another issuer', () {
      for (final credential in [
        statement(issuer: 'did:webvh:other'),
        statement(issuer: null),
        statement(
          value: const {'community': 'did:webvh:other', 'method': 'inPerson'},
        ),
      ]) {
        expect(
          VtcIdentityCheck.fromCredential(credential, communityDid: community),
          isNull,
        );
      }
    });

    test('reads no other credential type or one without a method', () {
      expect(
        VtcIdentityCheck.fromCredential(
          statement(
            types: const ['VerifiableCredential', 'MembershipCredential'],
          ),
          communityDid: community,
        ),
        isNull,
      );
      expect(
        VtcIdentityCheck.fromCredential(
          statement(value: const {'community': community}),
          communityDid: community,
        ),
        isNull,
      );
    });
  });
}
