import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../domain/models/vtc/vtc_card_delivery.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_icons.dart';
import 'vtc_trail_step.dart';

/// How a new member's card came from their identity's inbox to their VTA,
/// drawn as a trail: the keys the VTA lent, the inbox signed in to, the card
/// picked up there, kept on the VTA, and the membership confirmed. Each step
/// opens to its facts, and the picked-up card's signed delivery shows in
/// full. Shows key ids only, never key material.
class VtcCardDeliveryTrail extends StatelessWidget {
  const VtcCardDeliveryTrail({
    super.key,
    required this.delivery,
    required this.communityName,
  });

  final VtcCardDelivery delivery;
  final String communityName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String time(DateTime at) =>
        DateFormat.yMMMd(l10n.localeName).add_Hm().format(at.toLocal());
    final issue = delivery.issue;
    final proof = switch (issue?.toJson()['proof']) {
      final Map<String, dynamic> proof => proof,
      _ => const <String, dynamic>{},
    };

    /// The summary of [step]: [done] once it is, else what holds it up.
    String summary(
      VtcDeliveryStep step, {
      required String done,
      String? failed,
      String? waiting,
    }) => switch (delivery.status(step)) {
      VtcDeliveryStatus.done => done,
      VtcDeliveryStatus.failed => failed ?? done,
      VtcDeliveryStatus.waiting => waiting ?? done,
      VtcDeliveryStatus.working => done,
      VtcDeliveryStatus.next => l10n.vtcDeliveryNext,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VtcTrailStep(
          key: const Key('vtc_delivery_keys'),
          icon: McIcons.key,
          stage: _stage(VtcDeliveryStep.keysLent),
          busy: _isBusy(VtcDeliveryStep.keysLent),
          title: l10n.vtcDeliveryKeysLent,
          summary: summary(
            VtcDeliveryStep.keysLent,
            done: l10n.vtcDeliveryKeysLentSummary,
            failed: l10n.vtcDeliveryKeysFailed,
          ),
          tasks: const [VtaTask.exportSecret],
          details: [
            VtcTrailDetail(
              McIcons.identities,
              l10n.vtcJoinTrailIdentity,
              delivery.personaDid,
              isId: true,
            ),
            if (delivery.signingKeyId case final id?)
              VtcTrailDetail(
                McIcons.signature,
                l10n.vtcJoinTrailKey,
                id,
                isId: true,
              ),
            if (delivery.keyAgreementKeyId case final id?)
              VtcTrailDetail(
                McIcons.lock,
                l10n.vtcDeliveryKeyAgreementKey,
                id,
                isId: true,
              ),
          ],
        ),
        VtcTrailStep(
          key: const Key('vtc_delivery_inbox'),
          icon: McIcons.inbox,
          stage: _stage(VtcDeliveryStep.signedIn),
          busy: _isBusy(VtcDeliveryStep.signedIn),
          title: l10n.vtcDeliverySignedIn,
          summary: summary(
            VtcDeliveryStep.signedIn,
            done: l10n.vtcDeliveryWaitingMessages(delivery.waiting ?? 0),
            failed: l10n.vtcDeliverySignedInFailed,
          ),
          details: [
            // Said outright, so a step without one is not mistaken for a
            // gap in the trail.
            VtcTrailDetail(
              McIcons.clipboard,
              l10n.vtcJoinTrailTask,
              l10n.vtcDeliveryInboxNoTask,
            ),
            if (delivery.mediatorDid case final did?)
              VtcTrailDetail(
                McIcons.hub,
                l10n.vtcDeliveryMediator,
                did,
                isId: true,
              ),
          ],
        ),
        VtcTrailStep(
          key: const Key('vtc_delivery_pickup'),
          icon: McIcons.emailRead,
          stage: _stage(VtcDeliveryStep.pickedUp),
          busy: _isBusy(VtcDeliveryStep.pickedUp),
          title: l10n.vtcDeliveryPickedUp(communityName),
          summary: summary(
            VtcDeliveryStep.pickedUp,
            done: l10n.vtcDeliveryPickedUpSummary(communityName),
            waiting: l10n.vtcDeliveryWaiting(communityName),
          ),
          tasks: [issue?.type ?? credentialIssueTask],
          details: [
            if (issue != null) ...[
              VtcTrailDetail(
                McIcons.community,
                l10n.vtcDeliverySentBy,
                issue.issuer,
                isId: true,
              ),
              if (proof['cryptosuite'] case final String cryptosuite)
                VtcTrailDetail(
                  McIcons.encrypted,
                  l10n.vtcJoinTrailCryptosuite,
                  cryptosuite,
                ),
              if (proof['verificationMethod'] case final String key)
                VtcTrailDetail(
                  McIcons.key,
                  l10n.vtcJoinTrailKey,
                  key,
                  isId: true,
                ),
              if (DateTime.tryParse('${proof['created']}') case final at?)
                VtcTrailDetail(
                  McIcons.clock,
                  l10n.vtcJoinTrailSignedAt,
                  time(at),
                ),
            ],
          ],
          document: issue?.toJson(),
          documentTitle: l10n.vtcDeliveryIssueDocument,
          documentKey: const Key('vtc_delivery_pickup_document'),
        ),
        VtcTrailStep(
          key: const Key('vtc_delivery_kept'),
          icon: McIcons.cloudDone,
          stage: _stage(VtcDeliveryStep.kept),
          busy: _isBusy(VtcDeliveryStep.kept),
          title: l10n.vtcDeliveryKept,
          summary: summary(
            VtcDeliveryStep.kept,
            done: delivery.isKeptAsValid == false
                ? l10n.vtcDeliveryKeptInvalid
                : l10n.vtcDeliveryKeptSummary,
            failed: l10n.vtcDeliveryKeptFailed,
          ),
          tasks: const [VtaTask.credentialsReceive],
        ),
        VtcTrailStep(
          key: const Key('vtc_delivery_confirmed'),
          icon: McIcons.verified,
          stage: _stage(VtcDeliveryStep.confirmed),
          busy: _isBusy(VtcDeliveryStep.confirmed),
          title: l10n.vtcDeliveryConfirmed(communityName),
          summary: summary(
            VtcDeliveryStep.confirmed,
            done: l10n.vtcDeliveryConfirmedSummary,
            failed: l10n.vtcDeliveryConfirmedFailed,
          ),
          // The VTA signs the member's own membership credential, which the
          // community is then sent.
          tasks: const [VtaTask.signDocument, MemberTask.vmc],
          isLast: true,
        ),
      ],
    );
  }

  VtcTrailStage _stage(VtcDeliveryStep step) => switch (delivery.status(step)) {
    VtcDeliveryStatus.done => VtcTrailStage.done,
    VtcDeliveryStatus.working ||
    VtcDeliveryStatus.waiting => VtcTrailStage.current,
    VtcDeliveryStatus.failed => VtcTrailStage.failed,
    VtcDeliveryStatus.next => VtcTrailStage.next,
  };

  /// Whether [step]'s marker turns: while it is worked on or waited for.
  bool _isBusy(VtcDeliveryStep step) => switch (delivery.status(step)) {
    VtcDeliveryStatus.working || VtcDeliveryStatus.waiting => true,
    _ => false,
  };
}
