import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/connections_service/connections_service.dart';
import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/mediator_service/mediator_service.dart';
import '../../../domain/models/mediator/mediator.dart';
import '../../../infrastructure/extensions/connections_screen_filter_extensions.dart';
import 'connections_screen_filter.dart';
import 'connections_screen_state.dart';

part 'connections_screen_controller.g.dart';

@Riverpod(keepAlive: true)
class ConnectionsScreenController extends _$ConnectionsScreenController {
  ConnectionsScreenController() : super();

  @override
  ConnectionsScreenState build() {
    ref.listen(
      identitiesServiceProvider.currentIdentityOrPrimary,
      (prev, next) {
        if (prev == next) return;

        Future.microtask(() {
          state = state.copyWith(identity: next);
        });
      },
      fireImmediately: true,
    );

    ref.listen(
      connectionsServiceProvider.select((state) => state.connections),
      (prev, next) {
        if (prev == next) return;

        final prevIds =
            prev?.map((c) => c.publishOfferDid).toSet() ?? <String>{};
        final nextIds = next.map((c) => c.publishOfferDid).toSet();
        final newIds = nextIds.difference(prevIds);

        final newConnections =
            next.where((c) => newIds.contains(c.publishOfferDid));

        Future.microtask(() {
          state = state.copyWith(connections: next);
          _updateConnectionMediators(newConnections);
        });
      },
      fireImmediately: true,
    );

    ref.listen(
      mediatorServiceProvider,
      (prev, next) {
        if (prev == next) return;

        Future.microtask(_updateConnectionMediators);
      },
      fireImmediately: true,
    );

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
  ProviderListenable<bool> get hasConnections => select(
        (state) => state.connections.any(
          (connection) => connection.status != ConnectionOfferStatus.deleted,
        ),
      );
  ProviderListenable<bool> get hasAnySelectedConnections =>
      select((state) => state.selectedConnections.isNotEmpty);
  ProviderListenable<bool> get hasIdentity =>
      select((state) => state.identity != null);
  ProviderListenable<List<ConnectionOffer>> get filteredConnections =>
      select((state) {
        return state.connections
            .where(
              (connection) =>
                  connection.status != ConnectionOfferStatus.deleted &&
                  state.filter.statuses.contains(connection.status),
            )
            .toList();
      });
}
