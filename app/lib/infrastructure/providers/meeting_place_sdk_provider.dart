import 'package:dio/dio.dart';
import 'package:meeting_place_control_plane/meeting_place_control_plane.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ssi/ssi.dart';

import '../../application/services/settings_service/settings_service.dart';
import '../configuration/environment.dart';
import '../secure_storage/secure_storage.dart';
import '../trust/sdk_demo_trust_runtime_orchestrator.dart';
import 'app_logger_provider.dart';
import 'channel_repository_provider.dart';
import 'connection_offer_repository_provider.dart';
import 'group_repository_provider.dart';

/// A provider that resolves the [TrustPolicyEnforcer] to use for runtime
/// authorization checks against the local PDP.
///
/// Returns a [HttpTrustPolicyEnforcer] when trust enforcement is enabled and
/// a non-empty `TRUST_ENFORCER_URL` is configured. Falls back to a
/// [NoopTrustPolicyEnforcer] otherwise so the rest of the app can call into
/// the enforcer unconditionally.
final trustPolicyEnforcerProvider = Provider<TrustPolicyEnforcer>((ref) {
  const logKey = 'trustPolicyEnforcerProvider';
  final logger = ref.read(appLoggerProvider);
  final environment = ref.read(environmentProvider);

  if (!environment.isTrustEnforcementEnabled) {
    return const NoopTrustPolicyEnforcer();
  }

  final trustEnforcerUrl = environment.trustEnforcerUrl.trim();
  if (trustEnforcerUrl.isEmpty) {
    logger.warning(
      'Trust enforcement enabled but TRUST_ENFORCER_URL is empty. '
      'Falling back to no-op trust enforcement.',
      name: logKey,
    );
    return const NoopTrustPolicyEnforcer();
  }

  logger.info(
    'Trust enforcement enabled with endpoint: '
    '$trustEnforcerUrl${environment.trustEnforcerEndpointPath}',
    name: logKey,
  );

  return HttpTrustPolicyEnforcer(
    dio: Dio(),
    baseUrl: trustEnforcerUrl,
    endpointPath: environment.trustEnforcerEndpointPath,
  );
}, name: 'trustPolicyEnforcerProvider');

/// A provider that initializes and supplies the [MeetingPlaceCoreSDK]
/// instance.
///
/// This provider:
/// - Creates a [PersistentWallet] using [SecureStorage]
/// - Configures repositories ([ConnectionOfferRepository],
///   [ChannelRepository], [GroupRepository]) and key repository
/// - Uses mediator DID from settings and control plane DID from environment
/// - Provides comprehensive logging throughout the initialization process
/// - Handles initialization errors gracefully with proper error logging
final meetingPlaceSdkProvider = FutureProvider<MeetingPlaceCoreSDK>((
  ref,
) async {
  const logKey = 'meetingPlaceSdkProvider';
  final logger = ref.read(appLoggerProvider);
  final secureStorage = await ref.read(secureStorageProvider.future);

  try {
    final wallet = PersistentWallet(secureStorage);
    final settingsState = ref.read(settingsServiceProvider);
    final initialMediatorDid = settingsState.selectedMediatorDid;
    logger.info('Starting MeetingPlace SDK initialization', name: logKey);
    logger.info('Selected mediator: $initialMediatorDid', name: logKey);
    logger.info(
      'Service DID: ${ref.read(environmentProvider).controlPlaneDid}',
      name: logKey,
    );
    logger.info('Debug mode: ${settingsState.isDebugMode}', name: logKey);
    final environment = ref.read(environmentProvider);
    final trustPolicyEnforcer = ref.read(trustPolicyEnforcerProvider);
    final trustRuntimeOrchestrator = SdkDemoTrustRuntimeOrchestrator(
      dio: Dio(),
      environment: environment,
    );

    final sdk = await MeetingPlaceCoreSDK.create(
      wallet: wallet,
      repositoryConfig: RepositoryConfig(
        connectionOfferRepository: await ref.read(
          connectionOfferRepositoryProvider.future,
        ),
        channelRepository: await ref.read(channelRepositoryProvider.future),
        groupRepository: await ref.read(groupsRepositoryProvider.future),
        keyRepository: secureStorage,
      ),
      mediatorDid: initialMediatorDid,
      controlPlaneDid: environment.controlPlaneDid,
      options: MeetingPlaceCoreSDKOptions(
        trustPolicyEnforcer: trustPolicyEnforcer is NoopTrustPolicyEnforcer
            ? null
            : trustPolicyEnforcer,
        trustRuntimeOrchestrator: trustRuntimeOrchestrator,
      ),
      logger: logger,
    );

    logger.info('Completed initializing MeetingPlace SDK', name: logKey);

    return sdk;
  } catch (error, stackTrace) {
    logger.error(
      'Error initializing MeetingPlace SDK',
      error: error,
      stackTrace: stackTrace,
      name: logKey,
    );
    rethrow;
  }
}, name: 'meetingPlaceSdkProvider');
