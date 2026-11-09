import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../vtc_join/vtc_join_json_dialog.dart';
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
      await showModalBottomSheet<void>(
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
          ),
        ),
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

/// What vouching did, as steps the member follows: their VTA signed the
/// vouch as their identity in the community, and the community keeps it
/// where its members see it. The signed vouch opens in full.
class VtcVouchTrail extends StatelessWidget {
  const VtcVouchTrail({
    super.key,
    required this.edge,
    required this.communityName,
    required this.name,
  });

  final PublishedRelationship edge;
  final String communityName;
  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(l10n.vtcTrustDoneTitle(name), style: context.textTheme.titleLarge),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VtcTrailStep(
              key: const Key('vtc_vouch_signed'),
              icon: Icons.draw_outlined,
              stage: VtcTrailStage.done,
              title: l10n.vtcTrustSigned,
              summary: l10n.vtcTrustSignedSummary(communityName),
              details: [
                VtcTrailDetail(
                  Icons.fingerprint,
                  l10n.vtcJoinTrailIdentity,
                  edge.issuerDid,
                  isId: true,
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
              summary: l10n.vtcTrustStoredSummary(communityName, name),
              isLast: true,
            ),
          ],
        ),
      ],
    );
  }
}

/// The vouches between the member and [name], one chip each way round,
/// labelled [outgoingLabel] and [incomingLabel]. A chip opens the signed
/// credential the community keeps for that vouch.
class VtcVouchChips extends StatelessWidget {
  const VtcVouchChips({
    super.key,
    required this.edges,
    required this.name,
    required this.outgoingLabel,
    required this.incomingLabel,
  });

  final VtcEdges edges;
  final String name;
  final String outgoingLabel;
  final String incomingLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (edges.outgoing case final edge?)
          _chip(
            context,
            key: const Key('vtc_vouch_outgoing'),
            label: outgoingLabel,
            title: l10n.vtcTrustYourVouchDocument(name),
            edge: edge,
          ),
        if (edges.incoming case final edge?)
          _chip(
            context,
            key: const Key('vtc_vouch_incoming'),
            label: incomingLabel,
            title: l10n.vtcTrustTheirVouchDocument(name),
            edge: edge,
          ),
      ],
    );
  }

  static Widget _chip(
    BuildContext context, {
    required Key key,
    required String label,
    required String title,
    required PublishedRelationship edge,
  }) {
    final vrc = edge.vrc;
    return ActionChip(
      key: key,
      avatar: const Icon(Icons.handshake_outlined, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      onPressed: vrc == null
          ? null
          : () => showVtcJoinJson(
              context,
              title: title,
              json: vrc,
              icon: Icons.handshake_outlined,
              textKey: const Key('vtc_vouch_json'),
            ),
    );
  }
}

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
