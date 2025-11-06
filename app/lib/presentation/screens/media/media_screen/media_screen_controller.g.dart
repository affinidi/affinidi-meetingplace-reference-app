// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mediaScreenControllerHash() =>
    r'baae82cae3ebf315cd56456164aefb94c338ecf0';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$MediaScreenController
    extends BuildlessAutoDisposeNotifier<MediaScreenState> {
  late final CameraLensDirection cameraLensDirection;
  late final bool useCamera;

  MediaScreenState build({
    required CameraLensDirection cameraLensDirection,
    required bool useCamera,
  });
}

/// See also [MediaScreenController].
@ProviderFor(MediaScreenController)
const mediaScreenControllerProvider = MediaScreenControllerFamily();

/// See also [MediaScreenController].
class MediaScreenControllerFamily extends Family<MediaScreenState> {
  /// See also [MediaScreenController].
  const MediaScreenControllerFamily();

  /// See also [MediaScreenController].
  MediaScreenControllerProvider call({
    required CameraLensDirection cameraLensDirection,
    required bool useCamera,
  }) {
    return MediaScreenControllerProvider(
      cameraLensDirection: cameraLensDirection,
      useCamera: useCamera,
    );
  }

  @override
  MediaScreenControllerProvider getProviderOverride(
    covariant MediaScreenControllerProvider provider,
  ) {
    return call(
      cameraLensDirection: provider.cameraLensDirection,
      useCamera: provider.useCamera,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mediaScreenControllerProvider';
}

/// See also [MediaScreenController].
class MediaScreenControllerProvider extends AutoDisposeNotifierProviderImpl<
    MediaScreenController, MediaScreenState> {
  /// See also [MediaScreenController].
  MediaScreenControllerProvider({
    required CameraLensDirection cameraLensDirection,
    required bool useCamera,
  }) : this._internal(
          () => MediaScreenController()
            ..cameraLensDirection = cameraLensDirection
            ..useCamera = useCamera,
          from: mediaScreenControllerProvider,
          name: r'mediaScreenControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mediaScreenControllerHash,
          dependencies: MediaScreenControllerFamily._dependencies,
          allTransitiveDependencies:
              MediaScreenControllerFamily._allTransitiveDependencies,
          cameraLensDirection: cameraLensDirection,
          useCamera: useCamera,
        );

  MediaScreenControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.cameraLensDirection,
    required this.useCamera,
  }) : super.internal();

  final CameraLensDirection cameraLensDirection;
  final bool useCamera;

  @override
  MediaScreenState runNotifierBuild(
    covariant MediaScreenController notifier,
  ) {
    return notifier.build(
      cameraLensDirection: cameraLensDirection,
      useCamera: useCamera,
    );
  }

  @override
  Override overrideWith(MediaScreenController Function() create) {
    return ProviderOverride(
      origin: this,
      override: MediaScreenControllerProvider._internal(
        () => create()
          ..cameraLensDirection = cameraLensDirection
          ..useCamera = useCamera,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        cameraLensDirection: cameraLensDirection,
        useCamera: useCamera,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<MediaScreenController, MediaScreenState>
      createElement() {
    return _MediaScreenControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MediaScreenControllerProvider &&
        other.cameraLensDirection == cameraLensDirection &&
        other.useCamera == useCamera;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, cameraLensDirection.hashCode);
    hash = _SystemHash.combine(hash, useCamera.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MediaScreenControllerRef
    on AutoDisposeNotifierProviderRef<MediaScreenState> {
  /// The parameter `cameraLensDirection` of this provider.
  CameraLensDirection get cameraLensDirection;

  /// The parameter `useCamera` of this provider.
  bool get useCamera;
}

class _MediaScreenControllerProviderElement
    extends AutoDisposeNotifierProviderElement<MediaScreenController,
        MediaScreenState> with MediaScreenControllerRef {
  _MediaScreenControllerProviderElement(super.provider);

  @override
  CameraLensDirection get cameraLensDirection =>
      (origin as MediaScreenControllerProvider).cameraLensDirection;
  @override
  bool get useCamera => (origin as MediaScreenControllerProvider).useCamera;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
