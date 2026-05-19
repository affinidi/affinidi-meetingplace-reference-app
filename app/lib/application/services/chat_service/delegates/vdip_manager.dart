import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';

import '../../../../infrastructure/extensions/vrc_extensions.dart';
import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../../infrastructure/plugins/vrc_attachments_plugin/vrc_attachment.dart';
import '../../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../../infrastructure/providers/relationship_sdk_provider.dart';
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

    final relationshipSdk = await _ref.read(relationshipSdkProvider.future);
    _isConnectionInitiator = channel.isConnectionInitiator;

    _vrcRequestSubscription = relationshipSdk.receivedVrcRequests
        .where((request) => request.senderDid == otherPartyDid)
        .listen((request) {
          // Clear the pending cache: this live delivery supersedes any cached
          // event, preventing a double-handle on the next session open.
          relationshipSdk.consumePendingVrcRequest(otherPartyDid);
          unawaited(
            _handleReceivedVrcRequest(request, channel, relationshipSdk),
          );
        });

    _vrcSubscription = relationshipSdk.receivedVrcs
        .where((receivedVrc) => receivedVrc.senderDid == otherPartyDid)
        .listen((receivedVrc) {
          relationshipSdk.consumePendingVrc(otherPartyDid);
          unawaited(
            _handleReceivedVrc(receivedVrc.vcBlob, relationshipSdk, channel),
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

    final relationshipSdk = await _ref.read(relationshipSdkProvider.future);

    final pendingRequest = relationshipSdk.consumePendingVrcRequest(
      otherPartyDid,
    );
    if (pendingRequest != null) {
      await _handleReceivedVrcRequest(pendingRequest, channel, relationshipSdk);
    }

    final pendingVrc = relationshipSdk.consumePendingVrc(otherPartyDid);
    if (pendingVrc != null) {
      await _handleReceivedVrc(pendingVrc.vcBlob, relationshipSdk, channel);
    }
  }

  /// Processes an incoming VRC request and notifies the caller via
  /// onVrcRequestReceived with the appropriate shouldPromptForAction flag
  /// derived from the SDK-determined [VrcRequestProcessingResult].
  Future<void> _handleReceivedVrcRequest(
    VrcRequest request,
    Channel channel,
    MeetingPlaceRelationshipSDK relationshipSdk,
  ) async {
    final messages = _getMessages();
    final outcome = await relationshipSdk.handleReceivedVrcRequest(
      permanentChannelDid: _otherPartyPermanentDid,
      request: request,
      hasVrcExchangeInitiated: messages.hasVrcExchangeInitiated,
      isConnectionInitiator: channel.isConnectionInitiator,
      issuerDid: messages.vrcInitiatorIdentityDid,
      issuerName: messages.vrcInitiatorIdentityName,
      // Show the auto-issued VRC card (simultaneous-request owner path).
      onVrcSent: (sentVcBlob) => unawaited(
        _chatSdk?.createAttachmentMessage(
          attachments: [VrcAttachment(vcBlob: sentVcBlob).toAttachment()],
          senderDid: channel.permanentChannelDid ?? '',
        ),
      ),
    );

    switch (outcome) {
      case VrcRequestProcessingResult.prompt:
        await _onVrcRequestReceived(
          _otherPartyPermanentDid,
          request.identityDid,
          request.identityName,
        );
      case VrcRequestProcessingResult.issued:
        await _onVrcRequestReceived(
          _otherPartyPermanentDid,
          request.identityDid,
          request.identityName,
          shouldPromptForAction: false,
        );
        _logger.info(
          'Handled simultaneous VRC request by issuing immediately',
          name: _logKey,
        );
      case VrcRequestProcessingResult.waiting:
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

  /// Saves the received VRC, shows an incoming card, and—when the exchange is
  /// not yet complete—calls back into the SDK to reciprocate or finalise the
  /// exchange and persists the completion event.
  Future<void> _handleReceivedVrc(
    String vcBlob,
    MeetingPlaceRelationshipSDK relationshipSdk,
    Channel channel,
  ) async {
    await _ref
        .read(vrcServiceProvider.notifier)
        .saveVrc(vcBlob, _otherPartyPermanentDid);

    // Show the received VRC card immediately as an incoming attachment.
    await _chatSdk?.createAttachmentMessage(
      attachments: [VrcAttachment(vcBlob: vcBlob).toAttachment()],
      senderDid: channel.otherPartyPermanentChannelDid ?? '',
    );

    final messages = _getMessages();
    if (messages.hasVrcExchangeCompleted) return;

    final outcome = await relationshipSdk.handleReceivedVrc(
      permanentChannelDid: _otherPartyPermanentDid,
      vcBlob: vcBlob,
      exchangeState: VrcExchangeState(
        hasVrcExchangeInitiated: messages.hasVrcExchangeInitiated,
        hasVrcRequestReceived: messages.hasVrcRequestReceived,
        isConnectionInitiator: _isConnectionInitiator,
      ),
      issuerDid: messages.vrcInitiatorIdentityDid,
      issuerName: messages.vrcInitiatorIdentityName,
      // Show the reciprocated VRC card as an outgoing attachment.
      onVrcSent: (sentVcBlob) => unawaited(
        _chatSdk?.createAttachmentMessage(
          attachments: [VrcAttachment(vcBlob: sentVcBlob).toAttachment()],
          senderDid: channel.permanentChannelDid ?? '',
        ),
      ),
    );

    switch (outcome) {
      case VrcProcessingResult.reciprocated:
      case VrcProcessingResult.completed:
        await _persistLocalEventMessage(
          EventMessageType.fromJson('vrcExchangeCompleted'),
        );
        _logger.info(
          'VRC exchange completed (outcome: $outcome)',
          name: _logKey,
        );
        final identityDid =
            messages.vrcInitiatorIdentityDid ??
            _ref
                .read(vrcServiceProvider)
                .firstWhereOrNull((v) => v.channelId == _otherPartyPermanentDid)
                ?.holderIdentityDid;
        final identity = identityDid != null
            ? _ref
                  .read(identitiesServiceProvider)
                  .identities
                  .firstWhereOrNull((i) => i.did == identityDid)
            : null;
        if (identity != null) {
          unawaited(
            _ref
                .read(connectionsServiceProvider.notifier)
                .updatePublishedOffersScore(identity),
          );
        }
      case VrcProcessingResult.ignored:
        break;
    }
  }
}
