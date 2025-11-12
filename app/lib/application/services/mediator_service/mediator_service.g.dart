// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mediator_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mediatorServiceHash() => r'986c5eef0a06519365e99f5d94f2dbbc215bbabd';

/// Service to manage mediators: loading, adding, renaming, and removing.
///
/// This service provides a centralized interface for mediator operations
/// including fetching default and custom mediators, adding new custom
/// mediators with auto-generated names, renaming existing mediators,
/// removing mediators, resolving mediator DIDs from URLs, and finding
/// mediators by creation time and DID.
///
/// The service maintains state through Riverpod and persists custom
/// mediators using a repository layer with secure storage backing.
///
/// Copied from [MediatorService].
@ProviderFor(MediatorService)
final mediatorServiceProvider =
    NotifierProvider<MediatorService, MediatorServiceState>.internal(
  MediatorService.new,
  name: r'mediatorServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mediatorServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MediatorService = Notifier<MediatorServiceState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
