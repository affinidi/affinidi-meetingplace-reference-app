import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:ssi/ssi.dart';

import 'liveness_errors.dart';

void validateIssuedW3cLivenessCredential({
  required VcDataModelV2 credential,
  required String holderDid,
  required LivenessEvidence evidence,
}) {
  final json = credential.toJson();

  final typeJson = json['type'];
  final types = <String>{};
  if (typeJson is List) {
    types.addAll(typeJson.map((e) => e.toString()));
  } else if (typeJson is String) {
    types.add(typeJson);
  }

  if (!types.contains('VerifiableCredential') ||
      !types.contains(LivenessCredentialConstants.typeLivenessCredential)) {
    throw const InvalidLivenessW3cCredentialException(
      'Issued credential is missing required W3C VC types.',
    );
  }

  final proof = json['proof'];
  if (proof is! Map || proof.isEmpty) {
    throw const InvalidLivenessW3cCredentialException(
      'Issued W3C credential is missing a Data Integrity proof.',
    );
  }

  final subjectJson = json['credentialSubject'];
  Map<String, dynamic>? subject;
  if (subjectJson is List && subjectJson.isNotEmpty) {
    final first = subjectJson.first;
    if (first is Map) {
      subject = Map<String, dynamic>.from(first);
    }
  } else if (subjectJson is Map) {
    subject = Map<String, dynamic>.from(subjectJson);
  }

  if (subject == null) {
    throw const InvalidLivenessW3cCredentialException(
      'Issued W3C credential is missing credentialSubject.',
    );
  }

  final subjectDid = subject['id']?.toString() ?? '';
  if (subjectDid != holderDid) {
    throw InvalidLivenessW3cCredentialException(
      'Issued W3C credential subject mismatch: expected $holderDid, '
      'got $subjectDid.',
    );
  }

  final provider = subject['livenessProvider']?.toString() ?? '';
  final sessionId = subject['livenessSessionId']?.toString() ?? '';
  if (provider != evidence.providerId ||
      sessionId != evidence.providerTransactionId) {
    throw const InvalidLivenessW3cCredentialException(
      'Issued W3C credential does not match liveness evidence.',
    );
  }
}
