import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/demo_liveness_evidence_source.dart';

void main() {
  group('DemoLivenessEvidenceSource', () {
    test('returns passing demo evidence', () async {
      const source = DemoLivenessEvidenceSource();
      final evidence = await source.getEvidence(
        holderDid: 'did:example:holder',
      );

      expect(evidence.providerId, 'demo_liveness');
      expect(evidence.isLive, isTrue);
      expect(evidence.providerTransactionId, startsWith('demo-'));
    });
  });
}
