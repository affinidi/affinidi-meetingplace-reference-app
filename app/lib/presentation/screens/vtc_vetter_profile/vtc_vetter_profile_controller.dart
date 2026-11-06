import 'dart:async';

import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import 'vtc_vetter_profile_state.dart';

part 'vtc_vetter_profile_controller.g.dart';

/// Reads and publishes the member's vetter profile for one community. Only
/// a failure's type is logged, never what the profile says.
@riverpod
class VtcVetterProfileController extends _$VtcVetterProfileController {
  late final VtcService _service = ref.read(vtcServiceProvider);

  @override
  VtcVetterProfileState build(String communityDid) {
    unawaited(_load());
    return VtcVetterProfileState();
  }

  Future<void> _load() async {
    try {
      if (!await _service.canVet(communityDid)) {
        state = state.copyWith(step: VtcVetterProfileStep.notVetter);
        return;
      }
      state = state.copyWith(
        step: VtcVetterProfileStep.editing,
        recorded: (await _service.vetterDesk(communityDid))?.profile,
      );
    } on Exception catch (error, stackTrace) {
      _fail(error, stackTrace);
    }
  }

  /// Publishes [profile], replacing what the community held. Returns
  /// whether it did.
  Future<bool> publish(VetterProfile profile) async {
    if (state.busy || state.step != VtcVetterProfileStep.editing) return false;
    state = state.copyWith(busy: true, failure: null, invalidReason: null);
    try {
      final desk = await _service.publishVetterProfile(communityDid, profile);
      state = state.copyWith(recorded: desk.profile);
      return true;
    } on Exception catch (error, stackTrace) {
      _fail(error, stackTrace);
      return false;
    } finally {
      state = state.copyWith(busy: false);
    }
  }

  void _fail(Exception error, StackTrace stackTrace) {
    ref
        .read(appLoggerProvider)
        .error(
          'A vetter profile step failed: ${switch (error) {
            MeetingPlaceVtcSDKException(:final code) => code.name,
            _ => error.runtimeType,
          }}',
          stackTrace: stackTrace,
          name: 'VtcVetterProfileController',
        );
    state = switch (error) {
      NotVetterException() => state.copyWith(
        step: VtcVetterProfileStep.notVetter,
      ),
      MeetingPlaceVtcSDKException(
        code: MeetingPlaceVtcSDKErrorCode.invalidDocument,
        :final message,
      ) =>
        state.copyWith(
          failure: VtcVetterProfileFailure.invalid,
          invalidReason: message,
        ),
      _ => state.copyWith(failure: VtcVetterProfileFailure.unreachable),
    };
  }
}
