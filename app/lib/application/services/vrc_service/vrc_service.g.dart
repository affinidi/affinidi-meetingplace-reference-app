// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vrc_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vrcServiceHash() => r'1a968c5d075a043a58506cc804da93df6b4fa8bf';

/// Service that manages Verifiable Relationship Credentials (VRC).
///
/// Responsibilities:
/// - Exposes all stored [VrcCredential]s as live state for the UI.
/// - Provides methods to save, delete, and query VRCs.
/// - Emits [VrcEvent]s on a broadcast stream for interested listeners.
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
