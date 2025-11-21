import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

part 'accept_offer_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class AcceptOfferScreenState with _$AcceptOfferScreenState {
  factory AcceptOfferScreenState({
    ConnectionOffer? offer,
    String? error,
    Identity? selectedIdentity,
    @Default([]) List<Identity> identities,
  }) = _AcceptOfferScreenState;
}
