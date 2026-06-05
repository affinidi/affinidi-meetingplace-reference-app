class InvalidLivenessW3cCredentialException implements Exception {
  const InvalidLivenessW3cCredentialException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LivenessCredentialSessionMissingException implements Exception {
  const LivenessCredentialSessionMissingException();

  static const message =
      'Your liveness credential is not available in this app session. '
      'Generate a new credential and try again.';

  @override
  String toString() => message;
}

class LivenessEvidenceThresholdNotMetException implements Exception {
  const LivenessEvidenceThresholdNotMetException({
    required this.providerId,
    required this.score,
    required this.threshold,
  });

  final String providerId;
  final double score;
  final double threshold;

  @override
  String toString() =>
      'Liveness evidence did not meet threshold: '
      '$providerId score=$score threshold=$threshold';
}
