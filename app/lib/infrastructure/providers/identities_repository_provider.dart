import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/repositories/identities_repository.dart';

part 'identities_repository_provider.g.dart';

@Riverpod(keepAlive: true)
Future<IdentitiesRepository> identitiesRepository(Ref ref) async {
  throw UnimplementedError(
    '''Please configure the application by providing an IdentitiesRepository implementation in ProviderScope overrides.''',
  );
}
