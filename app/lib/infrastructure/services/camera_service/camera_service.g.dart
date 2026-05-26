// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A service class for managing camera functionality in the app.
///
/// - Manages camera initialization, switching between front/back lenses,
///   and capturing images.
/// - Observes the app lifecycle to recheck camera availability when resuming.
/// - Maintains camera state via [CameraServiceState].

@ProviderFor(CameraService)
final cameraServiceProvider = CameraServiceProvider._();

/// A service class for managing camera functionality in the app.
///
/// - Manages camera initialization, switching between front/back lenses,
///   and capturing images.
/// - Observes the app lifecycle to recheck camera availability when resuming.
/// - Maintains camera state via [CameraServiceState].
final class CameraServiceProvider
    extends $NotifierProvider<CameraService, CameraServiceState> {
  /// A service class for managing camera functionality in the app.
  ///
  /// - Manages camera initialization, switching between front/back lenses,
  ///   and capturing images.
  /// - Observes the app lifecycle to recheck camera availability when resuming.
  /// - Maintains camera state via [CameraServiceState].
  CameraServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cameraServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cameraServiceHash();

  @$internal
  @override
  CameraService create() => CameraService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CameraServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CameraServiceState>(value),
    );
  }
}

String _$cameraServiceHash() => r'daa9c3fe6186b55ae60f76d425361d26d21a8359';

/// A service class for managing camera functionality in the app.
///
/// - Manages camera initialization, switching between front/back lenses,
///   and capturing images.
/// - Observes the app lifecycle to recheck camera availability when resuming.
/// - Maintains camera state via [CameraServiceState].

abstract class _$CameraService extends $Notifier<CameraServiceState> {
  CameraServiceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CameraServiceState, CameraServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CameraServiceState, CameraServiceState>,
              CameraServiceState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
