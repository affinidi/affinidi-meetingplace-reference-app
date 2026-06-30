// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_call_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveCallController)
const activeCallControllerProvider = ActiveCallControllerProvider._();

final class ActiveCallControllerProvider
    extends $NotifierProvider<ActiveCallController, ActiveCallState?> {
  const ActiveCallControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeCallControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeCallControllerHash();

  @$internal
  @override
  ActiveCallController create() => ActiveCallController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActiveCallState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActiveCallState?>(value),
    );
  }
}

String _$activeCallControllerHash() =>
    r'ef312373b215bad0d230735dfe69ed101cea6726';

abstract class _$ActiveCallController extends $Notifier<ActiveCallState?> {
  ActiveCallState? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ActiveCallState?, ActiveCallState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ActiveCallState?, ActiveCallState?>,
              ActiveCallState?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
