import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../application/services/context_routing_service/context_routing_service.dart';
import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/personal_ai_service/personal_ai_service.dart';
import '../../../infrastructure/media/file_picker/file_picker_platform_provider.dart';
import 'personal_agent_screen_state.dart';

class RoutingContextUploadOutcome {
  const RoutingContextUploadOutcome._({
    required this.uploaded,
    this.fileName,
    this.target,
  });

  const RoutingContextUploadOutcome.skipped()
    : this._(uploaded: false, fileName: null, target: null);

  const RoutingContextUploadOutcome.uploaded({
    required String fileName,
    required AgentContext target,
  }) : this._(uploaded: true, fileName: fileName, target: target);

  final bool uploaded;
  final String? fileName;
  final AgentContext? target;
}

class PickedTextFile {
  const PickedTextFile({required this.fileName, required this.content});

  final String fileName;
  final String content;
}

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
      contextProvisioned: personalAiState.contextProvisioned,
      contextUploading: personalAiState.contextUploading,
      errorMessage: personalAiState.errorMessage,
      contextUploadError: personalAiState.contextUploadError,
      setupResult: personalAiState.setupResult,
      clearErrorMessage: personalAiState.errorMessage == null,
      clearContextUploadError: personalAiState.contextUploadError == null,
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

  Future<void> uploadContext(String content) {
    final setupId = state.setupResult?.setupId ?? '';
    return _ref
        .read(personalAiServiceProvider.notifier)
        .uploadContext(setupId: setupId, content: content);
  }

  Future<PickedTextFile?> pickContextSetupFile() => _pickTextFile();

  Future<RoutingContextUploadOutcome> uploadRoutingContext(
    AgentContext target,
  ) async {
    final pickedFile = await _pickTextFile();
    if (pickedFile == null) {
      return const RoutingContextUploadOutcome.skipped();
    }

    await _ref
        .read<ContextRoutingService>(contextRoutingServiceProvider.notifier)
        .markContextUploaded(context: target, fileName: pickedFile.fileName);

    if (state.setupResult?.setupId?.isNotEmpty == true) {
      await uploadContext(pickedFile.content);
    }

    return RoutingContextUploadOutcome.uploaded(
      fileName: pickedFile.fileName,
      target: target,
    );
  }

  Future<PickedTextFile?> _pickTextFile() async {
    final picker = _ref.read(filePickerPlatformProvider);
    final picked = await picker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['txt'],
    );
    if (picked == null || picked.files.isEmpty) {
      return null;
    }

    final file = picked.files.first;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      return null;
    }

    return PickedTextFile(
      fileName: file.name,
      content: String.fromCharCodes(bytes),
    );
  }
}
