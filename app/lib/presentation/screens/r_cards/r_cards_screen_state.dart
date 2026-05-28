import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';

import 'r_cards_screen_filter.dart';

part 'r_cards_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class RCardsScreenState with _$RCardsScreenState {
  RCardsScreenState._();

  factory RCardsScreenState({
    @Default(RCardsScreenFilter.all) RCardsScreenFilter filter,
    @Default([]) List<RCard> cards,
    @Default(false) bool isSearchActive,
    @Default(false) bool hasFilterApplied,
  }) = _RCardsScreenState;
}
