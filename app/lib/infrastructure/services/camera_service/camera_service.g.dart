// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cameraServiceHash() => r'9f07aaf0729c13960a19481b38a13dc173fac7ca';

/// A service class for managing camera functionality in the app.
///
/// - Manages camera initialization, switching between front/back lenses,
///   and capturing images.
/// - Observes the app lifecycle to recheck camera availability when resuming.
/// - Maintains camera state via [CameraServiceState].
///
/// Copied from [CameraService].
@ProviderFor(CameraService)
final cameraServiceProvider =
    NotifierProvider<CameraService, CameraServiceState>.internal(
      CameraService.new,
      name: r'cameraServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cameraServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CameraService = Notifier<CameraServiceState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
