import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final livenessEvidenceSourceProvider = Provider<LivenessEvidenceSource>(
  (ref) => const DemoAwsLivenessEvidenceSource(),
  name: 'livenessEvidenceSourceProvider',
);

class LivenessEvidence {
  const LivenessEvidence({
    required this.providerId,
    required this.providerTransactionId,
    required this.livenessScore,
    required this.livenessThreshold,
    required this.checkedAt,
  });

  final String providerId;
  final String providerTransactionId;
  final double livenessScore;
  final double livenessThreshold;
  final DateTime checkedAt;

  bool get isLive => livenessScore >= livenessThreshold;
}

abstract interface class LivenessEvidenceSource {
  Future<LivenessEvidence> getEvidence({required String holderDid});
}

class DemoAwsLivenessEvidenceSource implements LivenessEvidenceSource {
  const DemoAwsLivenessEvidenceSource();

  static const _defaultThreshold = 80.0;
  static const _defaultScore = 99.0;

  @override
  Future<LivenessEvidence> getEvidence({required String holderDid}) async {
    final checkedAt = clock.now().toUtc();
    final compactTs = checkedAt.millisecondsSinceEpoch;
    return LivenessEvidence(
      providerId: 'aws_rekognition',
      providerTransactionId: 'demo-aws-$compactTs',
      livenessScore: _defaultScore,
      livenessThreshold: _defaultThreshold,
      checkedAt: checkedAt,
    );
  }
}
