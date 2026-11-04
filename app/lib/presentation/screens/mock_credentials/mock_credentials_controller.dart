import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../domain/models/vtc/mock_credential_template.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import 'mock_credentials_state.dart';

part 'mock_credentials_controller.g.dart';

const _logKey = 'MockCredentialsController';

/// Shows the test credentials this phone can issue and which of the
/// member's identities hold each, and imports one for an identity. Only a
/// failure's code is logged; never a DID or a credential.
@riverpod
class MockCredentialsController extends _$MockCredentialsController {
  late final VtcService _service = ref.read(vtcServiceProvider);

  @override
  MockCredentialsState build() {
    Future.microtask(refresh);
    return MockCredentialsState();
  }

  /// Reads again which identities hold each test credential.
  Future<void> refresh() async {
    final identities = ref.read(identitiesServiceProvider).vtaPersonas;
    state = state.copyWith(
      isLoading: true,
      identities: identities,
      failure: null,
    );
    try {
      final holders = await _service.mockCredentialHolders([
        for (final identity in identities) identity.did,
      ]);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, holders: holders);
    } on VtaNotLinkedException {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        failure: MockCredentialsFailure.vtaMissing,
      );
    } on MeetingPlaceVtcSDKException catch (error) {
      _log(error);
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        failure: MockCredentialsFailure.unreachable,
      );
    }
  }

  /// Imports the test credential [templateId] for the identity [did], one
  /// of the member's VTA identities. A refusal comes with the VTA's reason,
  /// when it gives one, to show the member: this is a tool for testing.
  Future<({MockCredentialImport outcome, String? reason})> import(
    String templateId,
    String did,
  ) async {
    const failed = (outcome: MockCredentialImport.failed, reason: null);
    final template = mockCredentialTemplates
        .where((template) => template.id == templateId)
        .firstOrNull;
    final identity = state.identities
        .where((identity) => identity.did == did)
        .firstOrNull;
    if (template == null || identity == null || state.importing != null) {
      return failed;
    }
    state = state.copyWith(importing: templateId);
    try {
      final kept = await _service.importMockCredential(
        template,
        personaDid: did,
        contextId: identity.vtaContextId!,
      );
      if (!ref.mounted) return failed;
      state = state.copyWith(
        importing: null,
        holders: kept
            ? {
                ...state.holders,
                templateId: {...?state.holders[templateId], did},
              }
            : state.holders,
      );
      return (
        outcome: kept
            ? MockCredentialImport.imported
            : MockCredentialImport.notKept,
        reason: null,
      );
    } on Exception catch (error) {
      _log(error);
      if (ref.mounted) state = state.copyWith(importing: null);
      return (
        outcome: MockCredentialImport.failed,
        reason: error is MeetingPlaceVtcSDKException
            ? _reasonOf(error.errorPayload)
            : null,
      );
    }
  }

  /// The reason a Trust Task error gives: its `message`, else its
  /// `details.reason`.
  static String? _reasonOf(Map<String, dynamic>? error) => switch (error) {
    {'message': final String message} when message.isNotEmpty => message,
    {'details': {'reason': final String reason}} when reason.isNotEmpty =>
      reason,
    _ => null,
  };

  void _log(Object error) {
    final code = error is MeetingPlaceVtcSDKException
        ? error.code.name
        : error.runtimeType.toString();
    ref.read(appLoggerProvider).warning('failed: $code', name: _logKey);
  }
}
