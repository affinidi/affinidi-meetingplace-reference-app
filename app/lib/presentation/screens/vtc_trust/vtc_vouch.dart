import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../vtc_join/vtc_flow_diagram.dart';
import '../vtc_join/vtc_trail_step.dart';

/// What [failure] means to the member, about [name] in [community].
String vtcTrustFailureMessage(
  AppLocalizations l10n,
  VtcTrustFailure failure, {
  required String community,
  required String name,
}) => l10n.vtcTrustFailure(failure.name, community, name);

/// Vouches for [name], the member [personaDid] of [communityDid], once the
/// member consents: tells what members of [communityName] will see, then
/// shows what happened, or why it did not.
///
/// Returns the vouch, or null when the member did not consent or it failed.
Future<PublishedRelationship?> vouchWithConsent(
  BuildContext context,
  WidgetRef ref, {
  required String communityDid,
  required String communityName,
  required String personaDid,
  required String name,
}) async {
  final l10n = context.l10n;
  final consented = await _confirm(
    context,
    key: const Key('vtc_vouch_consent'),
    title: l10n.vtcTrustConsentTitle(name, communityName),
    message: l10n.vtcTrustConsentMessage(name, communityName),
    action: l10n.vtcTrustVouch,
  );
  if (!consented || !context.mounted) return null;

  try {
    final edge = await ref
        .read(vtcTrustServiceProvider)
        .vouch(communityDid, personaDid: personaDid);
    if (context.mounted) {
      await showVouchTrail(
        context,
        edge: edge,
        communityName: communityName,
        name: name,
        isOwn: true,
      );
    }
    return edge;
  } on VtcTrustException catch (error) {
    if (context.mounted) {
      _tell(
        context,
        vtcTrustFailureMessage(
          l10n,
          error.failure,
          community: communityName,
          name: name,
        ),
      );
    }
    return null;
  }
}

/// Withdraws [edge], the member's vouch for [name] in [communityDid], once
/// the member confirms. Returns whether it was withdrawn.
Future<bool> withdrawWithConfirmation(
  BuildContext context,
  WidgetRef ref, {
  required String communityDid,
  required String communityName,
  required String name,
  required PublishedRelationship edge,
}) async {
  final l10n = context.l10n;
  final confirmed = await _confirm(
    context,
    key: const Key('vtc_vouch_withdraw'),
    title: l10n.vtcTrustWithdrawTitle(name, communityName),
    message: l10n.vtcTrustWithdrawMessage,
    action: l10n.vtcTrustWithdraw,
    isDestructive: true,
  );
  if (!confirmed || !context.mounted) return false;

  try {
    await ref.read(vtcTrustServiceProvider).withdraw(communityDid, edge);
    return true;
  } on VtcTrustException catch (error) {
    if (context.mounted) {
      _tell(
        context,
        vtcTrustFailureMessage(
          l10n,
          error.failure,
          community: communityName,
          name: name,
        ),
      );
    }
    return false;
  }
}

/// Shows the story of [edge], a vouch between the member and [name] in
/// [communityName], as [VtcVouchTrail] draws it: the member's own when
/// [isOwn], else [name]'s for the member.
Future<void> showVouchTrail(
  BuildContext context, {
  required PublishedRelationship edge,
  required String communityName,
  required String name,
  required bool isOwn,
}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: VtcVouchTrail(
      edge: edge,
      communityName: communityName,
      name: name,
      isOwn: isOwn,
    ),
  ),
);

/// A vouch as steps, each pictured once opened as the membership card's
/// steps are: who vouched for whom, the VTA signing it as the voucher's
/// identity in the community, and the community keeping it where its
/// members see it. The signed vouch and the community's record of it open
/// in full from their steps.
///
/// [isOwn] tells the member's vouch for [name] from [name]'s for them.
class VtcVouchTrail extends StatelessWidget {
  const VtcVouchTrail({
    super.key,
    required this.edge,
    required this.communityName,
    required this.name,
    required this.isOwn,
  });

  final PublishedRelationship edge;
  final String communityName;
  final String name;
  final bool isOwn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String time(DateTime at) =>
        DateFormat.yMMMd(l10n.localeName).add_Hm().format(at.toLocal());
    final vrc = edge.vrc ?? const <String, dynamic>{};
    final proof = switch (vrc['proof']) {
      final Map<String, dynamic> proof => proof,
      _ => const <String, dynamic>{},
    };
    final validFrom = DateTime.tryParse('${vrc['validFrom']}');
    final you = l10n.vtcVouchTrailYou;
    final voucher = isOwn ? you : name;
    final vouchedFor = isOwn ? name : you;
    final voucherNode = VtcFlowNode(Icons.person_outline, voucher);
    final vouchedForNode = VtcFlowNode(Icons.person_outline, vouchedFor);
    final vtaNode = VtcFlowNode(
      Icons.shield_outlined,
      isOwn ? l10n.membershipTrailYourVta : l10n.vtcVouchTrailTheirVta(name),
    );
    final communityNode = VtcFlowNode(Icons.groups_outlined, communityName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(
          isOwn ? l10n.vtcTrustDoneTitle(name) : l10n.vtcTrustTheyVouched(name),
          style: context.textTheme.titleLarge,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VtcTrailStep(
              key: const Key('vtc_vouch_vouched'),
              icon: Icons.handshake_outlined,
              stage: VtcTrailStage.done,
              title: l10n.vtcVouchTrailTheVouch,
              flow: VtcFlowDiagram(
                key: const Key('vtc_vouch_flow_vouched'),
                nodes: [voucherNode, vouchedForNode],
              ),
              summary: validFrom == null
                  ? l10n.vtcVouchTrailIn(communityName)
                  : l10n.vtcVouchTrailValidFrom(communityName, time(validFrom)),
              highlights: [communityName],
              details: [
                VtcTrailDetail(
                  Icons.person_outline,
                  l10n.vtcJoinTrailIdentity,
                  edge.issuerDid,
                  isId: true,
                ),
                VtcTrailDetail(
                  Icons.person_pin_outlined,
                  l10n.vtcVouchTrailVouchedFor,
                  edge.subjectDid,
                  isId: true,
                ),
              ],
            ),
            VtcTrailStep(
              key: const Key('vtc_vouch_signed'),
              icon: Icons.draw_outlined,
              stage: VtcTrailStage.done,
              title: isOwn
                  ? l10n.vtcTrustSigned
                  : l10n.vtcVouchTrailSignedByTheirVta(name),
              flow: VtcFlowDiagram(
                key: const Key('vtc_vouch_flow_signed'),
                nodes: [vtaNode, voucherNode],
              ),
              summary: isOwn
                  ? l10n.vtcTrustSignedSummary(communityName)
                  : l10n.vtcVouchTrailSignedTheirSummary(name, communityName),
              highlights: [communityName],
              details: [
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
              document: edge.vrc,
              documentTitle: l10n.vtcTrustVouchDocument,
              documentKey: const Key('vtc_vouch_document'),
            ),
            VtcTrailStep(
              key: const Key('vtc_vouch_stored'),
              icon: Icons.groups_outlined,
              stage: VtcTrailStage.done,
              title: l10n.vtcTrustStored(communityName),
              flow: VtcFlowDiagram(
                key: const Key('vtc_vouch_flow_stored'),
                nodes: [voucherNode, communityNode],
              ),
              summary: l10n.vtcVouchTrailStoredSummary(communityName),
              highlights: [communityName],
              details: [
                VtcTrailDetail(
                  Icons.tag,
                  l10n.vtcVouchTrailRecord,
                  edge.id,
                  isId: true,
                ),
                if (edge.createdAt case final at?)
                  VtcTrailDetail(
                    Icons.schedule,
                    l10n.vtcVouchTrailStoredAt,
                    time(at),
                  ),
              ],
              document: edge.toJson(),
              documentTitle: l10n.vtcTrustRecordDocument(communityName),
              documentKey: const Key('vtc_vouch_record'),
              isLast: true,
            ),
          ],
        ),
      ],
    );
  }
}

/// A handshake beside [name] when the member and [name] vouched for one
/// another in [communityName], either way round; nothing otherwise. It
/// opens the story of each vouch ([showVouches]).
class VtcVouchButton extends StatelessWidget {
  const VtcVouchButton({
    super.key,
    required this.edges,
    required this.name,
    required this.communityName,
  });

  final VtcEdges edges;
  final String name;
  final String communityName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tooltip = switch ((edges.outgoing, edges.incoming)) {
      (null, null) => null,
      (_?, _?) => l10n.vtcTrustVouchedForEachOther(name),
      (_?, null) => l10n.vtcTrustDoneTitle(name),
      (null, _?) => l10n.vtcTrustTheyVouched(name),
    };
    if (tooltip == null) return const SizedBox.shrink();
    return IconButton(
      key: const Key('vtc_vouches'),
      icon: const Icon(Icons.handshake_outlined, size: 20),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: () => showVouches(
        context,
        edges: edges,
        communityName: communityName,
        name: name,
      ),
    );
  }
}

/// Shows the story of each vouch in [edges] between the member and [name]
/// in [communityName], the member's own first, as [VtcVouchTrail] draws it.
Future<void> showVouches(
  BuildContext context, {
  required VtcEdges edges,
  required String communityName,
  required String name,
}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        if (edges.outgoing case final edge?)
          VtcVouchTrail(
            key: const Key('vtc_vouch_trail_outgoing'),
            edge: edge,
            communityName: communityName,
            name: name,
            isOwn: true,
          ),
        if (edges.incoming case final edge?)
          VtcVouchTrail(
            key: const Key('vtc_vouch_trail_incoming'),
            edge: edge,
            communityName: communityName,
            name: name,
            isOwn: false,
          ),
      ],
    ),
  ),
);

Future<bool> _confirm(
  BuildContext context, {
  required Key key,
  required String title,
  required String message,
  required String action,
  bool isDestructive = false,
}) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      key: key,
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.generalCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? ElevatedButton.styleFrom(
                  backgroundColor: context.colorScheme.error,
                  foregroundColor: Colors.white,
                )
              : null,
          child: Text(action),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

void _tell(BuildContext context, String message) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(message)));
