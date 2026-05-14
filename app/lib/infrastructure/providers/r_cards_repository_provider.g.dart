// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r_cards_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rCardsRepositoryHash() => r'5a1e968436979a4586046b1c2c35de078cc90bfb';

/// Provides the app-wide [ReceivedRCardRepository] instance.
///
/// The default implementation throws [UnimplementedError]. Override this
/// provider in the root [ProviderScope] with [rCardsRepositoryDrift].
///
/// Copied from [rCardsRepository].
@ProviderFor(rCardsRepository)
final rCardsRepositoryProvider =
    FutureProvider<ReceivedRCardRepository>.internal(
      rCardsRepository,
      name: r'rCardsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$rCardsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RCardsRepositoryRef = FutureProviderRef<ReceivedRCardRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
