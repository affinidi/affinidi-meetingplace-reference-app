// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_playback_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VoicePlaybackService)
const voicePlaybackServiceProvider = VoicePlaybackServiceFamily._();

final class VoicePlaybackServiceProvider
    extends $NotifierProvider<VoicePlaybackService, VoicePlaybackState> {
  const VoicePlaybackServiceProvider._({
    required VoicePlaybackServiceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'voicePlaybackServiceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$voicePlaybackServiceHash();

  @override
  String toString() {
    return r'voicePlaybackServiceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VoicePlaybackService create() => VoicePlaybackService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoicePlaybackState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoicePlaybackState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VoicePlaybackServiceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$voicePlaybackServiceHash() =>
    r'8f3c2a1b9d4e5f60718293a4b5c6d7e8f9a0b1c2';

final class VoicePlaybackServiceFamily extends $Family
    with
        $ClassFamilyOverride<
          VoicePlaybackService,
          VoicePlaybackState,
          VoicePlaybackState,
          VoicePlaybackState,
          String
        > {
  const VoicePlaybackServiceFamily._()
    : super(
        retry: null,
        name: r'voicePlaybackServiceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VoicePlaybackServiceProvider call(String contactId) =>
      VoicePlaybackServiceProvider._(argument: contactId, from: this);

  @override
  String toString() => r'voicePlaybackServiceProvider';
}

abstract class _$VoicePlaybackService extends $Notifier<VoicePlaybackState> {
  late final _$args = ref.$arg as String;
  String get contactId => _$args;

  VoicePlaybackState build(String contactId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<VoicePlaybackState, VoicePlaybackState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VoicePlaybackState, VoicePlaybackState>,
              VoicePlaybackState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
