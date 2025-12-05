// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cameraServiceHash() => r'92371b420d1aa9f806b842a7e3989dcf2f81a064';

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
    AutoDisposeNotifierProvider<CameraService, CameraServiceState>.internal(
  CameraService.new,
  name: r'cameraServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cameraServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CameraService = AutoDisposeNotifier<CameraServiceState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
