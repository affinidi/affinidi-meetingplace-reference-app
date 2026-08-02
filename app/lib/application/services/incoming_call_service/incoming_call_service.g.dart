// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incoming_call_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IncomingCallService)
const incomingCallServiceProvider = IncomingCallServiceProvider._();

final class IncomingCallServiceProvider
    extends $NotifierProvider<IncomingCallService, void> {
  const IncomingCallServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomingCallServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomingCallServiceHash();

  @$internal
  @override
  IncomingCallService create() => IncomingCallService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$incomingCallServiceHash() =>
    r'deff916955981275ae0555cad638f51c97216114';

abstract class _$IncomingCallService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
