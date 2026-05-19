// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vrc_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vrcServiceHash() => r'c97796770d277dbcf29533ede40a7c06c4200f1d';

/// Service that manages Verifiable Relationship Credentials (VRC).
///
/// Responsibilities:
/// - Exposes all stored [VrcCredential]s as live state for the UI.
/// - Provides methods to save, delete, and query VRCs.
///
/// Copied from [VrcService].
@ProviderFor(VrcService)
final vrcServiceProvider =
    NotifierProvider<VrcService, List<VrcCredential>>.internal(
      VrcService.new,
      name: r'vrcServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$vrcServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VrcService = Notifier<List<VrcCredential>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
