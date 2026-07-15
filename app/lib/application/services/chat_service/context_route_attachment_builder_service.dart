import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

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
    final selectedContext = _ref
        .read(contextRoutingServiceProvider)
        .contextForContactId(contactId);
    final contextValue = selectedContext == AgentContext.work
        ? 'ctx-0'
        : 'ctx-1';
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
}

final contextRouteAttachmentBuilderServiceProvider =
    Provider<ContextRouteAttachmentBuilderService>(
      ContextRouteAttachmentBuilderService.new,
      name: 'contextRouteAttachmentBuilderServiceProvider',
    );
