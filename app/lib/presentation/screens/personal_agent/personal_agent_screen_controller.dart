import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/personal_ai_service/personal_ai_service.dart';
import 'personal_agent_screen_state.dart';

final personalAgentScreenControllerProvider =
    StateNotifierProvider<
      PersonalAgentScreenController,
      PersonalAgentScreenState
    >((ref) {
      final controller = PersonalAgentScreenController(ref);

      ref.listen(
        identitiesServiceProvider.currentIdentityOrPrimary,
        (_, _) => controller.syncFromDependencies(),
        fireImmediately: true,
      );

      ref.listen(
        personalAiServiceProvider,
        (_, _) => controller.syncFromDependencies(),
        fireImmediately: true,
      );

      return controller;
    });

class PersonalAgentScreenController
    extends StateNotifier<PersonalAgentScreenState> {
  PersonalAgentScreenController(this._ref)
    : super(const PersonalAgentScreenState.initial());

  final Ref _ref;

  void syncFromDependencies() {
    _ref
        .read(personalAiServiceProvider.notifier)
        .refreshPersonalAiContactSync();

    final identity = _ref.read(
      identitiesServiceProvider.currentIdentityOrPrimary,
    );
    final personalAiState = _ref.read(personalAiServiceProvider);

    state = state.copyWith(
      holderDid: identity?.did,
      isReady: personalAiState.isReady,
      isSettingUp: personalAiState.isSettingUp,
      errorMessage: personalAiState.errorMessage,
      setupResult: personalAiState.setupResult,
      clearErrorMessage: personalAiState.errorMessage == null,
      clearSetupResult: personalAiState.setupResult == null,
    );
  }

  Future<void> connectPersonalAi() {
    return _ref
        .read(personalAiServiceProvider.notifier)
        .setupPersonalAi(holderDid: state.holderDid ?? '');
  }

  void openSetupPrompt() {
    _ref.read(personalAiServiceProvider.notifier).openSetupPrompt();
  }
}
