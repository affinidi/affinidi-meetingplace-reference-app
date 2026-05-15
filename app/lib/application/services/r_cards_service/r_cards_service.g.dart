// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r_cards_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rCardsServiceHash() => r'f98d88ed10cd443db04e59697e7ff330dbad71df';

/// Service that drives the R-Card feature.
///
/// Responsibilities:
/// - Exposes all stored [RCard]s as live state for the UI.
/// - Delegates all persistence operations to [MeetingPlaceRelationshipSDK]
///   so consumers only need one dependency for the full R-Card feature.
///
/// Copied from [RCardsService].
@ProviderFor(RCardsService)
final rCardsServiceProvider =
    NotifierProvider<RCardsService, List<RCard>>.internal(
      RCardsService.new,
      name: r'rCardsServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$rCardsServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RCardsService = Notifier<List<RCard>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
