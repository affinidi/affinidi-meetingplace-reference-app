// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authenticationServiceHash() =>
    r'2346147e3fea23c050827b219fffd8cc117e7592';

/// Service responsible for managing authentication state and biometric flows.
///
/// This service provides functionality to:
/// - Trigger biometric authentication
///
/// It relies on the platform-specific local_auth provider for biometric
/// operations and the environment provider to determine whether biometric
/// checks are enabled.
///
/// Copied from [AuthenticationService].
@ProviderFor(AuthenticationService)
final authenticationServiceProvider =
    NotifierProvider<AuthenticationService, AuthenticationState>.internal(
  AuthenticationService.new,
  name: r'authenticationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authenticationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthenticationService = Notifier<AuthenticationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
