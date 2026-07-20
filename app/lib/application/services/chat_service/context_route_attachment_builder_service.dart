import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../domain/models/contacts/contact_category.dart';
import '../contacts_service/contacts_service.dart';
import '../context_routing_service/context_routing_service.dart';

/// Builds cierge context-route attachments for outbound chat messages.
///
/// Wire-format details are intentionally centralized here so presentation
/// controllers only coordinate actions instead of constructing protocol
/// payloads.
class ContextRouteAttachmentBuilderService {
  const ContextRouteAttachmentBuilderService(this._ref);

  final Ref _ref;

  ChatAttachment buildForContactId(String contactId) {
    final routingState = _ref.read(contextRoutingServiceProvider);
    final mappedContext = routingState.contactContexts[contactId];
    final selectedContext = mappedContext ?? _inferDefaultContext(contactId);
    final contextValue = selectedContext == AgentContext.work
        ? 'work'
        : 'personal';
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final payload = jsonEncode({'context': contextValue});

    return ChatAttachment(
      id: 'cierge-context-route-$timestamp-$contextValue',
      mediaType: 'application/json',
      filename: 'cierge-context-route.json',
      format: 'cierge/context-route',
      data: ChatAttachmentData(
        json: payload,
        base64: base64Encode(utf8.encode(payload)),
      ),
    );
  }

  AgentContext _inferDefaultContext(String contactId) {
    final contact = _ref
        .read(contactsServiceProvider)
        .getContactById(contactId);
    if (contact == null) {
      return AgentContext.personal;
    }

    final isAiContact =
        contact.category == ContactCategory.robot ||
        contact.card.type.trim().toLowerCase() == 'ai-agent';
    if (!isAiContact) {
      return AgentContext.personal;
    }

    final label = [
      contact.displayName ?? '',
      contact.card.displayName,
      contact.card.firstName,
    ].join(' ').toLowerCase();

    if (label.contains('work')) return AgentContext.work;
    if (label.contains('personal')) return AgentContext.personal;

    final aiContacts =
        _ref
            .read(contactsServiceProvider)
            .contacts
            .where(
              (c) =>
                  c.category == ContactCategory.robot ||
                  c.card.type.trim().toLowerCase() == 'ai-agent',
            )
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    if (aiContacts.length >= 2) {
      final idx = aiContacts.indexWhere((c) => c.id == contact.id);
      if (idx == 0) return AgentContext.work;
      if (idx == 1) return AgentContext.personal;
    }

    return AgentContext.personal;
  }
}

final contextRouteAttachmentBuilderServiceProvider =
    Provider<ContextRouteAttachmentBuilderService>(
      ContextRouteAttachmentBuilderService.new,
      name: 'contextRouteAttachmentBuilderServiceProvider',
    );
