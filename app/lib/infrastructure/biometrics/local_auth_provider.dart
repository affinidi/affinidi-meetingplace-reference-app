import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_auth_provider.g.dart';

/// Provides a LocalAuthentication instance from the `local_auth` plugin.
///
/// Factory parameters:
/// - [ref] - Riverpod Ref used to construct the provider.
@Riverpod(keepAlive: true)
LocalAuthentication localAuth(Ref ref) {
  return LocalAuthentication();
}
