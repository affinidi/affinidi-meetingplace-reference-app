// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_call_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoCallScreenControllerHash() =>
    r'd1851a459ff767900f32150004c00fd279cd5ab3';

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

abstract class _$VideoCallScreenController
    extends BuildlessAutoDisposeNotifier<VideoCallScreenState> {
  late final String roomId;
  late final String contactId;

  VideoCallScreenState build(String roomId, String contactId);
}

/// See also [VideoCallScreenController].
@ProviderFor(VideoCallScreenController)
const videoCallScreenControllerProvider = VideoCallScreenControllerFamily();

/// See also [VideoCallScreenController].
class VideoCallScreenControllerFamily extends Family<VideoCallScreenState> {
  /// See also [VideoCallScreenController].
  const VideoCallScreenControllerFamily();

  /// See also [VideoCallScreenController].
  VideoCallScreenControllerProvider call(String roomId, String contactId) {
    return VideoCallScreenControllerProvider(roomId, contactId);
  }

  @override
  VideoCallScreenControllerProvider getProviderOverride(
    covariant VideoCallScreenControllerProvider provider,
  ) {
    return call(provider.roomId, provider.contactId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'videoCallScreenControllerProvider';
}

/// See also [VideoCallScreenController].
class VideoCallScreenControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          VideoCallScreenController,
          VideoCallScreenState
        > {
  /// See also [VideoCallScreenController].
  VideoCallScreenControllerProvider(String roomId, String contactId)
    : this._internal(
        () => VideoCallScreenController()
          ..roomId = roomId
          ..contactId = contactId,
        from: videoCallScreenControllerProvider,
        name: r'videoCallScreenControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$videoCallScreenControllerHash,
        dependencies: VideoCallScreenControllerFamily._dependencies,
        allTransitiveDependencies:
            VideoCallScreenControllerFamily._allTransitiveDependencies,
        roomId: roomId,
        contactId: contactId,
      );

  VideoCallScreenControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomId,
    required this.contactId,
  }) : super.internal();

  final String roomId;
  final String contactId;

  @override
  VideoCallScreenState runNotifierBuild(
    covariant VideoCallScreenController notifier,
  ) {
    return notifier.build(roomId, contactId);
  }

  @override
  Override overrideWith(VideoCallScreenController Function() create) {
    return ProviderOverride(
      origin: this,
      override: VideoCallScreenControllerProvider._internal(
        () => create()
          ..roomId = roomId
          ..contactId = contactId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roomId: roomId,
        contactId: contactId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    VideoCallScreenController,
    VideoCallScreenState
  >
  createElement() {
    return _VideoCallScreenControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoCallScreenControllerProvider &&
        other.roomId == roomId &&
        other.contactId == contactId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VideoCallScreenControllerRef
    on AutoDisposeNotifierProviderRef<VideoCallScreenState> {
  /// The parameter `roomId` of this provider.
  String get roomId;

  /// The parameter `contactId` of this provider.
  String get contactId;
}

class _VideoCallScreenControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          VideoCallScreenController,
          VideoCallScreenState
        >
    with VideoCallScreenControllerRef {
  _VideoCallScreenControllerProviderElement(super.provider);

  @override
  String get roomId => (origin as VideoCallScreenControllerProvider).roomId;
  @override
  String get contactId =>
      (origin as VideoCallScreenControllerProvider).contactId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
