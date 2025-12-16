import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/connections_service/connections_service.dart';
import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/mediator_service/mediator_service.dart';
import '../../../application/services/settings_service/settings_service.dart';
import '../../../domain/models/contacts/contact_status.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../domain/models/mediator/mediator.dart';
import '../../../infrastructure/extensions/connections_screen_filter_extensions.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/extensions/vcard_extensions.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../chat/chat_screen_controller.dart';
import '../offer/publish_offer_screen/publish_offer_form_data.dart';
import 'connections_screen_filter.dart';
import 'connections_screen_state.dart';

part 'connections_screen_controller.g.dart';

@Riverpod(keepAlive: true)
class ConnectionsScreenController extends _$ConnectionsScreenController {
  ConnectionsScreenController() : super();

  @override
  ConnectionsScreenState build() {
    ref.listen(identitiesServiceProvider.currentIdentityOrPrimary,
        (prev, next) {
      if (prev == next) return;

      Future.microtask(() {
        state = state.copyWith(identity: next);
      });
    }, fireImmediately: true);

    ref.listen(connectionsServiceProvider.select((state) => state.connections),
        (prev, next) {
      if (prev == next) return;

      final prevIds = prev?.map((c) => c.publishOfferDid).toSet() ?? <String>{};
      final nextIds = next.map((c) => c.publishOfferDid).toSet();
      final newIds = nextIds.difference(prevIds);

      final newConnections =
          next.where((c) => newIds.contains(c.publishOfferDid));

      Future.microtask(() {
        state = state.copyWith(connections: next);
        _updateConnectionMediators(newConnections);
      });
    }, fireImmediately: true);

    ref.listen(mediatorServiceProvider, (prev, next) {
      if (prev == next) return;

      Future.microtask(_updateConnectionMediators);
    }, fireImmediately: true);

    return ConnectionsScreenState(isEditMode: false);
  }

  void setSelectedConnections(List<ConnectionOffer> connections) {
    if (state.selectedConnections != connections) {
      state = state.copyWith(selectedConnections: connections);
    }
  }

  void cancelEdit() {
    state = state.copyWith(isEditMode: false, selectedConnections: []);
  }

  void toggleEditMode() {
    state =
        state.copyWith(isEditMode: !state.isEditMode, selectedConnections: []);
  }

  Future<void> deleteConnection(ConnectionOffer connection) async {
    await ref
        .read(connectionsServiceProvider.notifier)
        .markConnectionOfferAsDeleted(connection);
  }

  Future<void> deleteSelectedConnections() async {
    for (final connection in state.selectedConnections) {
      await ref
          .read(connectionsServiceProvider.notifier)
          .markConnectionOfferAsDeleted(connection);
    }
    state = state.copyWith(isEditMode: false);
  }

  void applyFilter(ConnectionsScreenFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Starts the match maker flow by publishing an offer and navigating to chat.
  Future<void> onStartMatchmaker(
      BuildContext context, Identity identity) async {
    if (!context.mounted) return;

    // Get the selected mediator DID from settings
    final selectedMediatorDid =
        ref.read(settingsServiceProvider).selectedMediatorDid;

    // Build PublishOfferFormData
    final formData = PublishOfferFormData(
      headline: 'Match Maker Connection Invitation',
      description: 'Automated match making request',
      isGroupOffer: false,
      hasExpiry: false,
      hasMaxUsages: false,
      randomPhraseEnabled: false,
      isSearchable: false,
      selectedMediatorDid: selectedMediatorDid,
    );

    try {
      final contacts = ref.read(contactsServiceProvider).contacts;
      final matchingContact = contacts.firstWhereOrNull(
        (contact) =>
            contact.status == ContactStatus.active &&
            contact.vCard.fullName == 'Event Agent',
      );

      if (matchingContact == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Matchmaker contact not found')),
        );
        return;
      }

      // Publish the offer
      ConnectionOffer? connectionOffer =
          await ref.read(connectionsServiceProvider.notifier).publishOffer(
                formData,
                identity: identity,
              );

      // Navigate to chat with contactId - 'event concierge'
      if (!context.mounted || connectionOffer == null) return;
      final container = ProviderScope.containerOf(context);
      final contactId = matchingContact.id;
      final provider = chatScreenControllerProvider(contactId);
      final element = container.readProviderElement(provider);

      final link = (element as AutoDisposeNotifierProviderElement).keepAlive();

      await ref.read(provider.notifier).initialize();

      // Send the message to the chat
      final chatController = ref.read(provider.notifier);
      await chatController.sendMessageDirect(
          '@Matchmaker - can you make some recommendations for people I should connect with? I will use my persona "${identity.card.displayName}" to connect with them.',
          attachments: [
            Attachment(
              id: 'matchmaker_passphrase',
              data: AttachmentData(
                base64: base64Encode(utf8.encode(connectionOffer.mnemonic)),
              ),
            ),
            Attachment(
              id: 'matchmaker_identity',
              data: AttachmentData(
                base64: identity.card.toVCard().toBase64(),
              ),
            ),
          ]);

      await ChatRoute(contactId: contactId).push<void>(context);
      link.close();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  /// Updates the connection mediators map by finding the nearest mediator
  /// for each connection based on creation time and DID.
  void _updateConnectionMediators([
    Iterable<ConnectionOffer>? connectionsToProcess,
  ]) {
    final mediatorService = ref.read(mediatorServiceProvider.notifier);
    final connectionMediators =
        Map<String, Mediator>.from(state.connectionMediators);

    final connections = connectionsToProcess ?? state.connections;

    for (final connection in connections) {
      final mediator = mediatorService.findNearestMediatorBefore(
        dateTime: connection.createdAt,
        did: connection.mediatorDid,
      );
      if (mediator != null) {
        connectionMediators[connection.publishOfferDid] = mediator;
      }
    }

    state = state.copyWith(connectionMediators: connectionMediators);
  }
}

extension ConnectionsScreenControllerProviderSelectors
    on NotifierProvider<ConnectionsScreenController, ConnectionsScreenState> {
  ProviderListenable<bool> get hasConnections => select((state) => state
      .connections
      .any((connection) => connection.status != ConnectionOfferStatus.deleted));
  ProviderListenable<bool> get hasAnySelectedConnections =>
      select((state) => state.selectedConnections.isNotEmpty);
  ProviderListenable<bool> get hasIdentity =>
      select((state) => state.identity != null);
  ProviderListenable<List<ConnectionOffer>> get filteredConnections =>
      select((state) {
        return state.connections
            .where((connection) =>
                connection.status != ConnectionOfferStatus.deleted &&
                state.filter.statuses.contains(connection.status))
            .toList();
      });
}
