// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship_sdk_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the `MeetingPlaceRelationshipSDK` instance backed by the
/// `MeetingPlaceCoreSDK` from `meetingPlaceSdkProvider`.
///
/// Injects the [RCardRepository] from [rCardsRepositoryProvider]
/// so that every incoming R-Card is automatically persisted in the local
/// encrypted database.
///
/// Keep-alive ensures the relationship SDK is initialized once and shared
/// across the app lifetime.

@ProviderFor(relationshipSdk)
final relationshipSdkProvider = RelationshipSdkProvider._();

/// Provides the `MeetingPlaceRelationshipSDK` instance backed by the
/// `MeetingPlaceCoreSDK` from `meetingPlaceSdkProvider`.
///
/// Injects the [RCardRepository] from [rCardsRepositoryProvider]
/// so that every incoming R-Card is automatically persisted in the local
/// encrypted database.
///
/// Keep-alive ensures the relationship SDK is initialized once and shared
/// across the app lifetime.

final class RelationshipSdkProvider
    extends
        $FunctionalProvider<
          AsyncValue<MeetingPlaceRelationshipSDK>,
          MeetingPlaceRelationshipSDK,
          FutureOr<MeetingPlaceRelationshipSDK>
        >
    with
        $FutureModifier<MeetingPlaceRelationshipSDK>,
        $FutureProvider<MeetingPlaceRelationshipSDK> {
  /// Provides the `MeetingPlaceRelationshipSDK` instance backed by the
  /// `MeetingPlaceCoreSDK` from `meetingPlaceSdkProvider`.
  ///
  /// Injects the [RCardRepository] from [rCardsRepositoryProvider]
  /// so that every incoming R-Card is automatically persisted in the local
  /// encrypted database.
  ///
  /// Keep-alive ensures the relationship SDK is initialized once and shared
  /// across the app lifetime.
  RelationshipSdkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'relationshipSdkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$relationshipSdkHash();

  @$internal
  @override
  $FutureProviderElement<MeetingPlaceRelationshipSDK> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MeetingPlaceRelationshipSDK> create(Ref ref) {
    return relationshipSdk(ref);
  }
}

String _$relationshipSdkHash() => r'58aed20a8830106186da02ab0f789c3ef2d44dbb';
