// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r_cards_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rCardsServiceHash() => r'2731ac5485529e0ce0553a961d887b0d6e8c102e';

/// Service that drives the R-Card feature.
///
/// Responsibilities:
/// - Exposes all stored [ReceivedRCard]s as live state for the UI.
/// - Subscribes to `MeetingPlaceRelationshipSDK.receivedRCards` and persists
///   every verified card via `RCardRepository.upsertFromVdip`.
///
/// Copied from [RCardsService].
@ProviderFor(RCardsService)
final rCardsServiceProvider =
    NotifierProvider<RCardsService, List<ReceivedRCard>>.internal(
      RCardsService.new,
      name: r'rCardsServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$rCardsServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RCardsService = Notifier<List<ReceivedRCard>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
