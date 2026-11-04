import 'dart:async';
import 'dart:convert';

import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../domain/models/identity/identity.dart';
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
  static const pendingCheckInterval = Duration(seconds: 5);

  JoinManifest? _manifest;
  List<VtaPersona> _personas = const [];
  Timer? _pendingCheck;

  /// The identity whose details await approval, and what the VTA would
  /// disclose. Kept in memory only.
  VtaPersona? _identity;
  DisclosurePreview? _preview;

  /// For each way in met by presenting a credential, the credential each of
  /// the member's identities holds for it: by criterion id, then by DID.
  Map<String, Map<String, HeldCredential>> _holders = const {};

  /// The credential awaiting approval to present, the subject claims that
  /// discloses, and the application it completes. Kept in memory only.
  HeldCredential? _sharing;
  List<String> _sharedClaims = const [];
  VtaPersona? _applicant;
  List<JoinAttribute> _attributes = const [];

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
      } else {
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
    _holders = const {};
    _sharing = null;
    state = VtcJoinState();
  }

  /// Reads the scanned community code and what the community asks.
  Future<void> onScanned(String code) async {
    if (state.step != VtcJoinStep.scanning) return;
    state = state.copyWith(step: VtcJoinStep.working);

    await _run(() async {
      final manifest = await _service.readCommunity(code);
      _manifest = manifest;
      final profile = await _profileOf(manifest.communityDid);
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
      _holders = await _credentialHolders(manifest, community);
      state = state.copyWith(
        step: _stepOf(community),
        communityDid: manifest.communityDid,
        communityName:
            manifest.name ??
            profile?.name ??
            community?.name ??
            manifest.communityDid,
        logoUrl: manifest.logoUrl ?? profile?.logoUrl,
        description: profile?.description,
        website: profile?.website,
        contactEmail: profile?.contactEmail,
        directoryDisclosure: manifest.directoryDisclosure,
        canApply: manifest.canApply,
        wasMember: community?.isMember ?? false,
        ways: [
          for (final criterion in manifest.criteria)
            VtcJoinWay.of(
              criterion,
              heldBy: {...?_holders[criterion.id]?.keys},
            ),
        ],
        // The first way this app supports, else the community's first.
        chosenWayId:
            manifest.openCriterion?.id ?? manifest.criteria.firstOrNull?.id,
        manifest: manifest.document,
        requestedDetails: manifest.requestedAttributes,
        listsNewMembers: manifest.listsNewMembers,
        submitExchange: community?.submitExchange,
        submitReceipt: community?.submitReceipt,
        requestId: community?.joinRequestId,
        denialReason: community?.rejectionReason,
      );
    });
  }

  /// Which of the member's identities hold the credentials [manifest]'s ways
  /// in ask for: only the identity recorded for [community], when there is
  /// one, since a later application applies as it. A VTA that is not linked
  /// or cannot be asked holds none, and the review says so.
  Future<Map<String, Map<String, HeldCredential>>> _credentialHolders(
    JoinManifest manifest,
    VtcCommunity? community,
  ) async {
    final dids = community != null
        ? [community.personaDid]
        : [for (final identity in _joinableIdentities()) identity.did];
    try {
      return await _service.credentialHolders(manifest, dids);
    } on VtaNotLinkedException {
      return const {};
    } on MeetingPlaceVtcSDKException {
      return const {};
    }
  }

  /// The community's public profile, or null when it publishes none or it
  /// cannot be read: joining never depends on it.
  Future<CommunityProfile?> _profileOf(String communityDid) async {
    try {
      return await _service.readProfile(communityDid);
    } on MeetingPlaceVtcSDKException {
      return null;
    }
  }

  /// Sets whether the member opts in to the community's member directory.
  void setListInDirectory(bool listed) {
    if (state.step != VtcJoinStep.review) return;
    state = state.copyWith(listInDirectory: listed);
  }

  /// Shows the way in [id] of the scanned community as the one to apply
  /// under. One this app does not support can be shown, not applied under.
  void chooseWay(String id) {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.review || manifest == null) return;
    if (!manifest.criteria.any((criterion) => criterion.id == id)) return;
    state = state.copyWith(chosenWayId: id);
  }

  /// The chosen way in, when this app can apply under it: an open one, or
  /// one asking for a credential one of the member's identities holds.
  JoinCriterion? _chosenCriterion(JoinManifest manifest) => manifest.criteria
      .where(
        (criterion) =>
            criterion.id == state.chosenWayId &&
            (criterion.isOpen || (_holders[criterion.id]?.isNotEmpty ?? false)),
      )
      .firstOrNull;

  /// Goes on to apply to the scanned community, under the way in the member
  /// chose; does nothing when this app does not support it.
  ///
  /// A first application asks which of the member's identities joins, or a
  /// new one, when the member has any; a later one applies as the identity
  /// recorded for it.
  Future<void> join() async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.review ||
        manifest == null ||
        _chosenCriterion(manifest) == null) {
      return;
    }
    final criterion = _chosenCriterion(manifest)!;
    state = state.copyWith(step: VtcJoinStep.working);

    await _run(() async {
      if (await _service.community(manifest.communityDid) != null) {
        return _apply(manifest);
      }
      final identities = _joinableIdentities();
      _personas = [
        for (final identity in identities)
          VtaPersona(did: identity.did, contextId: identity.vtaContextId!),
      ];
      if (_personas.isEmpty) return _apply(manifest);
      state = state.copyWith(
        step: VtcJoinStep.chooseIdentity,
        identityChoices: [for (final persona in _personas) persona.did],
        identities: {for (final identity in identities) identity.did: identity},
        credentialHolders: criterion.asksForCredentials
            ? {...?_holders[criterion.id]?.keys}
            : null,
      );
    });
  }

  /// The member's identities, which are personas of their VTA, primary
  /// first.
  List<Identity> _joinableIdentities() {
    final identities = ref
        .read(identitiesServiceProvider)
        .identities
        .where((identity) => identity.isVtaPersona);
    return [
      ...identities.where((identity) => identity.isPrimary),
      ...identities.where((identity) => !identity.isPrimary),
    ];
  }

  /// Joins as the VTA identity [personaDid], or as a new identity when
  /// null. Only an identity the VTA offered is used, and under a way in
  /// asking for a credential only one holding it.
  Future<void> useIdentity(String? personaDid) async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.chooseIdentity || manifest == null) return;
    final persona = _personas.where((p) => p.did == personaDid).firstOrNull;
    if (personaDid != null && persona == null) return;
    final holders = state.credentialHolders;
    if (holders != null && !holders.contains(personaDid)) return;
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
      await _sendOrAskCredential(
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

  /// Presents the credential the member approved, through the VTA, and
  /// applies with it.
  Future<void> approveCredential() async {
    final manifest = _manifest;
    final sharing = _sharing;
    if (state.step != VtcJoinStep.approveCredential ||
        manifest == null ||
        sharing == null) {
      return;
    }
    state = state.copyWith(step: VtcJoinStep.working);

    await _run(() async {
      final presentation = await _service.presentCredential(
        manifest,
        sharing.id,
        _sharedClaims,
      );
      await _send(
        manifest,
        _applicant,
        attributes: _attributes,
        presentation: presentation,
      );
    });
  }

  /// Applies, first asking the member to approve the profile details the
  /// community asks for, when it asks for any.
  Future<void> _apply(JoinManifest manifest, {VtaPersona? persona}) async {
    if (manifest.requestedAttributes.isEmpty) {
      return _sendOrAskCredential(manifest, persona);
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

  /// Applies, first asking the member to approve presenting the credential
  /// the chosen way in asks for, when it asks for one. The credential is
  /// the one the applying identity holds; the recorded one when [persona]
  /// is null.
  Future<void> _sendOrAskCredential(
    JoinManifest manifest,
    VtaPersona? persona, {
    List<JoinAttribute> attributes = const [],
  }) async {
    final criterion = _chosenCriterion(manifest);
    if (criterion == null || !criterion.asksForCredentials) {
      return _send(manifest, persona, attributes: attributes);
    }
    final applicant =
        persona?.did ??
        (await _service.community(manifest.communityDid))?.personaDid;
    final held = _holders[criterion.id]?[applicant];
    final credential = held == null
        ? null
        : await _service.heldCredential(held.id);
    final subject = credential?['credentialSubject'];
    final claims = <String, Object>{
      if (subject is Map)
        for (final MapEntry(:key, :value) in subject.entries)
          if (key is String && key != 'id' && value != null)
            key: value as Object,
    };
    // A credential that discloses nothing about its subject but who they
    // are cannot be presented by naming its claims.
    if (held == null || claims.isEmpty) {
      return _fail(VtcJoinFailure.credentialMissing);
    }
    _sharing = held;
    _sharedClaims = [...claims.keys];
    _applicant = persona;
    _attributes = attributes;
    state = state.copyWith(
      step: VtcJoinStep.approveCredential,
      details: const [],
      sharedCredential: VtcJoinCredential(
        types: held.types,
        issuerDid: held.issuerDid,
        claims: [
          for (final MapEntry(:key, :value) in claims.entries)
            VtcJoinDetail(type: key, value: _shown(value)),
        ],
      ),
    );
  }

  Future<void> _send(
    JoinManifest manifest,
    VtaPersona? persona, {
    List<JoinAttribute> attributes = const [],
    Map<String, dynamic>? presentation,
  }) async {
    _preview = null;
    _sharing = null;
    final verdict = await _service.join(
      manifest,
      persona: persona,
      criterion: _chosenCriterion(manifest),
      presentation: presentation,
      attributes: attributes,
      listInDirectory: state.listInDirectory,
    );
    // The documents as recorded: an application already open keeps its own.
    final recorded = verdict is JoinPending
        ? await _service.community(manifest.communityDid)
        : null;
    state = state.copyWith(
      details: const [],
      sharedCredential: null,
      submitExchange: recorded?.submitExchange,
      submitReceipt: recorded?.submitReceipt,
      requestId: recorded?.joinRequestId,
      denialReason: verdict is JoinDenied ? verdict.reason : null,
      step: switch (verdict) {
        JoinAdmitted() => VtcJoinStep.joined,
        JoinPending() => VtcJoinStep.pending,
        JoinDenied() => VtcJoinStep.denied,
        JoinNeedsMore() => VtcJoinStep.needsMore,
      },
    );
  }

  /// Asks the community whether it decided on the open application. The
  /// screen stays as it is while it asks, and a check that fails leaves the
  /// application waiting for the next one.
  Future<void> checkAgain() async {
    final manifest = _manifest;
    // A check can take longer than [pendingCheckInterval]; checks never
    // overlap.
    if (state.step != VtcJoinStep.pending ||
        manifest == null ||
        state.checking) {
      return;
    }
    state = state.copyWith(checking: true);
    try {
      final status = await _service.checkApplication(manifest.communityDid);
      // The member may have moved on while the community answered.
      if (state.step != VtcJoinStep.pending) return;
      state = state.copyWith(
        denialReason: status?.reason,
        deferred: status?.status == JoinRequestStatus.deferred,
        lastCheckedAt: DateTime.now(),
        lastCheckExchange: status?.exchange,
        step: switch (status?.status) {
          JoinRequestStatus.approved => VtcJoinStep.joined,
          JoinRequestStatus.pending ||
          JoinRequestStatus.deferred => VtcJoinStep.pending,
          JoinRequestStatus.rejected ||
          JoinRequestStatus.withdrawn => VtcJoinStep.denied,
          null => VtcJoinStep.review,
        },
      );
    } on MeetingPlaceVtcSDKException {
      // Not logged: at this pace an unreachable community would flood the
      // log. The next check tries again.
    } on VtaNotLinkedException {
      _fail(VtcJoinFailure.vtaMissing);
    } finally {
      state = state.copyWith(checking: false);
    }
  }

  /// Withdraws the open application; the screen asks the member to confirm
  /// first. A check under way is then ignored. When the community decided
  /// already, shows its decision instead.
  Future<void> withdraw() async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.pending || manifest == null) return;
    state = state.copyWith(step: VtcJoinStep.working);

    await _run(() async {
      try {
        await _service.withdraw(manifest.communityDid);
      } on MeetingPlaceVtcSDKException catch (error) {
        if (!(error.refusalCode?.endsWith(':alreadyDecided') ?? false)) {
          rethrow;
        }
        final community = await _service.community(manifest.communityDid);
        state = state.copyWith(
          step: (community?.isMember ?? false)
              ? VtcJoinStep.joined
              : VtcJoinStep.denied,
          denialReason: community?.rejectionReason,
        );
        return;
      }
      state = state.copyWith(
        step: VtcJoinStep.withdrawn,
        submitExchange: null,
        submitReceipt: null,
        requestId: null,
        deferred: false,
        lastCheckedAt: null,
        lastCheckExchange: null,
      );
    });
  }

  /// Goes back to what the community asks, to apply again after
  /// withdrawing.
  void applyAgain() {
    if (state.step != VtcJoinStep.withdrawn) return;
    state = state.copyWith(step: VtcJoinStep.review);
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
