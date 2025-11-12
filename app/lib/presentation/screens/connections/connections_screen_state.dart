import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../domain/models/identity/identity.dart';
import '../../../domain/models/mediator/mediator.dart';
import 'connections_screen_filter.dart';

part 'connections_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class ConnectionsScreenState with _$ConnectionsScreenState {
  ConnectionsScreenState._();

  factory ConnectionsScreenState({
    @Default(false) bool isEditMode,
    @Default([]) List<ConnectionOffer> connections,
    @Default([]) List<ConnectionOffer> selectedConnections,
    @Default({}) Map<String, Mediator> connectionMediators,
    @Default(ConnectionsScreenFilter.all) ConnectionsScreenFilter filter,
    Identity? identity,
  }) = _ConnectionsScreenState;
}
