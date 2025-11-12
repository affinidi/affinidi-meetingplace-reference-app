import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

part 'connections_service_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class ConnectionsServiceState with _$ConnectionsServiceState {
  ConnectionsServiceState._();

  factory ConnectionsServiceState({
    @Default([]) List<ConnectionOffer> connections,
    ConnectionOffer? selectedOffer,
    ConnectionOffer? publishedOffer,
    bool? isCustomPhraseAvailable,
  }) = _ConnectionsServiceState;

  ConnectionOffer? getConnectionByOfferLink(String offerLink) =>
      connections.firstWhereOrNull((c) => c.offerLink == offerLink);
}
