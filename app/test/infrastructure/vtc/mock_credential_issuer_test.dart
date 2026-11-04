import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/mock_credential_template.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/mock_credential_issuer.dart';
import 'package:ssi/ssi.dart';

/// Resolves `did:key` DIDs from the identifier alone.
class _DidKeyResolver implements DidResolver {
  @override
  Future<DidDocument> resolveDid(String did) async => DidKey.resolve(did);
}

void main() {
  const subject = 'did:webvh:QmAda:host.example';
  final template = mockCredentialTemplates.first;

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('issues a credential its issuer signed for the subject', () async {
    final issuer = MockCredentialIssuer();
    final now = DateTime.utc(2026, 11, 4);

    final credential = await issuer.issue(
      template,
      subjectDid: subject,
      now: now,
    );

    await EddsaJcs2022.verify(
      credential,
      purpose: ProofPurpose.assertionMethod,
      resolver: _DidKeyResolver(),
      expectedSigner: await issuer.did(),
    );
    expect(credential['issuer'], await issuer.did());
    expect(credential['type'], ['VerifiableCredential', template.type]);
    expect(credential['credentialSubject'], {
      'id': subject,
      ...template.claims,
    });
    expect(credential['validFrom'], '2026-11-04T00:00:00Z');
    expect(credential['validUntil'], '2027-11-04T00:00:00Z');
  });

  test('keeps one issuer across instances', () async {
    final first = await MockCredentialIssuer().did();

    expect(await MockCredentialIssuer().did(), first);
    expect(first, startsWith('did:key:'));
  });

  test('gives one id per template and subject', () async {
    final issuer = MockCredentialIssuer();
    String? idOf(Map<String, dynamic> credential) =>
        credential['id'] as String?;

    final once = await issuer.issue(template, subjectDid: subject);
    final again = await issuer.issue(template, subjectDid: subject);
    final other = await issuer.issue(
      template,
      subjectDid: 'did:webvh:QmBo:host.example',
    );
    final another = await issuer.issue(
      mockCredentialTemplates.last,
      subjectDid: subject,
    );

    expect(idOf(once), startsWith('urn:uuid:'));
    expect(idOf(again), idOf(once));
    expect(idOf(other), isNot(idOf(once)));
    expect(idOf(another), isNot(idOf(once)));
  });
}
