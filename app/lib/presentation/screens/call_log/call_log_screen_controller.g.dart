// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_log_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CallLogScreenController)
const callLogScreenControllerProvider = CallLogScreenControllerProvider._();

final class CallLogScreenControllerProvider
    extends $NotifierProvider<CallLogScreenController, CallLogScreenState> {
  const CallLogScreenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'callLogScreenControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$callLogScreenControllerHash();

  @$internal
  @override
  CallLogScreenController create() => CallLogScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CallLogScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CallLogScreenState>(value),
    );
  }
}

String _$callLogScreenControllerHash() =>
    r'b3ce442f2d6d1b2c431b6c84f204780406d2d214';

abstract class _$CallLogScreenController extends $Notifier<CallLogScreenState> {
  CallLogScreenState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CallLogScreenState, CallLogScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CallLogScreenState, CallLogScreenState>,
              CallLogScreenState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
