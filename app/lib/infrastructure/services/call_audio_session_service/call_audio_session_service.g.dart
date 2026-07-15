// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_audio_session_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(audioSession)
const audioSessionProvider = AudioSessionProvider._();

final class AudioSessionProvider
    extends
        $FunctionalProvider<
          AsyncValue<AudioSession>,
          AudioSession,
          FutureOr<AudioSession>
        >
    with $FutureModifier<AudioSession>, $FutureProvider<AudioSession> {
  const AudioSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioSessionHash();

  @$internal
  @override
  $FutureProviderElement<AudioSession> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AudioSession> create(Ref ref) {
    return audioSession(ref);
  }
}

String _$audioSessionHash() => r'020b539acfa5dbdeb2f2fc84ceb32a73dd9159a0';

@ProviderFor(CallAudioSessionService)
const callAudioSessionServiceProvider = CallAudioSessionServiceProvider._();

final class CallAudioSessionServiceProvider
    extends $NotifierProvider<CallAudioSessionService, CallAudioSessionState> {
  const CallAudioSessionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'callAudioSessionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$callAudioSessionServiceHash();

  @$internal
  @override
  CallAudioSessionService create() => CallAudioSessionService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CallAudioSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CallAudioSessionState>(value),
    );
  }
}

String _$callAudioSessionServiceHash() =>
    r'0440ffbfaba8fcb1ade2631e137b78290fa4f859';

abstract class _$CallAudioSessionService
    extends $Notifier<CallAudioSessionState> {
  CallAudioSessionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CallAudioSessionState, CallAudioSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CallAudioSessionState, CallAudioSessionState>,
              CallAudioSessionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
