import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_credentials/meeting_place_credentials.dart'
    show
        LivenessProofPayload,
        LivenessZkpAttachmentParser,
        LivenessZkpDIDCommAttachmentBuilder;

import '../../../domain/models/contacts/contact_status.dart';
import '../../../domain/models/zkp/zkp_challenge_nonce.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../services/contacts_service/contacts_service.dart';
import '../chat_service/chat_session_service.dart';
import '../contacts_identities_service/contacts_identities_service.dart';
import '../zkp_service/zkp_service.dart';
import '../zkp_service/zkp_service_state.dart';

class ZkpSendProofResult {
  const ZkpSendProofResult._({
    required this.error,
    required this.resolvedChallengeNonce,
  });

  const ZkpSendProofResult.success({required List<int>? resolvedChallengeNonce})
    : this._(error: null, resolvedChallengeNonce: resolvedChallengeNonce);

  const ZkpSendProofResult.failure({
    required String error,
    required List<int>? resolvedChallengeNonce,
  }) : this._(error: error, resolvedChallengeNonce: resolvedChallengeNonce);

  final String? error;
  final List<int>? resolvedChallengeNonce;
}

class ZkpFlowService {
  ZkpFlowService({required Ref ref, required this._contactId}) : _ref = ref {
    _logger = ref.read(appLoggerProvider);
  }

  final Ref _ref;
  final String _contactId;
  late final AppLogger _logger;

  static const _logKey = 'ZkpFlowService';

  bool readIsZkpChannelReady() {
    final contact = _ref
        .read(contactsServiceProvider)
        .getContactById(_contactId);
    if (contact == null) return false;

    if (!contact.status.isEstablished) return false;

    final channelDid = contact.channelDid;
    if (channelDid == null) return false;

    return _ref.read(chatSessionServiceProvider(channelDid)).isInitialized;
  }

  Future<bool> requestLivenessCheck() async {
    if (!readIsZkpChannelReady()) {
      _logger.warning(
        'ZKP request blocked: connection not established '
        'for contact $_contactId',
        name: _logKey,
      );
      return false;
    }

    final challengeNonce = generateZkpChallengeNonce();
    final attachments =
        LivenessZkpDIDCommAttachmentBuilder.buildLivenessCheckRequest(
          challengeNonceHex: zkpChallengeNonceToHex(challengeNonce),
        );
    return _sendZkpAttachments(
      attachments,
      errorMessage: 'Failed to send liveness check request',
    );
  }

  List<int>? findVerifierChallengeNonceFromChatHistory() {
    final channelDid = _ref
        .read(contactsServiceProvider)
        .getContactById(_contactId)
        ?.channelDid;
    if (channelDid == null) return null;

    final messages = _ref.read(chatSessionServiceProvider(channelDid)).messages;

    for (final item in messages.reversed) {
      if (item is! chat.Message || item.isFromMe) continue;

      final payload = LivenessZkpAttachmentParser.tryParseRequestIn(
        item.attachments,
      );
      if (payload == null) continue;

      final challengeNonce = payload.challengeNonceBytes;
      if (challengeNonce.length != zkpChallengeNonceByteLength) continue;

      _logger.info(
        'Recovered verifier challenge nonce from chat history',
        name: _logKey,
      );
      return challengeNonce;
    }

    return null;
  }

  Future<ZkpSendProofResult> generateAndSendProof({
    required List<int>? challengeNonce,
  }) async {
    final identity = await _ref
        .read(contactsIdentitiesServiceProvider)
        .resolveIdentityForContact(_contactId);
    if (identity == null || identity.did.isEmpty) {
      return const ZkpSendProofResult.failure(
        error: 'No identity is linked to this connection.',
        resolvedChallengeNonce: null,
      );
    }

    _logger.info(
      'Starting proof generation for contact: $_contactId',
      name: _logKey,
    );

    final resolvedChallengeNonce =
        challengeNonce ?? findVerifierChallengeNonceFromChatHistory();

    if (resolvedChallengeNonce == null ||
        resolvedChallengeNonce.length != zkpChallengeNonceByteLength) {
      return ZkpSendProofResult.failure(
        error:
            'No liveness challenge from verifier. '
            'Ask them to send a new request.',
        resolvedChallengeNonce: resolvedChallengeNonce,
      );
    }

    final generation = await _ref
        .read(zkpServiceProvider)
        .generateProof(
          identityId: identity.id,
          challengeNonce: resolvedChallengeNonce,
        );

    switch (generation) {
      case ZkpProofGenerationFailure(:final error):
        _logger.error('Failed to generate proof: $error', name: _logKey);
        return ZkpSendProofResult.failure(
          error: error,
          resolvedChallengeNonce: resolvedChallengeNonce,
        );
      case ZkpProofGenerationSuccess(:final result):
        _logger.info(
          'Proof generated in ${result.generationTimeMs}ms',
          name: _logKey,
        );

        final attachments =
            LivenessZkpDIDCommAttachmentBuilder.buildLivenessProof(
              payload: LivenessProofPayload(
                proof: result.proof,
                publicSignals: result.publicSignals,
              ),
            );

        final channelDid = _ref
            .read(contactsServiceProvider)
            .getContactById(_contactId)
            ?.channelDid;
        if (channelDid == null) {
          return ZkpSendProofResult.failure(
            error: 'No chat channel is linked to this connection.',
            resolvedChallengeNonce: resolvedChallengeNonce,
          );
        }

        await _ref
            .read(chatSessionServiceProvider(channelDid).notifier)
            .sendTextMessage(
              '',
              attachments: List<chat.Attachment>.from(attachments),
            );

        _logger.info('Proof sent to contact successfully', name: _logKey);
        return ZkpSendProofResult.success(
          resolvedChallengeNonce: resolvedChallengeNonce,
        );
    }
  }

  Future<ZkpVerificationResult> verifyProof(
    LivenessProofPayload payload,
  ) async {
    _logger.info(
      'Starting proof verification for contact: $_contactId',
      name: _logKey,
    );

    final verification = await _ref
        .read(zkpServiceProvider)
        .verifyProof(
          proof: payload.proof,
          publicSignals: payload.publicSignals,
        );

    _logger.info('Verification result: ${verification.isValid}', name: _logKey);
    return verification;
  }

  Future<bool> sendDeclined() async {
    if (!readIsZkpChannelReady()) return false;
    final attachments =
        LivenessZkpDIDCommAttachmentBuilder.buildLivenessDeclined();
    return _sendZkpAttachments(
      attachments,
      errorMessage: 'Failed to send liveness declined event',
    );
  }

  String? _readChannelDid() {
    return _ref
        .read(contactsServiceProvider)
        .getContactById(_contactId)
        ?.channelDid;
  }

  Future<bool> _sendZkpAttachments(
    List<chat.Attachment> attachments, {
    required String errorMessage,
  }) async {
    final channelDid = _readChannelDid();
    if (channelDid == null) {
      _logger.warning(
        'ZKP message blocked: missing channel DID for contact $_contactId',
        name: _logKey,
      );
      return false;
    }

    try {
      await _ref
          .read(chatSessionServiceProvider(channelDid).notifier)
          .sendTextMessage(
            '',
            attachments: List<chat.Attachment>.from(attachments),
          );
      return true;
    } catch (error, stackTrace) {
      _logger.error(
        errorMessage,
        name: _logKey,
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
