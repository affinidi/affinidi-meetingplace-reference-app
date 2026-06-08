import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../connections_service/connections_service.dart';
import '../contacts_service/contacts_service.dart';
import '../identities_service/identities_service.dart';

part 'contacts_identities_service.g.dart';

/// Bridge service that resolves identity information for contacts.
class ContactsIdentitiesService {
  ContactsIdentitiesService(this._ref);

  final Ref _ref;
  static const _logKey = 'CTXIDSVC';

  AppLogger get _logger => _ref.read(appLoggerProvider);

  Future<Identity?> resolveIdentityForContact(String contactId) async {
    final contact = _ref.read(contactsServiceProvider).getContactById(contactId);
    if (contact == null) {
      _logger.warning(
        'resolveIdentityForContact: unknown contact $contactId',
        name: _logKey,
      );
      return null;
    }

    final identityId = await _resolveIdentityIdForContact(contact);
    if (identityId == null) {
      _logger.warning(
        'resolveIdentityForContact: no identity linked to contact $contactId',
        name: _logKey,
      );
      return null;
    }

    await _ref.read(identitiesServiceProvider.notifier).ensureInitialized();
    final identity = _ref.read(identitiesServiceProvider).getIdentityById(
      identityId,
    );
    if (identity == null) {
      _logger.warning(
        'resolveIdentityForContact: identity $identityId not in wallet',
        name: _logKey,
      );
    }
    return identity;
  }

  Future<String?> _resolveIdentityIdForContact(Contact contact) async {
    if (contact.channelDid != null) {
      final coreSdk = await _ref.read(meetingPlaceSdkProvider.future);
      final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
        contact.channelDid!,
      );
      final channelIdentityId = channel?.externalRef;
      if (channelIdentityId != null && channelIdentityId.isNotEmpty) {
        return channelIdentityId;
      }
    }

    await _ref.read(connectionsServiceProvider.notifier).ensureInitialized();
    final offerIdentityId = _ref
        .read(connectionsServiceProvider)
        .getConnectionByOfferLink(contact.offerLink)
        ?.externalRef;
    if (offerIdentityId != null && offerIdentityId.isNotEmpty) {
      return offerIdentityId;
    }

    return null;
  }
}

@Riverpod(keepAlive: true)
ContactsIdentitiesService contactsIdentitiesService(Ref ref) {
  return ContactsIdentitiesService(ref);
}
