// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$permissionServiceHash() => r'19b92322798ea7fd375e96ef01c7cc2626892ad5';

/// A service for checking and requesting permissions.
/// This abstraction allows for easier testing by providing a mockable interface.
///
/// Copied from [permissionService].
@ProviderFor(permissionService)
final permissionServiceProvider =
    AutoDisposeProvider<PermissionService>.internal(
  permissionService,
  name: r'permissionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$permissionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PermissionServiceRef = AutoDisposeProviderRef<PermissionService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
