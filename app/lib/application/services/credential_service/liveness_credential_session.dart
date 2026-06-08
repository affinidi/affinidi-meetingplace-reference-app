import 'dart:convert';

import 'package:vc_zkp/vc_zkp.dart';

import '../../../domain/models/credentials/liveness_credential_record.dart';
import '../../../domain/models/credentials/session_credential_material.dart';

SessionCredentialMaterial? sessionMaterialFromRecord(
  LivenessCredentialRecord? record, {
  void Function(Object error, StackTrace stackTrace)? onParseError,
}) {
  if (record == null || !record.hasPersistedZkpMaterial) return null;
  if (!record.hasW3cCredential) return null;
  try {
    final document = SignedVcDocument.fromJson(
      jsonDecode(record.zkpSignedDocumentJson) as Map<String, dynamic>,
    );
    return SessionCredentialMaterial(
      document: document,
      holderPrivateKeyHex: record.zkpHolderPrivateKeyHex,
      issuerAx: record.zkpIssuerAx,
      issuerAy: record.zkpIssuerAy,
    );
  } catch (error, stackTrace) {
    onParseError?.call(error, stackTrace);
    return null;
  }
}
