// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incoming_call_banner_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages intent and state for the incoming call banner.

@ProviderFor(IncomingCallBannerController)
const incomingCallBannerControllerProvider =
    IncomingCallBannerControllerProvider._();

/// Manages intent and state for the incoming call banner.
final class IncomingCallBannerControllerProvider
    extends $NotifierProvider<IncomingCallBannerController, bool> {
  /// Manages intent and state for the incoming call banner.
  const IncomingCallBannerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomingCallBannerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomingCallBannerControllerHash();

  @$internal
  @override
  IncomingCallBannerController create() => IncomingCallBannerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$incomingCallBannerControllerHash() =>
    r'5ecf1a4acf0d078d70de544d9ed2abed9b5dabf5';

/// Manages intent and state for the incoming call banner.

abstract class _$IncomingCallBannerController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
