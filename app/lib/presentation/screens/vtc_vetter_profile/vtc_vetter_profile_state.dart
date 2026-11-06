import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/models/vtc/vtc_vetter_desk.dart';

part 'vtc_vetter_profile_state.freezed.dart';

/// Where the member's vetter profile for a community stands.
enum VtcVetterProfileStep {
  /// Reading the profile last published and whether the member may vet.
  loading,

  /// The member holds no vetter role card for the community that is in
  /// date and not revoked.
  notVetter,

  /// The member edits the profile.
  editing,
}

/// Why the profile could not be published.
enum VtcVetterProfileFailure {
  /// The member's VTA or the community could not be reached.
  unreachable,

  /// The community would refuse the profile as written.
  invalid,
}

/// The member's vetter profile for one community, as the screen shows it.
@freezed
abstract class VtcVetterProfileState with _$VtcVetterProfileState {
  factory VtcVetterProfileState({
    @Default(VtcVetterProfileStep.loading) VtcVetterProfileStep step,

    /// The profile last published, as the community answered.
    VtcVetterProfileRecord? recorded,

    /// Whether the profile is being published.
    @Default(false) bool busy,

    VtcVetterProfileFailure? failure,

    /// What the community would refuse, when [failure] is
    /// [VtcVetterProfileFailure.invalid].
    String? invalidReason,
  }) = _VtcVetterProfileState;
}
