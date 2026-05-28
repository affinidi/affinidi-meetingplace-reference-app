import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';

import '../../../../infrastructure/extensions/vrc_extensions.dart';
import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../../infrastructure/plugins/vrc_attachments_plugin/vrc_attachment.dart';
import '../../../../infrastructure/providers/credentials_sdk_provider.dart';
import '../../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../connections_service/connections_service.dart';
import '../../identities_service/identities_service.dart';
import '../../vrc_service/vrc_service.dart';

typedef VrcRequestReceivedCallback =
    Future<void> Function(
      String otherPartyPermanentDid,
      String? identityDid,
      String? identityName, {
      bool shouldPromptForAction,
    });

/// Manages VDIP stream subscriptions and pending-event replay for a single
/// VRC-capable channel.
class VdipManager {
  VdipManager({
    required Ref ref,
    required String otherPartyPermanentDid,
    required AppLogger logger,
    required MeetingPlaceChatSDK? Function() getChatSdk,
    required List<ChatItem> Function() getMessages,
    required Future<void> Function(EventMessageType) persistLocalEventMessage,
    required VrcRequestReceivedCallback onVrcRequestReceived,
  }) : _ref = ref,
       _otherPartyPermanentDid = otherPartyPermanentDid,
       _logger = logger,
       _getChatSdk = getChatSdk,
       _getMessages = getMessages,
       _persistLocalEventMessage = persistLocalEventMessage,
       _onVrcRequestReceived = onVrcRequestReceived;

  static const _logKey = 'VDIP';

  final Ref _ref;
  final String _otherPartyPermanentDid;
  final AppLogger _logger;
  final MeetingPlaceChatSDK? Function() _getChatSdk;
  final List<ChatItem> Function() _getMessages;
  final Future<void> Function(EventMessageType) _persistLocalEventMessage;
  final VrcRequestReceivedCallback _onVrcRequestReceived;

  /// Convenience accessor for the lazily-provided chat SDK.
  MeetingPlaceChatSDK? get _chatSdk => _getChatSdk();

  bool _isConnectionInitiator = false;
  StreamSubscription<dynamic>? _vrcRequestSubscription;
  StreamSubscription<dynamic>? _vrcSubscription;

  /// Cancels all active VDIP stream subscriptions.
  Future<void> cancelSubscriptions() async {
    await _vrcRequestSubscription?.cancel();
    await _vrcSubscription?.cancel();
    _vrcRequestSubscription = null;
    _vrcSubscription = null;
  }

  /// Resolves the [Channel] and verified other-party DID for this manager's
  /// [_otherPartyPermanentDid]. Returns `null` when the channel cannot be
  /// found or the other-party DID is absent.
  Future<({Channel channel, String otherPartyDid})?> _resolveChannel() async {
    final coreSdk = await _ref.read(meetingPlaceSdkProvider.future);
    final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
      _otherPartyPermanentDid,
    );
    if (channel == null) return null;
    final otherPartyDid = channel.otherPartyPermanentChannelDid;
    if (otherPartyDid == null || otherPartyDid.isEmpty) return null;
    return (channel: channel, otherPartyDid: otherPartyDid);
  }

  /// Subscribes to incoming VRC requests and VRCs for this channel.
  Future<void> subscribe() async {
    await cancelSubscriptions();
    final resolved = await _resolveChannel();
    if (resolved == null) {
      _logger.warning(
        'Cannot subscribe to VDIP: channel or permanent DID not found',
        name: _logKey,
      );
      return;
    }
    final (:channel, :otherPartyDid) = resolved;

    final credentialsSdk = await _ref.read(credentialsSdkProvider.future);
    _isConnectionInitiator = channel.isConnectionInitiator;

    _vrcRequestSubscription = credentialsSdk.receivedVrcRequests
        .where((request) => request.senderDid == otherPartyDid)
        .listen((request) {
          // Clear the pending cache: this live delivery supersedes any cached
          // event, preventing a double-handle on the next session open.
          credentialsSdk.consumePendingVrcRequest(otherPartyDid);
          unawaited(
            _handleReceivedVrcRequest(request, channel, credentialsSdk),
          );
        });

    _vrcSubscription = credentialsSdk.receivedVrcs
        .where((receivedVrc) => receivedVrc.senderDid == otherPartyDid)
        .listen((receivedVrc) {
          credentialsSdk.consumePendingVrc(otherPartyDid);
          unawaited(
            _handleReceivedVrc(receivedVrc.vcBlob, credentialsSdk, channel),
          );
        });
  }

  /// Replays cached VRC requests and VRCs that arrived before this session
  /// was opened. Must be called after messages are loaded via [_getMessages].
  Future<void> replayPending() async {
    final resolved = await _resolveChannel();
    if (resolved == null) {
      _logger.warning(
        'Cannot replay pending VDIP events: channel or permanent DID not found',
        name: _logKey,
      );
      return;
    }
    final (:channel, :otherPartyDid) = resolved;

    final credentialsSdk = await _ref.read(credentialsSdkProvider.future);

    final pendingRequest = credentialsSdk.consumePendingVrcRequest(
      otherPartyDid,
    );
    if (pendingRequest != null) {
      await _handleReceivedVrcRequest(pendingRequest, channel, credentialsSdk);
    }

    final pendingVrc = credentialsSdk.consumePendingVrc(otherPartyDid);
    if (pendingVrc != null) {
      await _handleReceivedVrc(pendingVrc.vcBlob, credentialsSdk, channel);
    }
  }

  /// Calls the SDK to determine the VRC-request protocol outcome, then
  /// calls onVrcRequestReceived with the appropriate shouldPromptForAction
  /// flag. When the outcome is [VrcRequestProcessingResultIssued], the
  /// outgoing VRC card is created from the blob returned in the result.
  Future<void> _handleReceivedVrcRequest(
    VrcRequest request,
    Channel channel,
    MeetingPlaceCredentialsSDK credentialsSdk,
  ) async {
    final messages = _getMessages();
    final outcome = await credentialsSdk.handleReceivedVrcRequest(
      permanentChannelDid: _otherPartyPermanentDid,
      request: request,
      hasVrcExchangeInitiated: messages.hasVrcExchangeInitiated,
      isConnectionInitiator: channel.isConnectionInitiator,
      issuerDid: messages.vrcInitiatorIdentityDid,
      issuerName: messages.vrcInitiatorIdentityName,
    );

    switch (outcome) {
      case VrcRequestProcessingResultPromptRequired():
        await _onVrcRequestReceived(
          _otherPartyPermanentDid,
          request.identityDid,
          request.identityName,
        );
      case VrcRequestProcessingResultIssued(:final sentVcBlob):
        await _onVrcRequestReceived(
          _otherPartyPermanentDid,
          request.identityDid,
          request.identityName,
          shouldPromptForAction: false,
        );
        await _chatSdk?.createAttachmentMessage(
          attachments: [VrcAttachment(vcBlob: sentVcBlob).toAttachment()],
          senderDid: channel.permanentChannelDid ?? '',
        );
        _logger.info(
          'Handled simultaneous VRC request by issuing immediately',
          name: _logKey,
        );
      case VrcRequestProcessingResultWaiting():
        await _onVrcRequestReceived(
          _otherPartyPermanentDid,
          request.identityDid,
          request.identityName,
          shouldPromptForAction: false,
        );
        _logger.info(
          'Handled simultaneous VRC request by waiting for peer VRC',
          name: _logKey,
        );
    }
  }

  /// Calls the SDK to determine the correct protocol outcome, then saves and
  /// displays VRC cards based on the result. Returns without side effects when
  /// the SDK returns [VrcProcessingResultIgnored] (exchange already complete).
  /// On [VrcProcessingResultReciprocated], shows the incoming card first then
  /// the outgoing card to guarantee deterministic display order.
  Future<void> _handleReceivedVrc(
    String vcBlob,
    MeetingPlaceCredentialsSDK credentialsSdk,
    Channel channel,
  ) async {
    final messages = _getMessages();

    final outcome = await credentialsSdk.handleReceivedVrc(
      permanentChannelDid: _otherPartyPermanentDid,
      vcBlob: vcBlob,
      exchangeState: VrcExchangeState(
        hasVrcExchangeInitiated: messages.hasVrcExchangeInitiated,
        hasVrcRequestReceived: messages.hasVrcRequestReceived,
        hasVrcExchangeCompleted: messages.hasVrcExchangeCompleted,
        isConnectionInitiator: _isConnectionInitiator,
      ),
      issuerDid: messages.vrcInitiatorIdentityDid,
      issuerName: messages.vrcInitiatorIdentityName,
    );

    switch (outcome) {
      case VrcProcessingResultIgnored():
        return;
      case VrcProcessingResultCompleted():
        await _ref
            .read(vrcServiceProvider.notifier)
            .saveVrc(vcBlob, _otherPartyPermanentDid);
        await _chatSdk?.createAttachmentMessage(
          attachments: [VrcAttachment(vcBlob: vcBlob).toAttachment()],
          senderDid: channel.otherPartyPermanentChannelDid ?? '',
        );
        await _persistLocalEventMessage(
          EventMessageType.fromJson('vrcExchangeCompleted'),
        );
        _logger.info(
          'VRC exchange completed (outcome: completed)',
          name: _logKey,
        );
        final completedIdentityDid =
            messages.vrcInitiatorIdentityDid ??
            _ref
                .read(vrcServiceProvider)
                .firstWhereOrNull((v) => v.channelId == _otherPartyPermanentDid)
                ?.holderIdentityDid;
        final completedIdentity = completedIdentityDid != null
            ? _ref
                  .read(identitiesServiceProvider)
                  .identities
                  .firstWhereOrNull((i) => i.did == completedIdentityDid)
            : null;
        if (completedIdentity != null) {
          unawaited(
            _ref
                .read(connectionsServiceProvider.notifier)
                .updatePublishedOffersScore(completedIdentity),
          );
        }
      case VrcProcessingResultReciprocated(:final sentVcBlob):
        await _ref
            .read(vrcServiceProvider.notifier)
            .saveVrc(vcBlob, _otherPartyPermanentDid);
        await _chatSdk?.createAttachmentMessage(
          attachments: [VrcAttachment(vcBlob: vcBlob).toAttachment()],
          senderDid: channel.otherPartyPermanentChannelDid ?? '',
        );
        await _chatSdk?.createAttachmentMessage(
          attachments: [VrcAttachment(vcBlob: sentVcBlob).toAttachment()],
          senderDid: channel.permanentChannelDid ?? '',
        );
        await _persistLocalEventMessage(
          EventMessageType.fromJson('vrcExchangeCompleted'),
        );
        _logger.info(
          'VRC exchange completed (outcome: reciprocated)',
          name: _logKey,
        );
        final reciprocatedIdentityDid =
            messages.vrcInitiatorIdentityDid ??
            _ref
                .read(vrcServiceProvider)
                .firstWhereOrNull((v) => v.channelId == _otherPartyPermanentDid)
                ?.holderIdentityDid;
        final reciprocatedIdentity = reciprocatedIdentityDid != null
            ? _ref
                  .read(identitiesServiceProvider)
                  .identities
                  .firstWhereOrNull((i) => i.did == reciprocatedIdentityDid)
            : null;
        if (reciprocatedIdentity != null) {
          unawaited(
            _ref
                .read(connectionsServiceProvider.notifier)
                .updatePublishedOffersScore(reciprocatedIdentity),
          );
        }
    }
  }
}
