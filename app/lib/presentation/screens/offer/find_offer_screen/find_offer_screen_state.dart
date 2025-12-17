import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../domain/models/identity/identity.dart';

part 'find_offer_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class FindOfferScreenState with _$FindOfferScreenState {
  factory FindOfferScreenState({
    @Default([]) List<Identity> identities,
    Identity? selectedIdentity,
  }) = _FindOfferScreenState;
}
