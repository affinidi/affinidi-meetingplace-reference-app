import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../connections_service/connections_service.dart';
import '../contacts_service/contacts_service.dart';

part 'contacts_connections_service.g.dart';

/// Service responsible for synchronizing contacts and connections in response
/// to relevant events.
///
/// This service listens for group channel inauguration, contact card updates,
/// and contact leaving chat events, coordinating updates between
/// ContactsService and ConnectionsService.
///
/// It reacts to:
/// - onGroupOfferChannelInaugurated from ConnectionsService: updates contacts
///   based on the newly inaugurated channel.
/// - onContactCardUpdated from ContactsService: triggers a connections refresh.
/// - onContactLeftChat from ContactsService: triggers a connections refresh.
class ContactsConnectionsService {
  ContactsConnectionsService(Ref ref) {
    final contactsServiceNotifier = ref.read(contactsServiceProvider.notifier);
    final connectionsServiceNotifier = ref.read(
      connectionsServiceProvider.notifier,
    );

    connectionsServiceNotifier.onGroupOfferChannelInaugurated.listen((channel) {
      Future(() {
        contactsServiceNotifier.updateContactFromChannelActivity(channel);
      });
    });

    contactsServiceNotifier.onContactCardUpdated.listen((contactDid) {
      Future(connectionsServiceNotifier.fetchConnections);
    });

    contactsServiceNotifier.onContactLeftChat.listen((channel) {
      Future(connectionsServiceNotifier.fetchConnections);
    });
  }
}

/// Provider that exposes a single ContactsConnectionsService instance.
///
/// The provider is kept alive for the app lifetime and constructs the service
/// which registers cross-service listeners to keep contact cards and
/// connections in sync.
///
/// [ref] - Riverpod Ref passed by the provider system.
///
/// Returns:
/// - `ContactsConnectionsService` instance with listeners registered.
@Riverpod(keepAlive: true)
ContactsConnectionsService contactsConnectionsService(Ref ref) {
  return ContactsConnectionsService(ref);
}
