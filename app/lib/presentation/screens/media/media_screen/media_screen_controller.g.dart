// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MediaScreenController)
final mediaScreenControllerProvider = MediaScreenControllerFamily._();

final class MediaScreenControllerProvider
    extends $NotifierProvider<MediaScreenController, MediaScreenState> {
  MediaScreenControllerProvider._({
    required MediaScreenControllerFamily super.from,
    required ({
      CameraLensDirection cameraLensDirection,
      bool useCamera,
      bool useChatSemantics,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'mediaScreenControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mediaScreenControllerHash();

  @override
  String toString() {
    return r'mediaScreenControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MediaScreenController create() => MediaScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaScreenState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MediaScreenControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mediaScreenControllerHash() =>
    r'fccd69cc35d25a4ede82aff613ae145793ac5f77';

final class MediaScreenControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MediaScreenController,
          MediaScreenState,
          MediaScreenState,
          MediaScreenState,
          ({
            CameraLensDirection cameraLensDirection,
            bool useCamera,
            bool useChatSemantics,
          })
        > {
  MediaScreenControllerFamily._()
    : super(
        retry: null,
        name: r'mediaScreenControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MediaScreenControllerProvider call({
    required CameraLensDirection cameraLensDirection,
    required bool useCamera,
    required bool useChatSemantics,
  }) => MediaScreenControllerProvider._(
    argument: (
      cameraLensDirection: cameraLensDirection,
      useCamera: useCamera,
      useChatSemantics: useChatSemantics,
    ),
    from: this,
  );

  @override
  String toString() => r'mediaScreenControllerProvider';
}

abstract class _$MediaScreenController extends $Notifier<MediaScreenState> {
  late final _$args =
      ref.$arg
          as ({
            CameraLensDirection cameraLensDirection,
            bool useCamera,
            bool useChatSemantics,
          });
  CameraLensDirection get cameraLensDirection => _$args.cameraLensDirection;
  bool get useCamera => _$args.useCamera;
  bool get useChatSemantics => _$args.useChatSemantics;

  MediaScreenState build({
    required CameraLensDirection cameraLensDirection,
    required bool useCamera,
    required bool useChatSemantics,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MediaScreenState, MediaScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MediaScreenState, MediaScreenState>,
              MediaScreenState,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () => build(
        cameraLensDirection: _$args.cameraLensDirection,
        useCamera: _$args.useCamera,
        useChatSemantics: _$args.useChatSemantics,
      ),
    );
  }
}
