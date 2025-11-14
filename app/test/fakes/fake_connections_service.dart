import 'dart:async';

import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/application/services/connections_service/connections_service_state.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/offer/publish_offer_screen/publish_offer_form_data.dart';

class FakeConnectionsService {
  FakeConnectionsService({
    ConnectionOffer? offerToFind,
    Exception? findOfferException,
  })  : _offerToFind = offerToFind,
        _findOfferException = findOfferException;

  final ConnectionOffer? _offerToFind;
  final Exception? _findOfferException;

  ConnectionsServiceState _state = ConnectionsServiceState();
  ConnectionsServiceState get state => _state;

  // Track findOffer calls
  final List<String> _findOfferCalls = [];
  List<String> get findOfferCalls => _findOfferCalls;

  final StreamController<Channel> _groupOfferChannelInauguratedController =
      StreamController<Channel>.broadcast();
  Stream<Channel> get onGroupOfferChannelInaugurated =>
      _groupOfferChannelInauguratedController.stream;

  Future<void> ensureInitialized() async {
    // No-op for fake
  }

  Future<void> fetchConnections() async {
    // No-op for fake
  }

  Future<void> markConnectionOfferAsDeleted(
      ConnectionOffer connectionOffer) async {
    // No-op for fake
  }

  Future<void> approveConnectionOffer({
    required String otherPartyPermanentChannelDid,
    required String offerLink,
  }) async {
    // No-op for fake
  }

  Future<void> acceptOffer(
    ConnectionOffer connectionOffer, {
    required Identity identity,
  }) async {
    // No-op for fake
  }

  Future<void> validateOfferPhrase(String phrase) async {
    // No-op for fake
  }

  Future<void> publishOffer(
    PublishOfferFormData data, {
    required Identity identity,
  }) async {
    // No-op for fake
  }

  void clearPublishedOffer() {
    _state = _state.copyWith(publishedOffer: null);
  }

  Future<void> findOffer(String mnemonic) async {
    // Record the call
    _findOfferCalls.add(mnemonic);

    // Check if we should throw an exception
    if (_findOfferException != null) {
      throw _findOfferException;
    }

    // Update state with the found offer
    _state = _state.copyWith(selectedOffer: _offerToFind);
  }

  Future<void> getOffer(String mnemonic) async {
    if (_state.selectedOffer?.mnemonic == mnemonic) {
      return;
    }

    // Update state with the found offer
    _state = _state.copyWith(selectedOffer: _offerToFind);
  }
}
