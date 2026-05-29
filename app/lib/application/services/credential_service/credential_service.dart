import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ssi/ssi.dart';
import 'package:vc_zkp/vc_zkp.dart';

import '../../../domain/models/credentials/liveness_credential_record.dart';
import '../../../domain/repositories/liveness_credentials_repository.dart';
import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/liveness_credentials_repository_provider.dart';
import 'aws_amplify_bootstrap.dart';
import '../zkp_service/zkp_constants.dart';
import 'credential_service_state.dart';
import 'liveness_credential_builder.dart';
import 'liveness_credential_session.dart';
import 'liveness_credential_subject.dart';
import 'liveness_evidence_source.dart';
import 'liveness_issuer_service.dart';
import 'liveness_vc_zkp_adapter.dart';

final credentialServiceProvider =
    StateNotifierProvider<CredentialService, CredentialServiceState>((ref) {
      final service = CredentialService(ref: ref);
      service.ensureInitialized();
      return service;
    });

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

class InvalidLivenessW3cCredentialException implements Exception {
  const InvalidLivenessW3cCredentialException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CredentialService extends StateNotifier<CredentialServiceState> {
  CredentialService({required this.ref})
    : super(const CredentialServiceState()) {
    _logger = ref.read(appLoggerProvider);
  }

  final Ref ref;
  late final AppLogger _logger;
  static const _logKey = 'CredentialService';

  bool _initialized = false;
  LivenessCredentialsRepository? _repository;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    await _reloadFromStorage();
  }

  Future<void> issueLivenessCredential({
    required String identityId,
    required String holderDid,
    LivenessEvidence? evidence,
  }) async {
    await createLivenessCredential(
      identityId: identityId,
      holderDid: holderDid,
      evidence: evidence,
    );
  }

  Future<CredentialCreationResult> prepareCredentialForProof({
    required String identityId,
    required String holderDid,
  }) async {
    await ensureInitialized();
    final session = _sessionForIdentity(identityId);
    if (session != null) {
      _logger.info(
        'Using liveness credential session material for $identityId',
        name: _logKey,
      );
      return _resultFromSession(session);
    }

    _logger.info(
      'No ZKP session material for $identityId; re-issue liveness credential',
      name: _logKey,
    );
    throw const LivenessCredentialSessionMissingException();
  }

  Future<CredentialCreationResult> createLivenessCredential({
    required String identityId,
    required String holderDid,
    LivenessEvidence? evidence,
  }) async {
    await ensureInitialized();
    try {
      _logger.info(
        'Creating liveness credential for identity $identityId',
        name: _logKey,
      );

      final environment = ref.read(environmentProvider);
      if (environment.awsLivenessDirectEnabled && evidence == null) {
        throw const AwsLivenessConfigurationException(
          'Complete AWS Face Liveness before issuing credential.',
        );
      }

      final resolvedEvidence =
          evidence ??
          await ref
              .read(livenessEvidenceSourceProvider)
              .getEvidence(holderDid: holderDid);
      if (!resolvedEvidence.isLive) {
        throw LivenessEvidenceThresholdNotMetException(
          providerId: resolvedEvidence.providerId,
          score: resolvedEvidence.livenessScore,
          threshold: resolvedEvidence.livenessThreshold,
        );
      }

      final issuerManager = await ref
          .read(livenessIssuerServiceProvider)
          .getIssuerDidManager();
      final issuerDocument = await issuerManager.getDidDocument();
      final issuerDid = issuerDocument.id;

      final w3cCredential = await LivenessCredentialBuilder.build(
        issuerDid: issuerDid,
        subject: LivenessCredentialSubject(
          holderDid: holderDid,
          evidence: resolvedEvidence,
        ),
        issuerDidManager: issuerManager,
        evidence: resolvedEvidence,
      );

      _validateIssuedW3cLivenessCredential(
        credential: w3cCredential,
        holderDid: holderDid,
        evidence: resolvedEvidence,
      );

      final w3cCredentialJson = jsonEncode(w3cCredential.toJson());

      final issuerPrivateKeyHex = _randomPrivateKeyHex();
      final holderPrivateKeyHex = _randomPrivateKeyHex();

      final zkpMaterial = await LivenessVcZkpAdapter.buildFromW3cCredential(
        w3cCredential: w3cCredential,
        issuerDid: issuerDid,
        holderPrivateKeyHex: holderPrivateKeyHex,
        issuerPrivateKeyHex: issuerPrivateKeyHex,
      );

      final now = resolvedEvidence.checkedAt.toUtc();
      final expiresAt = now.add(ZkpConstants.vcExpiryDuration);
      final zkpDocumentJson = jsonEncode(zkpMaterial.document.toJson());

      final metadata = LivenessCredentialRecord(
        identityId: identityId,
        issuedToDid: holderDid,
        issuerName: ZkpConstants.vcIssuerName,
        issuerDid: issuerDid,
        issuedAt: now,
        expiresAt: expiresAt,
        w3cCredentialJson: w3cCredentialJson,
        zkpSignedDocumentJson: zkpDocumentJson,
        zkpHolderPrivateKeyHex: zkpMaterial.holderPrivateKeyHex,
        zkpIssuerAx: zkpMaterial.issuerPub.ax,
        zkpIssuerAy: zkpMaterial.issuerPub.ay,
      );

      await _upsertRecord(metadata);

      final session = SessionCredentialMaterial(
        document: zkpMaterial.document,
        holderPrivateKeyHex: zkpMaterial.holderPrivateKeyHex,
        issuerAx: zkpMaterial.issuerPub.ax,
        issuerAy: zkpMaterial.issuerPub.ay,
      );

      state = state.copyWith(
        sessionMaterialByIdentityId: {
          ...state.sessionMaterialByIdentityId,
          identityId: session,
        },
        latestCredential: CredentialData(
          identityId: identityId,
          w3cCredentialJson: w3cCredentialJson,
          issuerName: ZkpConstants.vcIssuerName,
          issuedAt: now,
          expiresAt: expiresAt,
          holderDid: holderDid,
        ),
      );

      _logger.info(
        'Liveness W3C credential validated, converted to vc_zkp signed document, and stored successfully',
        name: _logKey,
      );

      return CredentialCreationResult(
        document: zkpMaterial.document,
        issuerPub: zkpMaterial.issuerPub,
        holderPub: zkpMaterial.holderPub,
        holderPrivateKeyHex: zkpMaterial.holderPrivateKeyHex,
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to create liveness credential: $e',
        name: _logKey,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> deleteCredentialForIdentity(String identityId) async {
    await ensureInitialized();
    final repository = await _ensureRepository();
    await repository.delete(identityId);
    final clearLatest = state.latestCredential?.identityId == identityId;
    final sessionMaterial = Map<String, SessionCredentialMaterial>.from(
      state.sessionMaterialByIdentityId,
    )..remove(identityId);
    await _reloadFromStorage();
    state = state.copyWith(
      sessionMaterialByIdentityId: sessionMaterial,
      latestCredential: clearLatest ? null : state.latestCredential,
    );
  }

  SessionCredentialMaterial? _sessionForIdentity(String identityId) {
    final inMemory = state.sessionMaterialByIdentityId[identityId];
    if (inMemory != null) return inMemory;
    return sessionMaterialFromRecord(state.credentialsByIdentityId[identityId]);
  }

  CredentialCreationResult _resultFromSession(
    SessionCredentialMaterial session,
  ) {
    final document = session.document;
    final holderAx = document.header['holderAx']?.toString() ?? '';
    final holderAy = document.header['holderAy']?.toString() ?? '';

    return CredentialCreationResult(
      document: document,
      issuerPub: EddsaSignatureResult(
        ax: session.issuerAx,
        ay: session.issuerAy,
        r8x: '0',
        r8y: '0',
        s: '0',
      ),
      holderPub: EddsaSignatureResult(
        ax: holderAx,
        ay: holderAy,
        r8x: '0',
        r8y: '0',
        s: '0',
      ),
      holderPrivateKeyHex: session.holderPrivateKeyHex,
    );
  }

  Future<LivenessCredentialsRepository> _ensureRepository() async {
    _repository ??= await ref.read(
      livenessCredentialsRepositoryProvider.future,
    );
    return _repository!;
  }

  Future<void> _upsertRecord(LivenessCredentialRecord record) async {
    final repository = await _ensureRepository();
    await repository.upsert(record);
    await _reloadFromStorage();
  }

  Future<void> _reloadFromStorage() async {
    final repository = await _ensureRepository();
    final records = await repository.list();
    final credentialsByIdentityId = {
      for (final record in records) record.identityId: record,
    };
    final hydratedSessions = <String, SessionCredentialMaterial>{};
    for (final record in records) {
      final session = sessionMaterialFromRecord(record);
      if (session != null) {
        hydratedSessions[record.identityId] = session;
      }
    }

    state = state.copyWith(
      credentialsByIdentityId: credentialsByIdentityId,
      sessionMaterialByIdentityId: {
        ...hydratedSessions,
        ...state.sessionMaterialByIdentityId,
      },
    );
  }

  String _randomPrivateKeyHex() {
    final random = Random.secure();
    final bytes = List.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  void _validateIssuedW3cLivenessCredential({
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
        !types.contains('LivenessCredential')) {
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
        'Issued W3C credential subject mismatch: expected $holderDid, got $subjectDid.',
      );
    }

    final provider = subject['livenessProvider']?.toString() ?? '';
    final sessionId = subject['livenessSessionId']?.toString() ?? '';
    if (provider != evidence.providerId ||
        sessionId != evidence.providerTransactionId) {
      throw const InvalidLivenessW3cCredentialException(
        'Issued W3C credential does not match AWS liveness evidence.',
      );
    }
  }
}

class CredentialCreationResult {
  const CredentialCreationResult({
    required this.document,
    required this.issuerPub,
    required this.holderPub,
    required this.holderPrivateKeyHex,
  });

  final SignedVcDocument document;
  final EddsaSignatureResult issuerPub;
  final EddsaSignatureResult holderPub;
  final String holderPrivateKeyHex;
}
