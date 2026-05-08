import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/secure_storage/secure_storage.dart';
import 'credentials_screen_state.dart';

final credentialsScreenControllerProvider =
    StateNotifierProvider<CredentialsScreenController, CredentialsScreenState>((
      ref,
    ) {
      final controller = CredentialsScreenController(ref: ref);
      controller.initialize();
      return controller;
    });

class CredentialsScreenController
    extends StateNotifier<CredentialsScreenState> {
  CredentialsScreenController({required Ref ref})
    : _ref = ref,
      super(const CredentialsScreenState());

  final Ref _ref;
  bool _hasLocalMutation = false;

  Future<void> initialize() async {
    final storage = await _ref.read(secureStorageProvider.future);
    final hasCredential = await storage.getHasLivenessCredential();
    // Avoid stale async hydration overriding recent user actions.
    if (_hasLocalMutation) return;
    state = state.copyWith(hasCredentials: hasCredential);
  }

  /// Save a credential (temporarily for this session)
  Future<void> saveCredential() async {
    _hasLocalMutation = true;
    state = state.copyWith(hasCredentials: true);
    final storage = await _ref.read(secureStorageProvider.future);
    await storage.saveHasLivenessCredential(true);
  }

  /// Delete the credential
  Future<void> deleteCredential() async {
    _hasLocalMutation = true;
    state = state.copyWith(hasCredentials: false);
    final storage = await _ref.read(secureStorageProvider.future);
    await storage.saveHasLivenessCredential(false);
  }
}
