import 'package:clock/clock.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';

class DemoLivenessEvidenceSource implements LivenessEvidenceSource {
  const DemoLivenessEvidenceSource();

  static const _defaultThreshold = 80.0;
  static const _defaultScore = 99.0;
  static const _providerId = 'demo_liveness';

  @override
  Future<LivenessEvidence> getEvidence({required String holderDid}) async {
    final checkedAt = clock.now().toUtc();
    final compactTs = checkedAt.millisecondsSinceEpoch;
    return LivenessEvidence(
      providerId: _providerId,
      providerTransactionId: 'demo-$compactTs',
      livenessScore: _defaultScore,
      livenessThreshold: _defaultThreshold,
      checkedAt: checkedAt,
    );
  }
}
