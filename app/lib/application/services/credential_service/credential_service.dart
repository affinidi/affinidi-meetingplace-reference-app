import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_zkp/vc_zkp.dart';

import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../zkp_service/zkp_constants.dart';
import 'credential_service_state.dart';

final credentialServiceProvider =
    StateNotifierProvider<CredentialService, CredentialServiceState>((ref) {
      return CredentialService(ref: ref);
    });

/// Service responsible for managing Verifiable Credentials (VCs)
///
/// Handles creation, storage, and retrieval of credentials.
/// Separates credential lifecycle management from ZKP operations.
class CredentialService extends StateNotifier<CredentialServiceState> {
  CredentialService({required this.ref})
    : super(const CredentialServiceState()) {
    _logger = ref.read(appLoggerProvider);
  }

  final Ref ref;
  late final AppLogger _logger;
  static const _logKey = 'CredentialService';

  /// Creates a signed liveness credential
  ///
  /// Returns a tuple of (document, issuerPub, holderPub)
  /// for use in ZKP generation
  Future<CredentialCreationResult> createLivenessCredential({
    String? holderDid,
  }) async {
    try {
      _logger.info('Creating liveness credential', name: _logKey);

      final crypto = RustEddsaHelperFfi();

      // Generate random keys for issuer and holder
      final issuerPrivateKeyHex = _randomPrivateKeyHex();
      final holderPrivateKeyHex = _randomPrivateKeyHex();

      // Derive public keys
      final issuerPub = await crypto.signDigest(
        msgHash: '1',
        privateKeyHex: issuerPrivateKeyHex,
      );

      final holderPub = await crypto.signDigest(
        msgHash: '1',
        privateKeyHex: holderPrivateKeyHex,
      );

      // Build credential header
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
        Disclosure(field: 'did', value: holderDid ?? 'did:example:user123'),
      ];

      // Create signed document
      final issuer = VcIssuer(crypto: crypto);
      final document = await issuer.createSignedDocument(
        header: header,
        disclosures: disclosures,
        issuerPrivateKeyHex: issuerPrivateKeyHex,
      );

      _logger.info('Liveness credential created successfully', name: _logKey);

      // Store the latest credential in state
      state = state.copyWith(
        latestCredential: CredentialData(
          document: document,
          issuerName: ZkpConstants.vcIssuerName,
          issuedAt: now,
          expiresAt: now.add(ZkpConstants.vcExpiryDuration),
          holderDid: holderDid ?? 'did:example:user123',
        ),
      );

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

  /// Generates a random 32-byte private key as hex string
  String _randomPrivateKeyHex() {
    final random = Random.secure();
    final bytes = List.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

/// Result of credential creation containing all necessary components
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
