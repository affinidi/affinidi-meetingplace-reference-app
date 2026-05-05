import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/r_card_repository.dart';

part 'r_cards_repository_provider.g.dart';

/// Provides the app-wide [RCardRepository] instance.
///
/// The default implementation throws [UnimplementedError]. Override this
/// provider in the root [ProviderScope] with a concrete implementation
/// such as `rCardsRepositoryDrift`.
@Riverpod(keepAlive: true)
Future<RCardRepository> rCardsRepository(Ref ref) async {
  throw UnimplementedError(
    '''Please configure the application by providing an RCardRepository '''
    '''implementation in ProviderScope overrides.''',
  );
}
