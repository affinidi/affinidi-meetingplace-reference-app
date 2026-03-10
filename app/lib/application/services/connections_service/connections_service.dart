import 'dart:async';

import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/identity/identity.dart';
import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../presentation/screens/offer/publish_offer_screen/publish_offer_form_data.dart';
import '../control_plane_service/control_plane_service.dart';
import 'connections_service_state.dart';

part 'connections_service.g.dart';

/// Service responsible for managing connection offers and channels.
///
/// This service provides functionality to:
/// - Fetch current connection offers and channels
/// - Delete connection offers
/// - Approve and accept connection offers
/// - Publish new offers (including group offers)
/// - Validate and find offers by mnemonic/phrase
///
/// It interacts with the MeetingPlaceCoreSDK and exposes a stream for group
/// channel inauguration events.
@Riverpod(keepAlive: true)
class ConnectionsService extends _$ConnectionsService {
  ConnectionsService() : super();
  static const _logKey = 'CONXSVC';

  late final AppLogger _logger = ref.read(appLoggerProvider);
  final StreamController<Channel> _groupOfferChannelInauguratedController =
      StreamController<Channel>.broadcast();
  Stream<Channel> get onGroupOfferChannelInaugurated =>
      _groupOfferChannelInauguratedController.stream;

  @override
  ConnectionsServiceState build() {
    final controlPlaneNotifier = ref.read(controlPlaneServiceProvider.notifier);

    controlPlaneNotifier.onInvitationAccepted.listen((connectionOffer) {
      Future(fetchConnections);
    });

    controlPlaneNotifier.onConnectionOfferApproved.listen((connectionOffer) {
      Future(fetchConnections);
    });

    controlPlaneNotifier.onChannelActivity.listen((connectionOffer) {
      Future(fetchConnections);
    });

    return ConnectionsServiceState();
  }

  Future<void>? initializing;
  Future<void> ensureInitialized() async {
    initializing ??= fetchConnections();
    await initializing;
  }

  /// Fetch the list of connection offers from the MeetingPlaceCoreSDK and
  /// update state.
  ///
  /// This operation queries the SDK for current connection offers and updates
  /// the provider state with the retrieved list.
  ///
  /// Returns:
  /// - `Future<void>` completes when the connections have been fetched and
  ///   state has been updated.
  Future<void> fetchConnections() async {
    _logger.info('Calling SDK listConnectionOffers', name: _logKey);

    try {
      final sdk = await ref.read(meetingPlaceSdkProvider.future);
      final connectionOffers = await sdk.listConnectionOffers();

      _logger.info(
        'Connection fetch done. Got ${connectionOffers.length} items',
        name: _logKey,
      );

      state = state.copyWith(connections: connectionOffers);
    } catch (error, stackTrace) {
      _logger.error(
        'Error calling fetchConnections',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    }
  }

  /// Delete a connection offer.
  ///
  /// Attempts to remove the given [connectionOffer] via the SDK. Any errors
  /// encountered are logged. After deletion (or failure) the connections list
  /// is refreshed.
  ///
  /// [connectionOffer] - The connection offer to delete.
  ///
  /// Returns:
  /// - `Future<void>` completes when the delete operation and subsequent
  ///   refresh finish.
  Future<void> markConnectionOfferAsDeleted(
    ConnectionOffer connectionOffer,
  ) async {
    _logger.info(
      'Starting deletion of connection offer: ${connectionOffer.mnemonic}',
      name: _logKey,
    );

    try {
      final sdk = await ref.read(meetingPlaceSdkProvider.future);
      _logger.info(
        'SDK ready, deleting connection offer: ${connectionOffer.mnemonic}',
        name: _logKey,
      );

      await sdk.markConnectionOfferAsDeleted(connectionOffer);
      _logger.info(
        'Connection offer deleted successfully: ${connectionOffer.mnemonic}',
        name: _logKey,
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to delete connection offer: ${connectionOffer.mnemonic}',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }

    _logger.info('Refreshing connections after deletion', name: _logKey);
    await fetchConnections();
  }

  /// Approve a connection offer identified by an offer link and the other
  /// party's DID.
  ///
  /// Locates the connection offer using [offerLink] and the associated channel
  /// using [otherPartyPermanentChannelDid], then approves the connection
  /// request via the SDK. Throws an [AppException] when the offer or channel
  /// cannot be found.
  ///
  /// [otherPartyPermanentChannelDid] - The DID of the other party's channel.
  /// [offerLink] - The offer link used to retrieve the connection offer.
  ///
  /// Throws [AppException] if:
  /// - The connection offer could not be retrieved.
  /// - The channel associated with the other party could not be found.
  ///
  /// Returns:
  /// - `Future<void>` completes when the approval and refresh finish.
  Future<void> approveConnectionOffer({
    required String otherPartyPermanentChannelDid,
    required String offerLink,
  }) async {
    _logger.info(
      'Starting connection offer approval - '
      'ChannelId: $otherPartyPermanentChannelDid, '
      'OfferLink: $offerLink',
      name: _logKey,
    );

    try {
      final sdk = await ref.read(meetingPlaceSdkProvider.future);
      _logger.info('SDK ready, fetching connection offer', name: _logKey);

      final connectionOffer = await sdk.getConnectionOffer(offerLink);
      if (connectionOffer == null) {
        _logger.error(
          'Connection offer not found for link: $offerLink',
          name: _logKey,
        );
        throw AppException(
          'Unable to find connection offer via offer link',
          code: AppExceptionType.missingConnectionOffer.name,
        );
      }

      _logger.info(
        'Connection offer found: ${connectionOffer.mnemonic}, fetching channel',
        name: _logKey,
      );

      final channel = await sdk.getChannelByDid(otherPartyPermanentChannelDid);
      if (channel == null) {
        _logger.error(
          'Channel not found for DID: $otherPartyPermanentChannelDid',
          name: _logKey,
        );
        throw AppException(
          'Unable to find channel offer via other party permanent channel did',
          code: AppExceptionType.missingChannel.name,
        );
      }

      _logger.info(
        'Channel found: ${channel.permanentChannelDid}, approving request',
        name: _logKey,
      );

      await sdk.approveConnectionRequest(channel: channel);

      _logger.info('Connection request approved successfully', name: _logKey);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to approve connection offer',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    }

    _logger.info('Refreshing connections after approval', name: _logKey);
    await fetchConnections();
  }

  /// Accept a connection offer and notify acceptance.
  ///
  /// This method will accept the provided [connectionOffer], using the current
  /// contact card (from IdentitiesService) as the ContactCard
  /// and [identity] as an external reference.
  /// It notifies the issuer of acceptance and refreshes
  /// connections. Specific SDK errors are mapped to domain [AppException]s.
  ///
  /// [connectionOffer] - The offer to accept.
  /// [identity] - External identity reference used when accepting the offer.
  ///
  /// Throws [AppException] if:
  /// - The offer has already been claimed.
  /// - The offer is owned by the claiming party.
  /// - The offer cannot be found.
  /// - Other SDK errors are mapped to AppExceptionType.other.
  ///
  /// Returns:
  /// - `Future<void>` completes when acceptance, notification, and refresh
  ///  are done.
  Future<void> acceptOffer(
    ConnectionOffer connectionOffer, {
    required Identity identity,
  }) async {
    final sdk = await ref.read(meetingPlaceSdkProvider.future);
    await sdk.acceptOffer(
      connectionOffer: connectionOffer,
      contactCard: identity.card.toSdkContactCard(),
      externalRef: identity.id,
      senderInfo: identity.card.firstName,
    );
    await fetchConnections();
  }

  /// Validate whether an offer phrase/mnemonic is available.
  ///
  /// Trims and validates [phrase] using the SDK and updates state with the
  /// availability result. Logs outcomes and rethrows unexpected errors.
  ///
  /// [phrase] - The offer phrase to validate.
  ///
  /// Throws:
  /// - Rethrows any non-expected errors after logging.
  ///
  /// Returns:
  /// - `Future<void>` completes when validation finishes and state is updated.
  Future<void> validateOfferPhrase(String phrase) async {
    _logger.info('Validating offer phrase: $phrase', name: _logKey);

    try {
      final sdk = await ref.read(meetingPlaceSdkProvider.future);
      final result = await sdk.validateOfferPhrase(phrase.trim());
      _logger.info(
        'Phrase validation result: ${result.isAvailable}',
        name: _logKey,
      );
      state = state.copyWith(isCustomPhraseAvailable: result.isAvailable);
    } catch (error, stackTrace) {
      _logger.error(
        'Error validating offer phrase',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    }
  }

  /// Publish a new connection offer.
  ///
  /// Publishes an offer with data from [data], using the current identity's
  /// contact card as ContactCard and [identity] as an external reference. On
  /// success the published offer is stored in state and connections are
  /// refreshed. For group offers the group channel inauguration stream is
  /// announced.
  ///
  /// [data] - The form data describing the offer to publish.
  /// [identity] - External identity reference used when publishing the offer.
  ///
  /// Throws:
  /// - Rethrows SDK errors after logging.
  ///
  /// Returns:
  /// - `Future<void>` completes when publishing, refresh, and any group
  ///   announcement finish.
  Future<void> publishOffer(
    PublishOfferFormData data, {
    required Identity identity,
  }) async {
    _logger.info('Submitting offer: ${data.headline}', name: _logKey);

    try {
      final isGroupOffer = data.isGroupOffer;
      final sdk = await ref.read(meetingPlaceSdkProvider.future);
      final result = await sdk.publishOffer(
        offerName: data.headline,
        contactCard: identity.card.toSdkContactCard(),
        type: isGroupOffer
            ? SDKConnectionOfferType.groupInvitation
            : SDKConnectionOfferType.invitation,
        offerDescription: data.description,
        customPhrase: data.customPhrase,
        validUntil: data.expiryDate,
        maximumUsage: data.maxUsages,
        mediatorDid: data.selectedMediatorDid,
        externalRef: identity.id,
      );

      _logger.info('Offer registered successfully', name: _logKey);
      await fetchConnections();
      state = state.copyWith(publishedOffer: result.connectionOffer);

      if (isGroupOffer) {
        await _announceGroupChannelIsReady(result);
      }
    } catch (error, stackTrace) {
      _logger.error(
        'Error submitting offer',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    }
  }

  /// Announce that a published group offer has an associated channel ready.
  ///
  /// Validates that [result] contains a group connection offer and resolves
  /// the group's channel. On success the channel is emitted to the
  /// `onGroupOfferChannelInaugurated` stream.
  ///
  /// [result] - The publish result containing the published connection offer.
  ///
  /// Throws [AppException] if:
  /// - The published offer is not of type group.
  /// - The group offer has no owner.
  /// - The channel for the owner cannot be retrieved.
  Future<void> _announceGroupChannelIsReady(
    PublishOfferResult<ConnectionOffer> result,
  ) async {
    final groupConnectionOffer =
        result.connectionOffer as GroupConnectionOffer?;

    if (groupConnectionOffer == null) {
      throw AppException(
        '''Pubslished a group connection offer but the offer returned is not of type group''',
        code: AppExceptionType.missingConnectionOffer.name,
      );
    }
    final groupOwnerDid = groupConnectionOffer.groupOwnerDid;
    if (groupOwnerDid == null) {
      throw AppException(
        '''Group connection offer does not have an owner''',
        code: AppExceptionType.missingGroupConnectionOfferOwner.name,
      );
    }
    final sdk = await ref.read(meetingPlaceSdkProvider.future);
    final channel = await sdk.getChannelByDid(groupOwnerDid);
    if (channel == null) {
      throw AppException(
        '''Could not retrieve the channel associated to the group published offer''',
        code: AppExceptionType.missingChannelForPublishedGroupOffer.name,
      );
    }

    if (channel.type != ChannelType.group) {
      throw AppException(
        '''Found a channel but it does not claim to be for a group''',
        code: AppExceptionType.wrongChannelTypeForConnectionOffer.name,
      );
    }
    _groupOfferChannelInauguratedController.add(channel);
  }

  /// Clear the last published offer stored in state.
  ///
  /// This operation simply sets the `publishedOffer` field in state to `null`.
  void clearPublishedOffer() {
    state = state.copyWith(publishedOffer: null);
  }

  /// Find an offer by mnemonic and update state with the found offer.
  ///
  /// Validates that [mnemonic] is provided and queries the SDK to find the
  /// offer. Updates state with the found offer and any error code returned.
  ///
  /// [mnemonic] - The offer mnemonic to search for.
  ///
  /// Throws [AppException] if:
  /// - [mnemonic] is empty.
  ///
  /// Returns:
  /// - `Future<void>` completes when the offer lookup and state update finish.
  Future<void> findOffer(String mnemonic) async {
    if (mnemonic.isEmpty) {
      throw AppException(
        'Mnemonic is required',
        code: AppExceptionType.missingMnemonic.name,
      );
    }

    final sdk = await ref.read(meetingPlaceSdkProvider.future);
    final result = await sdk.findOffer(mnemonic: mnemonic);

    if (result.errorCode != null) {
      throw AppException('Unable to find offer', code: result.errorCode!.name);
    }

    if (result.connectionOffer == null) {
      throw AppException(
        'Unable to find offer',
        code: AppExceptionType.offerNotFound.name,
      );
    }

    state = state.copyWith(selectedOffer: result.connectionOffer);
  }

  /// Retrieve an offer by mnemonic and set it as the selected offer.
  ///
  /// If the currently found offer matches [mnemonic] that offer will be used
  /// as the selected offer immediately. Otherwise the SDK is queried to find
  /// the offer and the result is set as `selectedOffer` in state.
  ///
  /// [mnemonic] - The offer mnemonic to retrieve.
  ///
  /// Returns:
  /// - `Future<void>` completes when the selected offer has been resolved
  ///  and state updated.
  Future<void> getOffer(String mnemonic) async {
    if (state.selectedOffer?.mnemonic == mnemonic) {
      return;
    }

    final sdk = await ref.read(meetingPlaceSdkProvider.future);
    final result = await sdk.findOffer(mnemonic: mnemonic);

    if (result.errorCode != null) {
      throw AppException('Unable to find offer', code: result.errorCode!.name);
    }

    if (result.connectionOffer == null) {
      throw AppException(
        'Unable to find offer',
        code: AppExceptionType.other.name,
      );
    }

    state = state.copyWith(selectedOffer: result.connectionOffer);
  }
}
