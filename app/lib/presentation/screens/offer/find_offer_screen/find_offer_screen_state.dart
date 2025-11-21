import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

part 'find_offer_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class FindOfferScreenState with _$FindOfferScreenState {
  factory FindOfferScreenState({
    Identity? identity,
  }) = _FindOfferScreenState;
}
