import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../contacts_service/contacts_service.dart';
import '../context_routing_service/context_routing_service.dart';
import 'personal_ai_contact_resolution.dart';

final disconnectAgentContextServiceProvider =
    Provider<DisconnectAgentContextService>(DisconnectAgentContextService.new);

class DisconnectAgentContextService {
  const DisconnectAgentContextService(this._ref);

  final Ref _ref;

  Future<void> disconnect(AgentContext target) async {
    final contactsState = _ref.read(contactsServiceProvider);
    final routingState = _ref.read(contextRoutingServiceProvider);

    final contact = findPersonalAiContactForContext(
      contacts: contactsState.contacts,
      contactContexts: routingState.contactContexts,
      targetContext: target,
    );

    if (contact != null) {
      await _ref
          .read(contactsServiceProvider.notifier)
          .deleteContacts([contact]);
    }

    await _ref
        .read(contextRoutingServiceProvider.notifier)
        .clearContext(context: target);

    await _ref.read(contactsServiceProvider.notifier).fetchContacts();
  }
}