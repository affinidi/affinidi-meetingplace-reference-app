import 'dart:async';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:meeting_place_core/meeting_place_core.dart'
    show MeetingPlaceCoreSDKException;
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/community_offer_service/community_offer_service.dart';
import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../domain/models/vtc/vtc_card_delivery.dart';
import '../../../domain/models/vtc/vtc_community.dart';
import '../../../domain/models/vtc/vtc_membership_card.dart';
import '../../../domain/models/vtc/vtc_vetting.dart';
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

  /// How often the vetter's answers are picked up while the member waits
  /// on them, so the next step shows as soon as the vetter acts.
  static const vettingCheckInterval = Duration(seconds: 1);

  /// When the community, the VTA or the vetters were last asked.
  DateTime? _checkedAt;

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

  /// The credential awaiting approval to present, who presents it, and the
  /// application it completes. Kept in memory only.
  Map<String, dynamic>? _sharing;
  String? _holderDid;
  VtaPersona? _applicant;
  List<JoinAttribute> _attributes = const [];

  /// The details awaiting approval for a vetting card. Kept in memory only.
  DisclosurePreview? _vettingPreview;

  /// Whether the application now goes out with the statements gathered,
  /// rather than gathering more.
  bool _sendingVetted = false;

  /// Whether the vetters' answers are being picked up; checks do not
  /// overlap.
  bool _checkingVetting = false;

  /// Whether the membership card is being read; reads do not overlap.
  bool _readingCard = false;

  /// Whether the identity check is being read; reads do not overlap.
  bool _readingCheck = false;

  /// Whether the member's role is being read; reads do not overlap.
  bool _readingRole = false;

  /// Whether the membership card is being collected; collections do not
  /// overlap.
  bool _collectingCard = false;

  @override
  VtcJoinState build() {
    // A role card kept on the VTA, e.g. after a promotion, is read again.
    final membershipChanges = _service.membershipsChanged.listen(
      (_) => unawaited(readRole()),
    );
    ref.onDispose(() {
      unawaited(membershipChanges.cancel());
      _pendingCheck?.cancel();
      // Forget the identity's keys the VTA lent for collecting the card.
      if (_manifest case final manifest?) {
        unawaited(_service.endCardCollection(manifest.communityDid));
      }
    });
    // While an application waits, or a new member's card has yet to reach
    // their VTA, ask again now and then.
    listenSelf((previous, next) {
      final waiting =
          next.step == VtcJoinStep.pending ||
          (next.step == VtcJoinStep.joined && next.membershipCard == null) ||
          (next.step == VtcJoinStep.vetting &&
              (next.vetting?.requests.any((r) => r.isOpen) ?? false));
      if (waiting) {
        if (_pendingCheck == null) {
          // The first check waits its whole interval, as before.
          _checkedAt = clock.now();
          _pendingCheck = Timer.periodic(
            vettingCheckInterval,
            (_) => unawaited(_checkWhenDue()),
          );
        }
      } else {
        _pendingCheck?.cancel();
        _pendingCheck = null;
      }
      if (next.step == VtcJoinStep.joined &&
          previous?.step != VtcJoinStep.joined) {
        unawaited(readMembershipCard());
        unawaited(readIdentityCheck());
        unawaited(readRole());
        unawaited(refreshRole());
      }
    });
    return VtcJoinState();
  }

  /// Asks again once [pendingCheckInterval] passed since the last time, or
  /// [vettingCheckInterval] while the member waits on a vetter; what is
  /// asked follows the step as it is now, not as it was when the timer
  /// was set.
  Future<void> _checkWhenDue() async {
    final now = clock.now();
    final interval = state.waitingOnVetter
        ? vettingCheckInterval
        : pendingCheckInterval;
    final checkedAt = _checkedAt;
    if (checkedAt != null && now.difference(checkedAt) < interval) return;
    _checkedAt = now;
    await switch (state.step) {
      VtcJoinStep.pending => checkAgain(),
      VtcJoinStep.vetting => checkVetting(),
      _ => collectMembershipCard(),
    };
  }

  /// Starts over with another community's code, e.g. after a failure.
  void restart() {
    _manifest = null;
    _personas = const [];
    _holders = const {};
    _sharing = null;
    _vettingPreview = null;
    _sendingVetted = false;
    state = VtcJoinState();
  }

  /// Reads the scanned community code, a DID or a join phrase, and what
  /// the community asks.
  Future<void> onScanned(String code) async {
    if (state.step != VtcJoinStep.scanning) return;
    state = state.copyWith(step: VtcJoinStep.working);

    await _run(() async {
      final manifest = await _service.readCommunity(
        await _communityDidOf(code),
      );
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
      // Vetting under way picks up where it was.
      final vetting = await _service.vetting(manifest.communityDid);
      final vetted = manifest.criteria
          .where((criterion) => criterion.id == vetting?.criterionId)
          .firstOrNull;
      if (state.step == VtcJoinStep.review &&
          vetting != null &&
          (vetted?.asksOnlyForVetting ?? false)) {
        state = state.copyWith(chosenWayId: vetted!.id);
        _showVetting(vetting);
      }
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
            (criterion.isOpen ||
                criterion.asksOnlyForVetting ||
                (_holders[criterion.id]?.isNotEmpty ?? false)),
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
  List<Identity> _joinableIdentities() =>
      ref.read(identitiesServiceProvider).vtaPersonas;

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

    await _run(
      () => _send(
        manifest,
        _applicant,
        attributes: _attributes,
        presentation: joinPresentation(sharing, holderDid: _holderDid!),
      ),
    );
  }

  /// Applies, first asking the member to approve the profile details the
  /// community asks for, when it asks for any.
  Future<void> _apply(JoinManifest manifest, {VtaPersona? persona}) async {
    if ((_chosenCriterion(manifest)?.asksForVetting ?? false) &&
        !_sendingVetted) {
      return _startVetting(manifest, persona);
    }
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
    if (held == null || credential == null) {
      return _fail(VtcJoinFailure.credentialMissing);
    }
    _sharing = credential;
    _holderDid = applicant;
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
      // Shown at once: the VTA already keeps the card the admission carries.
      membershipCard: switch (verdict) {
        JoinAdmitted(membershipCard: final card?) =>
          VtcMembershipCard.fromCredential(card),
        _ => null,
      },
      step: switch (verdict) {
        JoinAdmitted() => VtcJoinStep.joined,
        JoinPending() => VtcJoinStep.pending,
        JoinDenied() => VtcJoinStep.denied,
        JoinNeedsMore() => VtcJoinStep.needsMore,
      },
    );
  }

  /// Records the identity applying, then shows the vetting it gathers.
  Future<void> _startVetting(JoinManifest manifest, VtaPersona? persona) async {
    await _service.joiningIdentity(
      manifest,
      persona: persona,
      listInDirectory: state.listInDirectory,
    );
    final criterion = _chosenCriterion(manifest)!;
    final vetting = await _service.vetting(manifest.communityDid);
    _showVetting(
      vetting?.criterionId == criterion.id
          ? vetting!
          : VtcVetting(
              communityDid: manifest.communityDid,
              criterionId: criterion.id,
              vetterRole: criterion.vetting!.vetterRole,
              salt: '',
            ),
    );
  }

  /// Shows the overview of [vetting], counted against the chosen way in.
  void _showVetting(VtcVetting vetting, {VettingFailure? failure}) {
    final requirements = _manifest == null
        ? null
        : _chosenCriterion(_manifest!)?.vetting;
    state = state.copyWith(
      step: VtcJoinStep.vetting,
      vetting: vetting,
      vettingRequirements: requirements,
      vettingProgress: requirements == null
          ? null
          : VettingProgress.of(
              requirements: requirements,
              communityDid: vetting.communityDid,
              statements: vetting.statements,
              now: DateTime.now(),
            ),
      vetterDid: null,
      vettingWork: null,
      details: const [],
      vettingFailure: failure,
    );
  }

  void _showWork(VtcVettingWork work) {
    // The screen may have closed while the work went on.
    if (ref.mounted) state = state.copyWith(vettingWork: work);
  }

  /// Picks up the vetters' answers. Quietly, as [checkAgain]: a check that
  /// fails waits for the next. A session a vetter opened is shown at once
  /// for the member to compare its match code.
  Future<void> checkVetting() async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.vetting ||
        manifest == null ||
        _checkingVetting) {
      return;
    }
    _checkingVetting = true;
    try {
      final vetting = await _service.checkVetting(manifest.communityDid);
      // The member may have moved on while the vetters' answers came in.
      if (!ref.mounted || state.step != VtcJoinStep.vetting) return;
      if (vetting == null) return;
      _showVetting(vetting, failure: state.vettingFailure);
      final session = vetting.requests
          .where((request) => request.status == VtcVettingStatus.inSession)
          .firstOrNull;
      if (session != null) {
        state = state.copyWith(
          step: VtcJoinStep.confirmMatch,
          vetterDid: session.vetterDid,
        );
      }
    } on MeetingPlaceVtcSDKException {
      // The next check tries again.
    } on VtaNotLinkedException {
      _fail(VtcJoinFailure.vtaMissing);
    } finally {
      _checkingVetting = false;
    }
  }

  /// Asks the vetter whose ticket the member scanned.
  Future<void> scanVettingTicket(String text) async {
    if (state.step != VtcJoinStep.vetting) return;
    final ticket = VettingTicket.parse(text);
    if (ticket == null) {
      state = state.copyWith(vettingFailure: VettingFailure.invalidTicket);
      return;
    }
    await _requestVetter(ticket);
  }

  /// Goes on to pick the vetter in front of the member, to type their code.
  /// A community listing one vetter needs no picking.
  Future<void> enterVettingCode() async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.vetting || manifest == null) return;
    state = state.copyWith(
      step: VtcJoinStep.working,
      vettingWork: VtcVettingWork.listingVetters,
      vettingFailure: null,
    );
    await _run(() async {
      final vetters = await _service.vetters(manifest);
      state = state.copyWith(
        vettingWork: null,
        vetters: vetters,
        step: vetters.length == 1
            ? VtcJoinStep.enterVettingCode
            : VtcJoinStep.chooseVetter,
        vetterDid: vetters.length == 1 ? vetters.single.did : null,
      );
    });
  }

  /// Takes [vetterDid], one the community lists, as the vetter in front of
  /// the member.
  void chooseVetter(String vetterDid) {
    if (state.step != VtcJoinStep.chooseVetter ||
        !state.vetters.any((vetter) => vetter.did == vetterDid)) {
      return;
    }
    state = state.copyWith(
      step: VtcJoinStep.enterVettingCode,
      vetterDid: vetterDid,
    );
  }

  /// Asks the vetter at hand with the [code] they read out.
  Future<void> submitVettingCode(String code) async {
    final vetterDid = state.vetterDid;
    final communityDid = state.communityDid;
    if (state.step != VtcJoinStep.enterVettingCode ||
        vetterDid == null ||
        communityDid == null) {
      return;
    }
    final ticket = VettingTicket.spoken(
      community: communityDid,
      vetter: vetterDid,
      code: code,
    );
    if (ticket == null) {
      state = state.copyWith(vettingFailure: VettingFailure.invalidTicket);
      return;
    }
    await _requestVetter(ticket);
  }

  Future<void> _requestVetter(VettingTicket ticket) async {
    final manifest = _manifest;
    final criterion = manifest == null ? null : _chosenCriterion(manifest);
    if (manifest == null || criterion == null) return;
    final name = state.vetters
        .where((vetter) => vetter.did == ticket.vetter)
        .firstOrNull
        ?.displayName;
    state = state.copyWith(
      step: VtcJoinStep.working,
      flowVetterDid: ticket.vetter,
      vettingWork: VtcVettingWork.unlockingIdentity,
      vettingFailure: null,
    );
    await _run(() async {
      _showVetting(
        await _service.startVetting(
          manifest,
          criterion: criterion,
          ticket: ticket,
          vetterName: name,
          onStep: _showWork,
        ),
      );
    });
  }

  /// Goes back to the vetting overview, e.g. from picking a vetter.
  /// Stops gathering vetters' statements and goes back to what the
  /// community asks, to choose a way in again. The screen asks the member to
  /// confirm first: what was gathered is forgotten.
  Future<void> stopVetting() async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.vetting || manifest == null) return;
    state = state.copyWith(step: VtcJoinStep.working);
    await _run(() async {
      await _service.stopVetting(manifest.communityDid);
      _vettingPreview = null;
      state = state.copyWith(
        step: VtcJoinStep.review,
        vetting: null,
        vettingRequirements: null,
        vettingProgress: null,
        vetterDid: null,
        flowVetterDid: null,
        vettingFailure: null,
      );
    });
  }

  /// Goes back to the vetting overview, e.g. from typing a vetter's code.
  void backToVetting() {
    final vetting = state.vetting;
    if (vetting == null) return;
    state = state.copyWith(flowVetterDid: null);
    _showVetting(vetting);
  }

  /// The member confirmed the match codes are the same: shows the details
  /// the vetting card would carry, as the VTA would disclose them.
  Future<void> confirmMatch() async {
    final manifest = _manifest;
    final vetterDid = state.vetterDid;
    if (state.step != VtcJoinStep.confirmMatch ||
        manifest == null ||
        vetterDid == null) {
      return;
    }
    state = state.copyWith(
      step: VtcJoinStep.working,
      vettingWork: VtcVettingWork.preparingDetails,
    );
    await _run(() async {
      final preview = await _service.previewVettingCard(
        manifest.communityDid,
        vetterDid,
      );
      final held = {
        for (final claim in preview.claims)
          if (claim.value != null) claim.type,
      };
      final session = state.vetting?.requestTo(vetterDid)?.session;
      final required = switch (session?['payload']) {
        {'requiredClaims': final List<dynamic> claims} => claims,
        _ => const <dynamic>[],
      };
      final missing = [
        for (final type in required.whereType<String>())
          if (!held.contains(type)) type,
      ];
      if (missing.isNotEmpty) {
        // Claim types only, never a value.
        ref
            .read(appLoggerProvider)
            .warning(
              'Vetting card: the VTA holds ${held.toList()..sort()}, '
              'the session asks for $required',
              name: 'VtcJoinController',
            );
        state = state.copyWith(
          missingDetails: missing,
          applyingIdentityName: await _applyingIdentityName(
            manifest.communityDid,
          ),
        );
        return _fail(VtcJoinFailure.detailsMissing);
      }
      _vettingPreview = preview;
      state = state.copyWith(
        step: VtcJoinStep.approveVettingCard,
        vettingWork: null,
        details: [
          for (final claim in preview.claims)
            if (claim.value case final Object value)
              VtcJoinDetail(type: claim.type, value: _shown(value)),
        ],
      );
    });
  }

  /// The name of the identity applying to [communityDid], as the member's
  /// identities show it, or null when it is none of them.
  Future<String?> _applyingIdentityName(String communityDid) async {
    final personaDid = (await _service.community(communityDid))?.personaDid;
    final name = ref
        .read(identitiesServiceProvider)
        .vtaPersonas
        .where((identity) => identity.did == personaDid)
        .firstOrNull
        ?.card
        .displayName
        .trim();
    return name == null || name.isEmpty ? null : name;
  }

  /// Sends the vetter the card with the details the member approved.
  Future<void> approveVettingCard() async {
    final manifest = _manifest;
    final vetterDid = state.vetterDid;
    final preview = _vettingPreview;
    if (state.step != VtcJoinStep.approveVettingCard ||
        manifest == null ||
        vetterDid == null ||
        preview == null) {
      return;
    }
    state = state.copyWith(
      step: VtcJoinStep.working,
      vettingWork: VtcVettingWork.recordingDisclosure,
    );
    _vettingPreview = null;
    await _run(() async {
      _showVetting(
        await _service.sendVettingCard(
          manifest.communityDid,
          vetterDid,
          preview: preview,
          onStep: _showWork,
        ),
      );
    });
  }

  /// Ends the session at hand without sending a card: the match codes
  /// differ, or the member declines.
  Future<void> declineSession() async {
    final manifest = _manifest;
    final vetterDid = state.vetterDid;
    if ((state.step != VtcJoinStep.confirmMatch &&
            state.step != VtcJoinStep.approveVettingCard) ||
        manifest == null ||
        vetterDid == null) {
      return;
    }
    _vettingPreview = null;
    state = state.copyWith(step: VtcJoinStep.working);
    await _run(
      () async => _showVetting(
        await _service.abandonVetting(manifest.communityDid, vetterDid),
      ),
    );
  }

  /// Applies with the statements gathered, once they meet what the
  /// community asks.
  Future<void> sendVettedApplication() async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.vetting ||
        manifest == null ||
        !(state.vettingProgress?.satisfied ?? false)) {
      return;
    }
    state = state.copyWith(
      step: VtcJoinStep.working,
      flowVetterDid: null,
      vettingWork: null,
    );
    _sendingVetted = true;
    await _run(() => _apply(manifest));
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
      final status = await _service.checkApplication(
        manifest.communityDid,
        onCardDelivery: _showCardDelivery,
      );
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

  /// Collects the member's card from their identity's inbox when the
  /// community delivered it there, showing each step, then reads it from
  /// their VTA. Quietly, as [checkAgain]: a collection that fails waits for
  /// the next.
  Future<void> collectMembershipCard() async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.joined ||
        manifest == null ||
        state.membershipCard != null ||
        _collectingCard) {
      return;
    }
    _collectingCard = true;
    _showGettingCard();
    try {
      await _service.checkApplication(
        manifest.communityDid,
        onCardDelivery: _showCardDelivery,
        onCardStep: _showCardStep,
      );
    } on MeetingPlaceVtcSDKException {
      // The next collection tries again.
    } on VtaNotLinkedException {
      // Nothing to collect with; the membership stands all the same.
    } finally {
      _collectingCard = false;
    }
    if (!ref.mounted) return;
    _showGettingCard();
    await readMembershipCard();
    // The community delivers the role card with the membership card.
    if (ref.mounted) await readRole();
  }

  /// Reads the member's role in the community for the community page from
  /// their VTA, which the community delivers its role card to. Only reads,
  /// and quietly: a read that finds no role keeps the one shown.
  Future<void> readRole() async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.joined || manifest == null || _readingRole) {
      return;
    }
    _readingRole = true;
    try {
      final role = await _service.communityRole(manifest.communityDid);
      // The screen may have closed, or moved on, while the VTA answered.
      if (!ref.mounted) return;
      if (role != null && state.step == VtcJoinStep.joined) {
        state = state.copyWith(role: role);
      }
    } on MeetingPlaceVtcSDKException {
      // The next read tries again.
    } on VtaNotLinkedException {
      // Nothing to read from; the membership stands all the same.
    } finally {
      _readingRole = false;
    }
  }

  /// Asks the community for the member's current role, which may have
  /// changed since their VTA last heard, e.g. after an administrator
  /// promoted them. A changed role is kept on the VTA, and [readRole] reads
  /// it from there. Quietly: a community that cannot be reached leaves the
  /// role shown as it was.
  Future<void> refreshRole() async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.joined || manifest == null) return;
    try {
      await _service.refreshMembership(manifest.communityDid);
    } on MeetingPlaceVtcSDKException {
      // The role shown stands until the next refresh.
    } on VtaNotLinkedException {
      // Nothing to refresh with; the membership stands all the same.
    }
  }

  /// Reads the community's own check of the member's identity for the
  /// joined screen from their VTA, which the community delivers it to. Only
  /// reads, and quietly: a member the community never checked has none.
  Future<void> readIdentityCheck() async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.joined ||
        manifest == null ||
        state.identityCheck != null ||
        _readingCheck) {
      return;
    }
    _readingCheck = true;
    try {
      final check = await _service.identityCheck(manifest.communityDid);
      // The screen may have closed, or moved on, while the VTA answered.
      if (!ref.mounted) return;
      if (check != null && state.step == VtcJoinStep.joined) {
        state = state.copyWith(identityCheck: check);
      }
    } on MeetingPlaceVtcSDKException {
      // Shown on the next visit.
    } on VtaNotLinkedException {
      // Nothing to read from; the membership stands all the same.
    } finally {
      _readingCheck = false;
    }
  }

  void _showCardDelivery(VtcCardDelivery delivery) {
    // The screen may have closed while the card was collected.
    if (!ref.mounted) return;
    state = state.copyWith(
      cardDelivery: delivery,
      // Shown once the VTA keeps it, before the community confirms it.
      membershipCard:
          state.membershipCard ??
          switch (delivery.card) {
            final card? => VtcMembershipCard.fromCredential(card),
            null => null,
          },
    );
  }

  /// Reads the member's card for the joined screen from their VTA, which
  /// the community delivers it to; an approval already asked for it again
  /// when the VTA held none. Only reads, and quietly: a read that finds no
  /// card or fails waits for the next.
  Future<void> readMembershipCard() async {
    final manifest = _manifest;
    if (state.step != VtcJoinStep.joined ||
        manifest == null ||
        state.membershipCard != null ||
        _readingCard) {
      return;
    }
    _readingCard = true;
    _showGettingCard();
    try {
      final card = await _service.membershipCard(
        manifest.communityDid,
        onStep: _showCardStep,
      );
      // The screen may have closed, or moved on, while the VTA answered.
      if (!ref.mounted) return;
      if (card != null && state.step == VtcJoinStep.joined) {
        state = state.copyWith(membershipCard: card);
      }
    } on MeetingPlaceVtcSDKException {
      // The next read tries again.
    } on VtaNotLinkedException {
      // Nothing to read from; the membership stands all the same.
    } finally {
      _readingCard = false;
      if (ref.mounted) _showGettingCard();
    }
  }

  /// Shows whether the card is being read or collected right now; how far
  /// only while it is.
  void _showGettingCard() {
    final gettingCard = _readingCard || _collectingCard;
    state = state.copyWith(
      gettingCard: gettingCard,
      cardStep: gettingCard ? state.cardStep : null,
    );
  }

  void _showCardStep(MembershipCardStep step) {
    // The screen may have closed while the VTA answered.
    if (!ref.mounted) return;
    state = state.copyWith(cardStep: step);
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

  /// The DID [code] names: the code itself when it is a DID, else the
  /// community whose join phrase it is. Text that is neither is refused
  /// before any network call.
  Future<String> _communityDidOf(String code) async {
    final trimmed = code.trim();
    if (trimmed.startsWith('did:')) return trimmed;
    if (!CommunityOfferService.isPhrase(trimmed)) {
      throw const InvalidCommunityCodeException();
    }
    return ref.read(communityOfferServiceProvider).findCommunity(trimmed);
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
    } on VettingException catch (error) {
      // Not logged: only what failed, which the overview shows.
      if (state.vetting case final vetting?) {
        _showVetting(vetting, failure: error.failure);
      } else {
        _fail(VtcJoinFailure.badAnswer);
      }
    } on InvalidCommunityCodeException {
      _fail(VtcJoinFailure.invalidCode);
    } on VtaNotLinkedException {
      _fail(VtcJoinFailure.vtaMissing);
    } on CommunityPhraseException catch (error) {
      _fail(switch (error.problem) {
        CommunityPhraseProblem.notFound => VtcJoinFailure.phraseNotFound,
        CommunityPhraseProblem.expired => VtcJoinFailure.phraseExpired,
      });
    } on MeetingPlaceCoreSDKException catch (error, stackTrace) {
      ref
          .read(appLoggerProvider)
          .error(
            'Looking up the join phrase failed: ${error.code}',
            stackTrace: stackTrace,
            name: 'VtcJoinController',
          );
      _fail(VtcJoinFailure.unreachable);
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
    state = state.copyWith(
      step: VtcJoinStep.failed,
      failure: failure,
      flowVetterDid: null,
      vettingWork: null,
    );
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
