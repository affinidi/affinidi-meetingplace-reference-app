import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/liveness_evidence_source.dart';

void main() {
  group('DemoAwsLivenessEvidenceSource', () {
    test('returns AWS-shaped successful evidence', () async {
      const source = DemoAwsLivenessEvidenceSource();
      final evidence = await source.getEvidence(holderDid: 'did:key:z6Mkh');

      expect(evidence.providerId, 'aws_rekognition');
      expect(evidence.providerTransactionId, startsWith('demo-aws-'));
      expect(evidence.livenessScore, greaterThanOrEqualTo(80));
      expect(evidence.livenessThreshold, equals(80));
      expect(evidence.isLive, isTrue);
    });
  });
}
