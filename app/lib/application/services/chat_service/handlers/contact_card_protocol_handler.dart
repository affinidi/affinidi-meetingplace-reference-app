import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

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
  final void Function(ChatEvent event, String channelDid)
  _onGroupDetailsUpdated;
  final void Function(domain.ContactCard card) _onOtherPartyCardUpdated;
  final AppLogger _logger;

  @override
  bool canHandle(ChatEvent event) => event is ChatContactDetailsUpdateEvent;

  @override
  Future<void> handle(ChatEvent event, String channelDid) async {
    if (_isGroupChat()) {
      _onGroupDetailsUpdated(event, channelDid);
      return;
    }

    if (event is! ChatContactDetailsUpdateEvent) {
      throw StateError('Unexpected event type: ${event.runtimeType}');
    }

    final domainCard = ContactCardUtils.fromSdkContactCard(event.contactCard);
    _logger.info('Received contact card update', name: _logKey);

    _onOtherPartyCardUpdated(domainCard);
    _ref
        .read(contactsServiceProvider.notifier)
        .updateContactCard(event.senderDid, domainCard);
  }
}
