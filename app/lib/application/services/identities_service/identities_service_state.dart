import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart'
    show $IdentityCopyWith, Identity;

part 'identities_service_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class IdentitiesServiceState with _$IdentitiesServiceState {
  IdentitiesServiceState._();

  factory IdentitiesServiceState({
    Identity? currentIdentity,
    @Default([]) List<Identity> identities,
    String? errorMessage,
  }) = _IdentitiesServiceState;

  Identity? getIdentityById(String? identityId) =>
      identities.firstWhereOrNull((identity) => identity.id == identityId);
}
