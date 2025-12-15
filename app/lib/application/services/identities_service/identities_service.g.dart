// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identities_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$identitiesServiceHash() => r'f5853956ccf3e2b2d894ba53a22dbe8d50c1ccc1';

/// Service responsible for managing identities and the current contact card.
///
/// This service provides functionality to:
/// - Load and persist identities via a repository
/// - Add, update and delete identities
/// - Resolve and manage the currently selected identity
/// - Expose the current contact card derived from the selected identity
///
/// The service initializes by loading identities and keeps the current identity
/// in sync with environment defaults and repository state.
///
/// Copied from [IdentitiesService].
@ProviderFor(IdentitiesService)
final identitiesServiceProvider =
    NotifierProvider<IdentitiesService, IdentitiesServiceState>.internal(
  IdentitiesService.new,
  name: r'identitiesServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$identitiesServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$IdentitiesService = Notifier<IdentitiesServiceState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
