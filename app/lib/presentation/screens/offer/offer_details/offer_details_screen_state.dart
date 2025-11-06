import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart'
    show ConnectionOffer;

import '../../../../domain/models/identity/identity.dart';

part 'offer_details_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class OfferDetailsScreenState with _$OfferDetailsScreenState {
  factory OfferDetailsScreenState({
    ConnectionOffer? offer,
    Identity? publisherIdentity,
    String? groupDid,
    @Default(false) bool isUsingPrimaryIdentity,
    @Default(false) bool isDebugMode,
    @Default(false) bool showQrIcon,
    @Default(false) bool showQrView,
  }) = _OfferDetailsScreenState;
}
