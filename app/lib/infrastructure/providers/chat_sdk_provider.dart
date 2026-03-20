import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../application/services/identities_service/identities_service.dart';
import '../configuration/environment.dart';
import '../extensions/contact_card_extensions.dart';
import 'app_logger_provider.dart';
import 'chat_matrix_content_repository_provider.dart';
import 'chat_repository_provider.dart';
import 'meeting_place_sdk_provider.dart';

/// A provider that initializes and supplies a [MeetingPlaceChatSDK] instance
/// for a given [Channel].
///
/// This provider:
/// - Sets up the [MeetingPlaceChatSDK] with the correct channel, repository,
///   and identity ContactCard
/// - Configures chat activity expiration and presence send intervals from
///   environment settings
/// - Logs both successful and failed initialization attempts
/// - Automatically disposes when no longer needed
/// - Throws and logs errors if initialization fails
final chatSdkProvider =
    AutoDisposeFutureProvider.family<MeetingPlaceChatSDK, Channel>((
      ref,
      channel,
    ) async {
      const logKey = 'chatSdkProvider';
      final logger = ref.read(appLoggerProvider);
      final environment = ref.read(environmentProvider);

      logger.info(
        '''From: ${channel.permanentChannelDid} - To: ${channel.otherPartyPermanentChannelDid}''',
        name: logKey,
      );

      final identity = ref
          .read(identitiesServiceProvider)
          .getIdentityById(channel.externalRef);
      final sdkContactCard = identity?.card.toSdkContactCard();

      try {
        final coreSDK = await ref.read(meetingPlaceSdkProvider.future);
        final sdk = await MeetingPlaceChatSDK.initialiseFromChannel(
          channel,
          coreSDK: coreSDK,
          chatRepository: await ref.read(chatRepositoryProvider.future),
          options: ChatSDKOptions(
            chatActivityExpiry: Duration(
              seconds: environment.chatActivityExpiresInSeconds,
            ),
            chatPresenceSendInterval: Duration(
              seconds: environment.chatPresenceIntervalInSeconds,
            ),
            chatPresenceExpiry: Duration(
              seconds: environment.chatPresenceIntervalInSeconds,
            ),
          ),
          card: sdkContactCard,
          logger: logger,
          matrixContentRepository: await ref.read(
            chatMatrixContentRepositoryProvider.future,
          ),
        );

        logger.info('Completed initializing Chat SDK', name: logKey);

        return sdk;
      } catch (e, st) {
        logger.error(
          'Error initializing Chat SDK',
          error: e,
          stackTrace: st,
          name: logKey,
        );
        rethrow;
      }
    }, name: 'chatSdkProvider');
