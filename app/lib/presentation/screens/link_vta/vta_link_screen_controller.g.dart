// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vta_link_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives a view of the VTA link, on the link screen or in the settings:
/// turns the member's taps into link actions and their outcome into what the
/// view shows. Logs the type of a failure only; never a DID or key.

@ProviderFor(VtaLinkScreenController)
const vtaLinkScreenControllerProvider = VtaLinkScreenControllerProvider._();

/// Drives a view of the VTA link, on the link screen or in the settings:
/// turns the member's taps into link actions and their outcome into what the
/// view shows. Logs the type of a failure only; never a DID or key.
final class VtaLinkScreenControllerProvider
    extends $NotifierProvider<VtaLinkScreenController, VtaLinkScreenState> {
  /// Drives a view of the VTA link, on the link screen or in the settings:
  /// turns the member's taps into link actions and their outcome into what the
  /// view shows. Logs the type of a failure only; never a DID or key.
  const VtaLinkScreenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vtaLinkScreenControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vtaLinkScreenControllerHash();

  @$internal
  @override
  VtaLinkScreenController create() => VtaLinkScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VtaLinkScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VtaLinkScreenState>(value),
    );
  }
}

String _$vtaLinkScreenControllerHash() =>
    r'1f1c7b8988021b87ccdc64f233113bbcf1e7156e';

/// Drives a view of the VTA link, on the link screen or in the settings:
/// turns the member's taps into link actions and their outcome into what the
/// view shows. Logs the type of a failure only; never a DID or key.

abstract class _$VtaLinkScreenController extends $Notifier<VtaLinkScreenState> {
  VtaLinkScreenState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<VtaLinkScreenState, VtaLinkScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VtaLinkScreenState, VtaLinkScreenState>,
              VtaLinkScreenState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
