// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship_sdk_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$relationshipSdkHash() => r'4580bd51eca5599a21eecb7bf71dcff6e046dbf7';

/// Provides the `MeetingPlaceRelationshipSDK` instance backed by the
/// `MeetingPlaceCoreSDK` from `meetingPlaceSdkProvider`.
///
/// Injects the [RCardRepository] from [rCardsRepositoryProvider]
/// so that every incoming R-Card is automatically persisted in the local
/// encrypted database.
///
/// Keep-alive ensures the relationship SDK is initialized once and shared
/// across the app lifetime.
///
/// Copied from [relationshipSdk].
@ProviderFor(relationshipSdk)
final relationshipSdkProvider =
    FutureProvider<MeetingPlaceRelationshipSDK>.internal(
      relationshipSdk,
      name: r'relationshipSdkProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$relationshipSdkHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RelationshipSdkRef = FutureProviderRef<MeetingPlaceRelationshipSDK>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
