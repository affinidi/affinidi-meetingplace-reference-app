import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/credential_service.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/liveness_issuer_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/liveness_credentials_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/liveness_credentials_repository/liveness_credentials_repository_secure_storage.dart';
import 'package:mpx_flutter_reference_app/infrastructure/secure_storage/secure_storage.dart';
import 'package:ssi/ssi.dart';

import '../../../fakes/fake_secure_storage.dart';

LivenessEvidence passingLivenessEvidence({
  String holderSessionId = 'session-abc',
}) {
  return LivenessEvidence(
    providerId: 'demo_liveness',
    providerTransactionId: holderSessionId,
    livenessScore: 99,
    livenessThreshold: 80,
    checkedAt: DateTime.utc(2026, 5, 29, 12),
  );
}

LivenessEvidence failingLivenessEvidence() {
  return LivenessEvidence(
    providerId: 'demo_liveness',
    providerTransactionId: 'session-fail',
    livenessScore: 40,
    livenessThreshold: 80,
    checkedAt: DateTime.utc(2026, 5, 29, 12),
  );
}

Future<DidManager> createTestIssuerDidManager() async {
  final wallet = PersistentWallet(InMemoryKeyStore());
  final manager = await DidManager.create(
    () => DidPeerManager(store: InMemoryDidStore(), wallet: wallet),
  );
  final key = await wallet.generateKey(keyId: 'issuer-assertion-key');
  final verificationMethod = await manager.addVerificationMethod(key.id);
  await manager.addAssertionMethod(verificationMethod.verificationMethodId);
  return manager;
}

final class TestLivenessIssuerService extends LivenessIssuerService {
  TestLivenessIssuerService(super.ref, this._issuerManager);

  final DidManager _issuerManager;

  @override
  Future<DidManager> getIssuerDidManager() async => _issuerManager;
}

void initializeCredentialServiceTests() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(
    File('${Directory.systemTemp.path}/credential_service_test.log'),
  );
}

credentialServiceTestOverrides({
  required DidManager issuerManager,
  FakeSecureStorage? secureStorage,
}) {
  final storage = secureStorage ?? FakeSecureStorage();
  return [
    secureStorageProvider.overrideWith((ref) async => storage),
    livenessCredentialsRepositoryProvider.overrideWith(
      livenessCredentialsRepositorySecureStorage,
    ),
    livenessIssuerServiceProvider.overrideWith(
      (ref) => TestLivenessIssuerService(ref, issuerManager),
    ),
    credentialServiceProvider.overrideWith((ref) => CredentialService(ref: ref)),
  ];
}
