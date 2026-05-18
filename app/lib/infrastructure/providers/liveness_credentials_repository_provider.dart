import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/liveness_credentials_repository.dart';

part 'liveness_credentials_repository_provider.g.dart';

@Riverpod(keepAlive: true)
Future<LivenessCredentialsRepository> livenessCredentialsRepository(
  Ref ref,
) async {
  throw UnimplementedError(
    'LivenessCredentialsRepositoryProvider is not implemented.',
  );
}
