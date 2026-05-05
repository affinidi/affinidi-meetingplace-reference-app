import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ssi/ssi.dart';

import '../../application/services/identities_service/identities_service.dart';
import '../../application/services/settings_service/settings_service.dart';
import '../configuration/environment.dart';
import '../secure_storage/secure_storage.dart';
import 'app_logger_provider.dart';
import 'channel_repository_provider.dart';
import 'connection_offer_repository_provider.dart';
import 'group_repository_provider.dart';

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
          mediatorDid: initialMediatorDid,
          controlPlaneDid: ref.read(environmentProvider).controlPlaneDid,
          logger: logger,
          options: MeetingPlaceCoreSDKOptions(
            onBuildAttachments: (channel) async {
              try {
                final identities = ref
                    .read(identitiesServiceProvider)
                    .identities;
                final primary =
                    identities.where((id) => id.isPrimary).firstOrNull ??
                    identities.firstOrNull;
                if (primary == null || primary.did.isEmpty) return null;

                final sdk = await ref.read(meetingPlaceSdkProvider.future);
                final didManager = await sdk.getDidManager(primary.did);

                return RCardAttachmentBuilder.buildForPersona(
                  persona: PersonaDid(
                    did: primary.did,
                    name: primary.card.displayName,
                  ),
                  card: RCardSubject(
                    firstName: primary.card.firstName,
                    lastName: primary.card.lastName,
                    email: primary.card.email,
                    phone: primary.card.mobile,
                  ),
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
