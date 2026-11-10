import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/models/identity/identity.dart';

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

  Identity? getIdentityByDid(String? identityDid) =>
      identities.firstWhereOrNull((i) => i.did == identityDid);

  /// The identities that are personas of the member's VTA, primary first.
  List<Identity> get vtaPersonas {
    final personas = identities.where((identity) => identity.isVtaPersona);
    return [
      ...personas.where((identity) => identity.isPrimary),
      ...personas.where((identity) => !identity.isPrimary),
    ];
  }

  /// The identity on the member's VTA in [contextId], or null when none is.
  /// A community knows the identity under a DID of its own in that context,
  /// so the context, not the DID, tells which identity joined it.
  Identity? vtaPersonaIn(String? contextId) => vtaPersonas.firstWhereOrNull(
    (identity) => identity.vtaContextId == contextId,
  );
}
