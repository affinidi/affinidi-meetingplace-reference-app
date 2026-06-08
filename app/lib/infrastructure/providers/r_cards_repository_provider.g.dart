// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r_cards_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the app-wide [RCardRepository] instance.
///
/// The default implementation throws [UnimplementedError]. Override this
/// provider in the root [ProviderScope] with [rCardsRepositoryDrift].

@ProviderFor(rCardsRepository)
final rCardsRepositoryProvider = RCardsRepositoryProvider._();

/// Provides the app-wide [RCardRepository] instance.
///
/// The default implementation throws [UnimplementedError]. Override this
/// provider in the root [ProviderScope] with [rCardsRepositoryDrift].

final class RCardsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<RCardRepository>,
          RCardRepository,
          FutureOr<RCardRepository>
        >
    with $FutureModifier<RCardRepository>, $FutureProvider<RCardRepository> {
  /// Provides the app-wide [RCardRepository] instance.
  ///
  /// The default implementation throws [UnimplementedError]. Override this
  /// provider in the root [ProviderScope] with [rCardsRepositoryDrift].
  RCardsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rCardsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rCardsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<RCardRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RCardRepository> create(Ref ref) {
    return rCardsRepository(ref);
  }
}

String _$rCardsRepositoryHash() => r'0c9f2cd684f9a5d327f0ed8fb7d51078f9a51611';
