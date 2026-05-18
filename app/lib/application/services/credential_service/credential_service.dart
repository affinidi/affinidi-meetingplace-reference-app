import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_zkp/vc_zkp.dart';

import '../../../domain/models/credentials/liveness_credential_record.dart';
import '../../../domain/repositories/liveness_credentials_repository.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/liveness_credentials_repository_provider.dart';
import '../zkp_service/zkp_constants.dart';
import 'credential_service_state.dart';

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
  }) async {
    await createLivenessCredential(
      identityId: identityId,
      holderDid: holderDid,
    );
  }

  Future<CredentialCreationResult> prepareCredentialForProof({
    required String identityId,
    required String holderDid,
  }) async {
    await ensureInitialized();
    final session = state.sessionMaterialByIdentityId[identityId];
    if (session != null) {
      _logger.info(
        'Using in-session liveness credential for $identityId',
        name: _logKey,
      );
      return _resultFromSession(session);
    }

    _logger.info(
      'No in-session VC for $identityId; proof requires explicit re-issue',
      name: _logKey,
    );
    throw const LivenessCredentialSessionMissingException();
  }

  Future<CredentialCreationResult> createLivenessCredential({
    required String identityId,
    required String holderDid,
  }) async {
    await ensureInitialized();
    try {
      _logger.info(
        'Creating liveness credential for identity $identityId',
        name: _logKey,
      );

      final crypto = RustEddsaHelperFfi();

      final issuerPrivateKeyHex = _randomPrivateKeyHex();
      final holderPrivateKeyHex = _randomPrivateKeyHex();

      final issuerPub = await crypto.signDigest(
        msgHash: '1',
        privateKeyHex: issuerPrivateKeyHex,
      );

      final holderPub = await crypto.signDigest(
        msgHash: '1',
        privateKeyHex: holderPrivateKeyHex,
      );

      final now = clock.now();
      final header = <String, Object?>{
        'version': '1',
        'issued_at': now.millisecondsSinceEpoch ~/ 1000,
        'expires_at':
            now.add(ZkpConstants.vcExpiryDuration).millisecondsSinceEpoch ~/
            1000,
        'issuer': ZkpConstants.vcIssuerName,
        'holderAx': holderPub.ax,
        'holderAy': holderPub.ay,
        'schema': ZkpConstants.livenessSchemaVersion,
      };

      final disclosures = <Disclosure>[
        Disclosure(field: 'did', value: holderDid),
      ];

      final issuer = VcIssuer(crypto: crypto);
      final document = await issuer.createSignedDocument(
        header: header,
        disclosures: disclosures,
        issuerPrivateKeyHex: issuerPrivateKeyHex,
      );

      final metadata = LivenessCredentialRecord(
        identityId: identityId,
        issuedToDid: holderDid,
        issuerName: ZkpConstants.vcIssuerName,
        issuedAt: now,
        expiresAt: now.add(ZkpConstants.vcExpiryDuration),
      );

      await _upsertRecord(metadata);

      final session = SessionCredentialMaterial(
        document: document,
        holderPrivateKeyHex: holderPrivateKeyHex,
        issuerAx: issuerPub.ax,
        issuerAy: issuerPub.ay,
      );

      state = state.copyWith(
        sessionMaterialByIdentityId: {
          ...state.sessionMaterialByIdentityId,
          identityId: session,
        },
        latestCredential: CredentialData(
          identityId: identityId,
          document: document,
          issuerName: ZkpConstants.vcIssuerName,
          issuedAt: now,
          expiresAt: now.add(ZkpConstants.vcExpiryDuration),
          holderDid: holderDid,
        ),
      );

      _logger.info('Liveness credential created successfully', name: _logKey);

      return CredentialCreationResult(
        document: document,
        issuerPub: issuerPub,
        holderPub: holderPub,
        holderPrivateKeyHex: holderPrivateKeyHex,
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
    state = state.copyWith(
      credentialsByIdentityId: {
        for (final record in records) record.identityId: record,
      },
    );
  }

  String _randomPrivateKeyHex() {
    final random = Random.secure();
    final bytes = List.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

/// Cryptographic material for one liveness VC, used when generating ZKPs.
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
