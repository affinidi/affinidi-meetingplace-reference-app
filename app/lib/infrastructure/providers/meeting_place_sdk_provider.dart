import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ssi/ssi.dart';

import '../../application/services/settings_service/settings_service.dart';
import '../configuration/environment.dart';
import '../secure_storage/secure_storage.dart';
import 'app_logger_provider.dart';
import 'channel_repository_provider.dart';
import 'connection_offer_repository_provider.dart';
import 'group_repository_provider.dart';
import 'identity_repository_provider.dart';

final meetingPlaceSdkProvider = FutureProvider<MeetingPlaceCoreSDK>(
  (ref) async {
    const logKey = 'meetingPlaceSdkProvider';
    final logger = ref.read(appLoggerProvider);
    final secureStorage = await ref.read(secureStorageProvider.future);

    try {
      final wallet = PersistentWallet(secureStorage);
      final settingsState = ref.read(settingsServiceProvider);
      final initialMediatorDid = settingsState.selectedMediatorDid;
      logger.info(
        'Starting MeetingPlace SDK initialization',
        name: logKey,
      );
      logger.info(
        'Selected mediator: $initialMediatorDid',
        name: logKey,
      );
      logger.info(
        'Service DID: ${ref.read(environmentProvider).controlPlaneDid}',
        name: logKey,
      );
      logger.info(
        'Debug mode: ${settingsState.isDebugMode}',
        name: logKey,
      );

      final sdk = await MeetingPlaceCoreSDK.create(
        wallet: wallet,
        repositoryConfig: RepositoryConfig(
          connectionOfferRepository:
              await ref.read(connectionOfferRepositoryProvider.future),
          channelRepository: await ref.read(channelRepositoryProvider.future),
          groupRepository: await ref.read(groupsRepositoryProvider.future),
          keyRepository: secureStorage,
          identityRepository: await ref.read(identityRepositoryProvider.future),
        ),
        mediatorDid: initialMediatorDid,
        controlPlaneDid: ref.read(environmentProvider).controlPlaneDid,
        logger: logger,
      );

      logger.info(
        'Completed initializing MeetingPlace SDK',
        name: logKey,
      );

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
  },
  name: 'meetingPlaceSdkProvider',
);
