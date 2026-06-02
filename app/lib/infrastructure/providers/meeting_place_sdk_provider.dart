import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as fvod;
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:ssi/ssi.dart';

import '../../application/services/identities_service/identities_service.dart';
import '../../application/services/settings_service/settings_service.dart';
import '../configuration/environment.dart';
import '../extensions/contact_card_extensions.dart';
import '../secure_storage/secure_storage.dart';
import 'app_logger_provider.dart';
import 'channel_repository_provider.dart';
import 'connection_offer_repository_provider.dart';
import 'group_repository_provider.dart';
import 'matrix_config_provider.dart';

/// Initializes the vodozemac cryptographic library.
///
/// Cached at module scope so the native init runs at most once per
/// process even if the [ProviderContainer] is recreated (hot restart,
/// tests). Exposed as a provider so it can be overridden in tests to
/// verify that encryption bootstrap always completes before SDK creation.
final Future<void> _vodozemacInit = fvod.init();

@visibleForTesting
final vodozemacInitProvider = FutureProvider<void>(
  (ref) => _vodozemacInit,
  name: 'vodozemacInitProvider',
);

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
final FutureProvider<MeetingPlaceCoreSDK> meetingPlaceSdkProvider =
    FutureProvider<MeetingPlaceCoreSDK>((ref) async {
      const logKey = 'meetingPlaceSdkProvider';
      final logger = ref.read(appLoggerProvider);
      final secureStorage = await ref.read(secureStorageProvider.future);

      try {
        await ref.read(vodozemacInitProvider.future);
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
          config: await ref.read(matrixConfigProvider.future),
          logger: logger,
          options: MeetingPlaceCoreSDKOptions(
            expectedMessageWrappingTypes: const [
              MessageWrappingType.authcryptPlaintext,
              MessageWrappingType.authcryptSignPlaintext,
            ],
            messageTypesForSequenceTracking: [
              ChatProtocol.chatMessage.value,
              VdipClient.requestIssuanceMessageType,
              VdipClient.issuedCredentialMessageType,
            ],
            onBuildAttachments:
                (
                  Channel channel,
                  Future<DidManager> Function(String did) getDidManager,
                ) async {
                  try {
                    await ref
                        .read(identitiesServiceProvider.notifier)
                        .ensureInitialized();

                    final externalRef = channel.externalRef;
                    if (externalRef == null || externalRef.isEmpty) return null;

                    final identity = ref
                        .read(identitiesServiceProvider)
                        .getIdentityById(externalRef);
                    if (identity == null || identity.did.isEmpty) return null;

                    final didManager = await getDidManager(identity.did);

                    return RCardDIDCommAttachmentBuilder.build(
                      issuerDid: identity.did,
                      card: identity.card.toRCardSubject(),
                      issuerDidManager: didManager,
                    );
                  } catch (_) {
                    return null;
                  }
                },
          ),
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
