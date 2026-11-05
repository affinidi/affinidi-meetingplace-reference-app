// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_credentials_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The member's membership cards, and whether each one's community still
/// holds it. Only a failure's code is logged; never a DID or a card.

@ProviderFor(MembershipCredentialsController)
const membershipCredentialsControllerProvider =
    MembershipCredentialsControllerProvider._();

/// The member's membership cards, and whether each one's community still
/// holds it. Only a failure's code is logged; never a DID or a card.
final class MembershipCredentialsControllerProvider
    extends
        $NotifierProvider<
          MembershipCredentialsController,
          MembershipCredentialsState
        > {
  /// The member's membership cards, and whether each one's community still
  /// holds it. Only a failure's code is logged; never a DID or a card.
  const MembershipCredentialsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membershipCredentialsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membershipCredentialsControllerHash();

  @$internal
  @override
  MembershipCredentialsController create() => MembershipCredentialsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MembershipCredentialsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MembershipCredentialsState>(value),
    );
  }
}

String _$membershipCredentialsControllerHash() =>
    r'3a13aa3d4b6e472aa0b1f7e3438e8baeb1c4465c';

/// The member's membership cards, and whether each one's community still
/// holds it. Only a failure's code is logged; never a DID or a card.

abstract class _$MembershipCredentialsController
    extends $Notifier<MembershipCredentialsState> {
  MembershipCredentialsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<MembershipCredentialsState, MembershipCredentialsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                MembershipCredentialsState,
                MembershipCredentialsState
              >,
              MembershipCredentialsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
