import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_category.dart';
import '../../../domain/models/contacts/contact_status.dart';
import '../context_routing_service/context_routing_service.dart';

String canonicalPersonalAiContextName({
  String? explicitContextName,
  required String contextId,
  required String displayName,
}) {
  final explicit = explicitContextName?.trim().toLowerCase();
  if (explicit == 'work-ai' || explicit == 'personal-ai') {
    return explicit!;
  }

  final normalizedContextId = contextId.trim().toLowerCase();
  final contextFromRoute = AgentContext.fromRouteKey(normalizedContextId);
  if (normalizedContextId == contextFromRoute.routeKey ||
      normalizedContextId == contextFromRoute.setupContextName) {
    return contextFromRoute.setupContextName;
  }

  final normalizedDisplayName = displayName.trim().toLowerCase();
  if (normalizedDisplayName.contains('work')) {
    return AgentContext.work.setupContextName;
  }
  return AgentContext.personal.setupContextName;
}

AgentContext agentContextForSetup({
  required String contextId,
  required String displayName,
}) {
  final contextName = canonicalPersonalAiContextName(
    contextId: contextId,
    displayName: displayName,
  );
  return contextName == AgentContext.work.setupContextName
      ? AgentContext.work
      : AgentContext.personal;
}

bool isAiContactBoundToOtherContext({
  required Contact contact,
  required AgentContext targetContext,
  required Map<String, AgentContext> contactContexts,
}) {
  if (contact.category != ContactCategory.robot) {
    return false;
  }

  final assignedContext = contactContexts[contact.id];
  return assignedContext != null && assignedContext != targetContext;
}

Contact? findPersonalAiContactForContext({
  required List<Contact> contacts,
  required Map<String, AgentContext> contactContexts,
  required AgentContext targetContext,
  String? offerLink,
  String? channelDid,
}) {
  for (final entry in contactContexts.entries) {
    if (entry.value != targetContext) {
      continue;
    }

    for (final contact in contacts) {
      if (contact.id == entry.key) {
        return contact;
      }
    }
  }

  final normalizedOfferLink = offerLink?.trim();
  if (normalizedOfferLink != null && normalizedOfferLink.isNotEmpty) {
    final byOfferLink = contacts.where(
      (contact) => contact.offerLink == normalizedOfferLink,
    );
    if (byOfferLink.isNotEmpty) {
      return byOfferLink.first;
    }
    return null;
  }

  final normalizedChannelDid = channelDid?.trim();
  if (normalizedChannelDid == null || normalizedChannelDid.isEmpty) {
    return null;
  }

  for (final contact in contacts) {
    if (contact.channelDid != normalizedChannelDid) {
      continue;
    }
    if (isAiContactBoundToOtherContext(
      contact: contact,
      targetContext: targetContext,
      contactContexts: contactContexts,
    )) {
      continue;
    }
    return contact;
  }

  return null;
}

bool isEstablishedPersonalAiContact({
  required Contact contact,
  required AgentContext targetContext,
  required Map<String, AgentContext> contactContexts,
}) {
  return contact.category == ContactCategory.robot &&
      contact.status == ContactStatus.active &&
      contactContexts[contact.id] == targetContext;
}

bool shouldRenamePersonalAiContact({
  required Contact contact,
  required String desiredName,
  required bool isInitialSetup,
}) {
  if (desiredName.isEmpty) {
    return false;
  }
  if (!isInitialSetup && (contact.displayName?.trim().isNotEmpty ?? false)) {
    return false;
  }

  return contact.displayName == null ||
      contact.displayName!.trim().isEmpty ||
      contact.displayName != desiredName ||
      contact.card.displayName.trim().isEmpty ||
      contact.card.displayName != desiredName;
}
