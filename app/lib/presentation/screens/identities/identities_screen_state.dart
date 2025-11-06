import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/models/identity/identity.dart';
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
