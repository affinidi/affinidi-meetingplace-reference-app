// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oob_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$oOBServiceHash() => r'a198ef4278048ddf16ba563db739b29f2650e128';

/// Service responsible for creating and accepting out-of-band (OOB) flows.
///
/// This service provides functionality to:
/// - Create an OOB offer that can be shared (e.g., via QR) to initiate a
///  connection.
/// - Accept an incoming OOB offer URL and complete the connection flow.
/// - Observe control plane events to finalize connections and update state.
/// - Expose the last established channel and the current OOB offer in state.
///
/// Copied from [OOBService].
@ProviderFor(OOBService)
final oOBServiceProvider =
    AutoDisposeNotifierProvider<OOBService, OOBServiceState>.internal(
  OOBService.new,
  name: r'oOBServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$oOBServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OOBService = AutoDisposeNotifier<OOBServiceState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
