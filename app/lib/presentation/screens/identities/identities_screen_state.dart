import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart'
    show $IdentityCopyWith, Identity;
import 'identities_screen_filter.dart';

part 'identities_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class IdentitiesScreenState with _$IdentitiesScreenState {
  IdentitiesScreenState._();

  factory IdentitiesScreenState({
    @Default(false) bool shouldShowFilter,
    @Default(IdentitiesScreenFilter.all) IdentitiesScreenFilter filter,
    Identity? currentIdentity,
    @Default([]) List<Identity> identities,
    @Default(false) bool shouldSetupPrimaryIdentity,
  }) = _IdentitiesScreenState;
}
