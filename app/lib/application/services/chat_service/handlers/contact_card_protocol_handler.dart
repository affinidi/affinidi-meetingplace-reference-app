import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;

import '../../../../domain/models/contact_card/contact_card.dart' as domain;
import '../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../services/contacts_service/contacts_service.dart';
import 'interfaces/chat_protocol_handler.dart';

/// Handles `ChatProtocol.chatContactDetailsUpdate`.
///
/// For individual chats: parses the contact card payload and notifies the
/// caller. For group chats: delegates to `onGroupDetailsUpdated` since a
/// contact update in a group context triggers a full group refresh.
class ContactCardProtocolHandler implements ChatProtocolHandler {
  ContactCardProtocolHandler({
    required this._ref,
    required this._isGroupChat,
    required this._onGroupDetailsUpdated,
    required this._onOtherPartyCardUpdated,
    required this._logger,
  });

  static const _logKey = 'CONTACTCARDPROTOCOLHANDLER';

  final Ref _ref;
  final bool Function() _isGroupChat;
  final void Function(StreamData data, String channelDid)
  _onGroupDetailsUpdated;
  final void Function(domain.ContactCard card) _onOtherPartyCardUpdated;
  final AppLogger _logger;

  @override
  bool canHandle(String protocolType) =>
      protocolType == ChatProtocol.chatContactDetailsUpdate.value;

  @override
  Future<void> handle(StreamData data, String channelDid) async {
    if (_isGroupChat()) {
      _onGroupDetailsUpdated(data, channelDid);
      return;
    }

    final plainTextMessage = data.plainTextMessage;
    if (plainTextMessage == null) {
      _logger.warning(
        'Received a contact details update without a message',
        name: _logKey,
      );
      return;
    }

    final contactDid = plainTextMessage.from;
    if (contactDid == null || contactDid.isEmpty) {
      _logger.warning(
        'Received a contact details update without a from',
        name: _logKey,
      );
      return;
    }

    final body = plainTextMessage.body;
    if (body == null) {
      _logger.warning(
        'Received a contact details update without a body',
        name: _logKey,
      );
      return;
    }

    final cardValues = body['contactInfo'] as Map<String, dynamic>?;
    if (cardValues == null) {
      _logger.warning(
        'Received a contact details update without a contact card',
        name: _logKey,
      );
      return;
    }

    _logger.info('Received contact card update', name: _logKey);

    final sdkCard = sdk.ContactCard(
      did: body['did'] as String,
      type: body['type'] as String,
      contactInfo: cardValues,
    );

    final domainCard = ContactCardUtils.fromSdkContactCard(sdkCard);
    _onOtherPartyCardUpdated(domainCard);
    _ref
        .read(contactsServiceProvider.notifier)
        .updateContactCard(contactDid, domainCard);
  }
}
