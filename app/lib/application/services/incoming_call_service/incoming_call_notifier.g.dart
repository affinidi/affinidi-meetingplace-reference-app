// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incoming_call_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service that owns the current [IncomingCallState].

@ProviderFor(IncomingCallNotifier)
const incomingCallProvider = IncomingCallNotifierProvider._();

/// Service that owns the current [IncomingCallState].
final class IncomingCallNotifierProvider
    extends $NotifierProvider<IncomingCallNotifier, IncomingCallState> {
  /// Service that owns the current [IncomingCallState].
  const IncomingCallNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomingCallProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomingCallNotifierHash();

  @$internal
  @override
  IncomingCallNotifier create() => IncomingCallNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IncomingCallState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IncomingCallState>(value),
    );
  }
}

String _$incomingCallNotifierHash() =>
    r'26e05e541314afd1752868b95df898235d707456';

/// Service that owns the current [IncomingCallState].

abstract class _$IncomingCallNotifier extends $Notifier<IncomingCallState> {
  IncomingCallState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<IncomingCallState, IncomingCallState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IncomingCallState, IncomingCallState>,
              IncomingCallState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
