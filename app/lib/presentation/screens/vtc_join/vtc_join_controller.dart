import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../domain/models/vtc/vtc_community.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import 'vtc_join_state.dart';

part 'vtc_join_controller.g.dart';

/// Drives joining one community, from its scanned code to the community's
/// answer. Only a failure's code is logged; never a DID, key or document.
@riverpod
class VtcJoinController extends _$VtcJoinController {
  late final VtcService _service = ref.read(vtcServiceProvider);

  JoinManifest? _manifest;

  @override
  VtcJoinState build() => VtcJoinState();

  /// Reads the scanned community code and what the community asks.
  Future<void> onScanned(String code) async {
    if (state.step != VtcJoinStep.scanning) return;
    state = state.copyWith(step: VtcJoinStep.working);

    await _run(() async {
      final manifest = await _service.readCommunity(code);
      _manifest = manifest;
      final community = await _service.community(manifest.communityDid);
      state = state.copyWith(
        step: _stepOf(community),
        communityName:
            manifest.name ?? community?.name ?? manifest.communityDid,
        canApply: manifest.canApply,
        admitsAtOnce: manifest.admitsAtOnce,
        wasMember: community?.isMember ?? false,
      );
    });
  }

  /// Applies to join the scanned community.
  Future<void> join() async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.review || manifest == null) return;
    state = state.copyWith(step: VtcJoinStep.working);

    await _run(() async {
      final verdict = await _service.join(manifest);
      state = state.copyWith(
        step: switch (verdict) {
          JoinAdmitted() => VtcJoinStep.joined,
          JoinPending() => VtcJoinStep.pending,
          JoinDenied() => VtcJoinStep.denied,
          JoinNeedsMore() => VtcJoinStep.needsMore,
        },
      );
    });
  }

  /// Asks the community whether it decided on the open application.
  Future<void> checkAgain() async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.pending || manifest == null) return;
    state = state.copyWith(step: VtcJoinStep.working);

    await _run(() async {
      final status = await _service.checkApplication(manifest.communityDid);
      state = state.copyWith(
        step: switch (status) {
          JoinRequestStatus.approved => VtcJoinStep.joined,
          JoinRequestStatus.pending ||
          JoinRequestStatus.deferred => VtcJoinStep.pending,
          JoinRequestStatus.rejected ||
          JoinRequestStatus.withdrawn => VtcJoinStep.denied,
          null => VtcJoinStep.review,
        },
      );
    });
  }

  static VtcJoinStep _stepOf(VtcCommunity? community) {
    if (community == null) return VtcJoinStep.review;
    if (community.isMember) return VtcJoinStep.joined;
    if (community.isApplying) return VtcJoinStep.pending;
    return VtcJoinStep.review;
  }

  Future<void> _run(Future<void> Function() step) async {
    try {
      await step();
    } on InvalidCommunityCodeException {
      _fail(VtcJoinFailure.invalidCode);
    } on VtaNotLinkedException {
      _fail(VtcJoinFailure.vtaMissing);
    } on MeetingPlaceVtcSDKException catch (error, stackTrace) {
      // The refusal code tells the VTA's refusal from the community's.
      ref
          .read(appLoggerProvider)
          .error(
            'Joining the community failed: ${error.code.name}'
            ' ${error.refusalCode ?? ''}',
            stackTrace: stackTrace,
            name: 'VtcJoinController',
          );
      _fail(_failureOf(error));
    }
  }

  void _fail(VtcJoinFailure failure) {
    state = state.copyWith(step: VtcJoinStep.failed, failure: failure);
  }

  static VtcJoinFailure _failureOf(MeetingPlaceVtcSDKException error) {
    return switch (error.code) {
      MeetingPlaceVtcSDKErrorCode.didHostingMissing =>
        VtcJoinFailure.noDidHosting,
      MeetingPlaceVtcSDKErrorCode.refused
          when error.refusalCode?.endsWith(':notAccepting') ?? false =>
        VtcJoinFailure.notAccepting,
      MeetingPlaceVtcSDKErrorCode.refused => VtcJoinFailure.refused,
      MeetingPlaceVtcSDKErrorCode.invalidDocument ||
      MeetingPlaceVtcSDKErrorCode.invalidProof => VtcJoinFailure.badAnswer,
      MeetingPlaceVtcSDKErrorCode.didResolutionFailed ||
      MeetingPlaceVtcSDKErrorCode.signInNotOffered ||
      MeetingPlaceVtcSDKErrorCode.transportFailed => VtcJoinFailure.unreachable,
    };
  }
}
