import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../domain/models/vtc/vtc_card_delivery.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
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
          icon: Icons.key_outlined,
          stage: _stage(VtcDeliveryStep.keysLent),
          busy: _isBusy(VtcDeliveryStep.keysLent),
          title: l10n.vtcDeliveryKeysLent,
          summary: summary(
            VtcDeliveryStep.keysLent,
            done: l10n.vtcDeliveryKeysLentSummary,
            failed: l10n.vtcDeliveryKeysFailed,
          ),
          details: [
            VtcTrailDetail(
              Icons.fingerprint,
              l10n.vtcJoinTrailIdentity,
              delivery.personaDid,
              isId: true,
            ),
            if (delivery.signingKeyId case final id?)
              VtcTrailDetail(
                Icons.draw_outlined,
                l10n.vtcJoinTrailKey,
                id,
                isId: true,
              ),
            if (delivery.keyAgreementKeyId case final id?)
              VtcTrailDetail(
                Icons.lock_outline,
                l10n.vtcDeliveryKeyAgreementKey,
                id,
                isId: true,
              ),
          ],
        ),
        VtcTrailStep(
          key: const Key('vtc_delivery_inbox'),
          icon: Icons.inbox_outlined,
          stage: _stage(VtcDeliveryStep.signedIn),
          busy: _isBusy(VtcDeliveryStep.signedIn),
          title: l10n.vtcDeliverySignedIn,
          summary: summary(
            VtcDeliveryStep.signedIn,
            done: l10n.vtcDeliveryWaitingMessages(delivery.waiting ?? 0),
            failed: l10n.vtcDeliverySignedInFailed,
          ),
          details: [
            if (delivery.mediatorDid case final did?)
              VtcTrailDetail(
                Icons.hub_outlined,
                l10n.vtcDeliveryMediator,
                did,
                isId: true,
              ),
          ],
        ),
        VtcTrailStep(
          key: const Key('vtc_delivery_pickup'),
          icon: Icons.mark_email_read_outlined,
          stage: _stage(VtcDeliveryStep.pickedUp),
          busy: _isBusy(VtcDeliveryStep.pickedUp),
          title: l10n.vtcDeliveryPickedUp(communityName),
          summary: summary(
            VtcDeliveryStep.pickedUp,
            done: l10n.vtcDeliveryPickedUpSummary(communityName),
            waiting: l10n.vtcDeliveryWaiting(communityName),
          ),
          details: [
            if (issue != null) ...[
              VtcTrailDetail(
                Icons.groups_outlined,
                l10n.vtcDeliverySentBy,
                issue.issuer,
                isId: true,
              ),
              VtcTrailDetail(
                Icons.assignment_outlined,
                l10n.vtcJoinTrailTask,
                issue.type,
              ),
              if (proof['cryptosuite'] case final String cryptosuite)
                VtcTrailDetail(
                  Icons.enhanced_encryption_outlined,
                  l10n.vtcJoinTrailCryptosuite,
                  cryptosuite,
                ),
              if (proof['verificationMethod'] case final String key)
                VtcTrailDetail(
                  Icons.key_outlined,
                  l10n.vtcJoinTrailKey,
                  key,
                  isId: true,
                ),
              if (DateTime.tryParse('${proof['created']}') case final at?)
                VtcTrailDetail(
                  Icons.schedule,
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
          icon: Icons.cloud_done_outlined,
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
        ),
        VtcTrailStep(
          key: const Key('vtc_delivery_confirmed'),
          icon: Icons.verified_outlined,
          stage: _stage(VtcDeliveryStep.confirmed),
          busy: _isBusy(VtcDeliveryStep.confirmed),
          title: l10n.vtcDeliveryConfirmed(communityName),
          summary: summary(
            VtcDeliveryStep.confirmed,
            done: l10n.vtcDeliveryConfirmedSummary,
            failed: l10n.vtcDeliveryConfirmedFailed,
          ),
          details: [
            if (delivery.status(VtcDeliveryStep.confirmed) ==
                VtcDeliveryStatus.done)
              VtcTrailDetail(
                Icons.assignment_outlined,
                l10n.vtcJoinTrailTask,
                MemberTask.vmc,
              ),
          ],
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
