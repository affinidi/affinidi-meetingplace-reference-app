// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vtc_sign_in_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives one sign-in to a community's portal or console, from the scanned
/// code to the member's approval.
///
/// A claimed sign-in that is left before it is approved is cancelled, unless
/// the grant may already have been sent. Nothing is logged.

@ProviderFor(VtcSignInController)
const vtcSignInControllerProvider = VtcSignInControllerProvider._();

/// Drives one sign-in to a community's portal or console, from the scanned
/// code to the member's approval.
///
/// A claimed sign-in that is left before it is approved is cancelled, unless
/// the grant may already have been sent. Nothing is logged.
final class VtcSignInControllerProvider
    extends $NotifierProvider<VtcSignInController, VtcSignInState> {
  /// Drives one sign-in to a community's portal or console, from the scanned
  /// code to the member's approval.
  ///
  /// A claimed sign-in that is left before it is approved is cancelled, unless
  /// the grant may already have been sent. Nothing is logged.
  const VtcSignInControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vtcSignInControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vtcSignInControllerHash();

  @$internal
  @override
  VtcSignInController create() => VtcSignInController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VtcSignInState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VtcSignInState>(value),
    );
  }
}

String _$vtcSignInControllerHash() =>
    r'45d8d90ef89c2dc64acb8e18f597c34db056ff58';

/// Drives one sign-in to a community's portal or console, from the scanned
/// code to the member's approval.
///
/// A claimed sign-in that is left before it is approved is cancelled, unless
/// the grant may already have been sent. Nothing is logged.

abstract class _$VtcSignInController extends $Notifier<VtcSignInState> {
  VtcSignInState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<VtcSignInState, VtcSignInState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VtcSignInState, VtcSignInState>,
              VtcSignInState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
