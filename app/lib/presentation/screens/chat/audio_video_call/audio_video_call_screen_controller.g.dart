// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_video_call_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AudioVideoCallScreenController)
const audioVideoCallScreenControllerProvider =
    AudioVideoCallScreenControllerFamily._();

final class AudioVideoCallScreenControllerProvider
    extends
        $NotifierProvider<
          AudioVideoCallScreenController,
          AudioVideoCallScreenState
        > {
  const AudioVideoCallScreenControllerProvider._({
    required AudioVideoCallScreenControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'audioVideoCallScreenControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$audioVideoCallScreenControllerHash();

  @override
  String toString() {
    return r'audioVideoCallScreenControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AudioVideoCallScreenController create() => AudioVideoCallScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioVideoCallScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioVideoCallScreenState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AudioVideoCallScreenControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$audioVideoCallScreenControllerHash() =>
    r'25e65462dcf6fd10e802bc7391220d5c724d0a4b';

final class AudioVideoCallScreenControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          AudioVideoCallScreenController,
          AudioVideoCallScreenState,
          AudioVideoCallScreenState,
          AudioVideoCallScreenState,
          String
        > {
  const AudioVideoCallScreenControllerFamily._()
    : super(
        retry: null,
        name: r'audioVideoCallScreenControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AudioVideoCallScreenControllerProvider call(String contactId) =>
      AudioVideoCallScreenControllerProvider._(argument: contactId, from: this);

  @override
  String toString() => r'audioVideoCallScreenControllerProvider';
}

abstract class _$AudioVideoCallScreenController
    extends $Notifier<AudioVideoCallScreenState> {
  late final _$args = ref.$arg as String;
  String get contactId => _$args;

  AudioVideoCallScreenState build(String contactId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AudioVideoCallScreenState, AudioVideoCallScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AudioVideoCallScreenState, AudioVideoCallScreenState>,
              AudioVideoCallScreenState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
