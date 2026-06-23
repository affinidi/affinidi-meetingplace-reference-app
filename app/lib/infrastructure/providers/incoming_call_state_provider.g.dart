// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incoming_call_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the current pending incoming call, or `null` when no call is ringing.
///
/// Written by `AppController` when a new `IncomingAudioVideoCallEvent` arrives.
/// Read by `App` to render the `IncomingCallBanner` on any screen.
/// Cleared when the user accepts or declines via the banner.

@ProviderFor(IncomingCallState)
const incomingCallStateProvider = IncomingCallStateProvider._();

/// Holds the current pending incoming call, or `null` when no call is ringing.
///
/// Written by `AppController` when a new `IncomingAudioVideoCallEvent` arrives.
/// Read by `App` to render the `IncomingCallBanner` on any screen.
/// Cleared when the user accepts or declines via the banner.
final class IncomingCallStateProvider
    extends $NotifierProvider<IncomingCallState, IncomingAudioVideoCallEvent?> {
  /// Holds the current pending incoming call, or `null` when no call is ringing.
  ///
  /// Written by `AppController` when a new `IncomingAudioVideoCallEvent` arrives.
  /// Read by `App` to render the `IncomingCallBanner` on any screen.
  /// Cleared when the user accepts or declines via the banner.
  const IncomingCallStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomingCallStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomingCallStateHash();

  @$internal
  @override
  IncomingCallState create() => IncomingCallState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IncomingAudioVideoCallEvent? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IncomingAudioVideoCallEvent?>(value),
    );
  }
}

String _$incomingCallStateHash() => r'2aa63d9afda59a34e29b6d313aa98672ed1ffabb';

/// Holds the current pending incoming call, or `null` when no call is ringing.
///
/// Written by `AppController` when a new `IncomingAudioVideoCallEvent` arrives.
/// Read by `App` to render the `IncomingCallBanner` on any screen.
/// Cleared when the user accepts or declines via the banner.

abstract class _$IncomingCallState
    extends $Notifier<IncomingAudioVideoCallEvent?> {
  IncomingAudioVideoCallEvent? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<IncomingAudioVideoCallEvent?, IncomingAudioVideoCallEvent?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                IncomingAudioVideoCallEvent?,
                IncomingAudioVideoCallEvent?
              >,
              IncomingAudioVideoCallEvent?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
