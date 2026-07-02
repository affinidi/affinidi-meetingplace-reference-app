// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_ended_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CallEndedController)
const callEndedControllerProvider = CallEndedControllerProvider._();

final class CallEndedControllerProvider
    extends $NotifierProvider<CallEndedController, CallEndedState?> {
  const CallEndedControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'callEndedControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$callEndedControllerHash();

  @$internal
  @override
  CallEndedController create() => CallEndedController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CallEndedState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CallEndedState?>(value),
    );
  }
}

String _$callEndedControllerHash() =>
    r'2a81655061c1068ba920845017ab86578e30ab96';

abstract class _$CallEndedController extends $Notifier<CallEndedState?> {
  CallEndedState? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CallEndedState?, CallEndedState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CallEndedState?, CallEndedState?>,
              CallEndedState?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
