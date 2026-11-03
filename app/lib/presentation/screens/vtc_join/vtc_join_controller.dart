import 'dart:async';
import 'dart:convert';

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

  /// How often an open application is checked while the screen shows it.
  static const pendingCheckInterval = Duration(seconds: 30);

  JoinManifest? _manifest;
  List<VtaPersona> _personas = const [];
  Timer? _pendingCheck;

  /// The identity whose details await approval, and what the VTA would
  /// disclose. Kept in memory only.
  VtaPersona? _identity;
  DisclosurePreview? _preview;

  @override
  VtcJoinState build() {
    ref.onDispose(() => _pendingCheck?.cancel());
    // While an application waits, ask the community again now and then.
    listenSelf((_, next) {
      if (next.step == VtcJoinStep.pending) {
        _pendingCheck ??= Timer.periodic(
          pendingCheckInterval,
          (_) => checkAgain(),
        );
      } else if (next.step != VtcJoinStep.working) {
        _pendingCheck?.cancel();
        _pendingCheck = null;
      }
    });
    return VtcJoinState();
  }

  /// Starts over with another community's code, e.g. after a failure.
  void restart() {
    _manifest = null;
    _personas = const [];
    state = VtcJoinState();
  }

  /// Reads the scanned community code and what the community asks.
  Future<void> onScanned(String code) async {
    if (state.step != VtcJoinStep.scanning) return;
    state = state.copyWith(step: VtcJoinStep.working);

    await _run(() async {
      final manifest = await _service.readCommunity(code);
      _manifest = manifest;
      var community = await _service.community(manifest.communityDid);
      if (community == null) {
        // A membership another app of the member holds, backed up to the
        // VTA: joining again would apply a second time.
        final backedUp = await _service.importMembership(manifest.communityDid);
        if (backedUp != null) {
          await _service.rememberMembership(backedUp);
          community = await _service.community(manifest.communityDid);
        }
      }
      state = state.copyWith(
        step: _stepOf(community),
        communityName:
            manifest.name ?? community?.name ?? manifest.communityDid,
        canApply: manifest.canApply,
        admitsAtOnce: manifest.admitsAtOnce,
        wasMember: community?.isMember ?? false,
        ways: [
          for (final criterion in manifest.criteria) VtcJoinWay.of(criterion),
        ],
        requestedDetails: manifest.requestedAttributes,
        listsNewMembers: manifest.listsNewMembers,
        denialReason: community?.rejectionReason,
      );
    });
  }

  /// Sets whether the member opts in to the community's member directory.
  void setListInDirectory(bool listed) {
    if (state.step != VtcJoinStep.review) return;
    state = state.copyWith(listInDirectory: listed);
  }

  /// Goes on to apply to the scanned community, under the first way in
  /// this app supports; does nothing when there is none.
  ///
  /// A first application asks which identity on the VTA joins, when the VTA
  /// holds any; a later one applies as the identity recorded for it.
  Future<void> join() async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.review ||
        manifest == null ||
        !manifest.canApply) {
      return;
    }
    state = state.copyWith(step: VtcJoinStep.working);

    await _run(() async {
      if (await _service.community(manifest.communityDid) != null) {
        return _apply(manifest);
      }
      _personas = await _service.vtaPersonas();
      if (_personas.isEmpty) return _apply(manifest);
      state = state.copyWith(
        step: VtcJoinStep.chooseIdentity,
        identityChoices: [for (final persona in _personas) persona.did],
      );
    });
  }

  /// Joins as the VTA identity [personaDid], or as a new identity when
  /// null. Only an identity the VTA offered is used.
  Future<void> useIdentity(String? personaDid) async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.chooseIdentity || manifest == null) return;
    final persona = _personas.where((p) => p.did == personaDid).firstOrNull;
    if (personaDid != null && persona == null) return;
    state = state.copyWith(step: VtcJoinStep.working);

    await _run(() => _apply(manifest, persona: persona));
  }

  /// Shares the profile details the member approved, through the VTA, and
  /// applies with them.
  Future<void> approveDetails() async {
    final manifest = _manifest;
    final identity = _identity;
    final preview = _preview;
    if (state.step != VtcJoinStep.approveDetails ||
        manifest == null ||
        identity == null ||
        preview == null) {
      return;
    }
    state = state.copyWith(step: VtcJoinStep.working);

    await _run(() async {
      await _service.shareDetails(identity, preview.previewId);
      await _send(
        manifest,
        identity,
        attributes: [
          for (final claim in preview.claims)
            if (claim.value case final Object value)
              JoinAttribute(type: claim.type, value: value),
        ],
      );
    });
  }

  /// Applies, first asking the member to approve the profile details the
  /// community asks for, when it asks for any.
  Future<void> _apply(JoinManifest manifest, {VtaPersona? persona}) async {
    if (manifest.requestedAttributes.isEmpty) {
      return _send(manifest, persona);
    }
    final identity = await _service.joiningIdentity(
      manifest,
      persona: persona,
      listInDirectory: state.listInDirectory,
    );
    final preview = await _service.previewDetails(manifest, identity);
    final held = {
      for (final claim in preview.claims)
        if (claim.value != null) claim.type: claim.value!,
    };
    if (manifest.requestedAttributes.any(
      (detail) => detail.required && !held.containsKey(detail.type),
    )) {
      return _fail(VtcJoinFailure.detailsMissing);
    }
    _identity = identity;
    _preview = DisclosurePreview(
      previewId: preview.previewId,
      // Only what the community asked for, and only what the VTA holds.
      claims: [
        for (final detail in manifest.requestedAttributes)
          if (held[detail.type] case final Object value)
            DisclosedClaim(type: detail.type, value: value),
      ],
    );
    state = state.copyWith(
      step: VtcJoinStep.approveDetails,
      details: [
        for (final claim in _preview!.claims)
          VtcJoinDetail(type: claim.type, value: _shown(claim.value!)),
      ],
    );
  }

  Future<void> _send(
    JoinManifest manifest,
    VtaPersona? persona, {
    List<JoinAttribute> attributes = const [],
  }) async {
    _preview = null;
    final verdict = await _service.join(
      manifest,
      persona: persona,
      attributes: attributes,
      listInDirectory: state.listInDirectory,
    );
    state = state.copyWith(
      details: const [],
      denialReason: verdict is JoinDenied ? verdict.reason : null,
      step: switch (verdict) {
        JoinAdmitted() => VtcJoinStep.joined,
        JoinPending() => VtcJoinStep.pending,
        JoinDenied() => VtcJoinStep.denied,
        JoinNeedsMore() => VtcJoinStep.needsMore,
      },
    );
  }

  /// Asks the community whether it decided on the open application.
  Future<void> checkAgain() async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.pending || manifest == null) return;
    state = state.copyWith(step: VtcJoinStep.working);

    await _run(() async {
      final status = await _service.checkApplication(manifest.communityDid);
      state = state.copyWith(
        denialReason: status?.reason,
        step: switch (status?.status) {
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

  static String _shown(Object value) =>
      value is String ? value : jsonEncode(value);

  /// Leaves the community the member belongs to; the screen asks them to
  /// confirm first.
  Future<void> leave() async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.joined || manifest == null) return;
    state = state.copyWith(step: VtcJoinStep.working);

    await _run(() async {
      try {
        await _service.leave(manifest.communityDid);
      } on MeetingPlaceVtcSDKException catch (error) {
        if (error.httpStatus != _lastAdministratorStatus) rethrow;
        return _fail(VtcJoinFailure.lastAdministrator);
      }
      state = state.copyWith(step: VtcJoinStep.left);
    });
  }

  /// How a community refuses the leave of its last administrator.
  static const _lastAdministratorStatus = 409;

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
      if (error.refusalCode?.endsWith(':alreadyMember') ?? false) {
        // The community already counts this identity as a member.
        state = state.copyWith(step: VtcJoinStep.joined, wasMember: true);
        return;
      }
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
      MeetingPlaceVtcSDKErrorCode.refused
          when error.refusalCode == 'notBound' =>
        VtcJoinFailure.profileMissing,
      MeetingPlaceVtcSDKErrorCode.refused => VtcJoinFailure.refused,
      MeetingPlaceVtcSDKErrorCode.invalidDocument ||
      MeetingPlaceVtcSDKErrorCode.invalidProof => VtcJoinFailure.badAnswer,
      MeetingPlaceVtcSDKErrorCode.didResolutionFailed ||
      MeetingPlaceVtcSDKErrorCode.signInNotOffered ||
      MeetingPlaceVtcSDKErrorCode.transportFailed => VtcJoinFailure.unreachable,
    };
  }
}
