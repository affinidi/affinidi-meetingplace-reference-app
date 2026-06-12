import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/repositories/mediators_repository.dart';

part 'mediators_repository_provider.g.dart';

@Riverpod(keepAlive: true)
Future<MediatorsRepository> mediatorsRepository(Ref ref) async {
  throw UnimplementedError(
    '''Please configure the application by providing a MediatorsRepository implementation in ProviderScope overrides.''',
  );
}
