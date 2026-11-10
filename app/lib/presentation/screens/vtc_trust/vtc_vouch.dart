import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
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
  DirectoryEntry? entry,
  String? entryId,
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
    final edge = await _whileWorking(
      context,
      title: l10n.vtcTrustVouching(name),
      detail: l10n.vtcTrustVouchingDetail(communityName),
      () => ref
          .read(vtcTrustServiceProvider)
          .vouch(communityDid, personaDid: personaDid),
    );
    if (context.mounted) {
      await showVouchTrail(
        context,
        edge: edge,
        communityDid: communityDid,
        communityName: communityName,
        name: name,
        isOwn: true,
        entry: entry,
        entryId: entryId,
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
/// the member confirms, then says it is done. Returns whether it was
/// withdrawn.
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
    await _whileWorking(
      context,
      title: l10n.vtcTrustWithdrawing(name),
      detail: l10n.vtcTrustWithdrawingDetail(communityName),
      () => ref.read(vtcTrustServiceProvider).withdraw(communityDid, edge),
    );
    if (context.mounted) _tell(context, l10n.vtcTrustWithdrawn(name));
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
  required String communityDid,
  required String communityName,
  required String name,
  required bool isOwn,
  DirectoryEntry? entry,
  String? entryId,
}) => showOnboardingSheet(
  context,
  VtcVouchTrail(
    edge: edge,
    communityDid: communityDid,
    communityName: communityName,
    name: name,
    isOwn: isOwn,
    entry: entry,
    entryId: entryId,
  ),
);

/// A vouch as steps, each pictured once opened as the membership card's
/// steps are: who vouched for whom, the VTA signing it as the voucher's
/// identity in the community, and the community keeping it where its
/// members see it. The signed vouch and the community's record of it open
/// in full from their steps.
///
/// [isOwn] tells the member's vouch for [name] from [name]'s for them. The
/// two are drawn by their pictures where they show one: the member's of the
/// identity they joined with, [name]'s from their [entry] in the directory,
/// or the entry [entryId] names.
class VtcVouchTrail extends HookConsumerWidget {
  const VtcVouchTrail({
    super.key,
    required this.edge,
    required this.communityName,
    required this.name,
    required this.isOwn,
    this.communityDid,
    this.entry,
    this.entryId,
  });

  final PublishedRelationship edge;
  final String communityName;
  final String name;
  final bool isOwn;

  /// The community, to fetch pictures from; none are drawn without it.
  final String? communityDid;

  /// [name]'s directory entry, which names their picture.
  final DirectoryEntry? entry;

  /// The id of [name]'s directory entry, read when [entry] is not given.
  final String? entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final (yours, theirs) = _usePictures(ref);
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
    final voucherNode = VtcFlowNode(
      McIcons.person,
      voucher,
      picture: isOwn ? yours : theirs,
    );
    final vouchedForNode = VtcFlowNode(
      McIcons.person,
      vouchedFor,
      picture: isOwn ? theirs : yours,
    );
    final vtaNode = VtcFlowNode(
      McIcons.shield,
      isOwn ? l10n.membershipTrailYourVta : l10n.vtcVouchTrailTheirVta(name),
    );
    final communityNode = VtcFlowNode(McIcons.community, communityName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(
          isOwn ? l10n.vtcTrustDoneTitle(name) : l10n.vtcTrustTheyVouched(name),
          style: context.textTheme.titleLarge?.copyWith(
            color: context.mcColors.textPrimary,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VtcTrailStep(
              key: const Key('vtc_vouch_vouched'),
              icon: McIcons.handshake,
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
                  McIcons.person,
                  l10n.vtcJoinTrailIdentity,
                  edge.issuerDid,
                  isId: true,
                ),
                VtcTrailDetail(
                  McIcons.person,
                  l10n.vtcVouchTrailVouchedFor,
                  edge.subjectDid,
                  isId: true,
                ),
              ],
            ),
            VtcTrailStep(
              key: const Key('vtc_vouch_signed'),
              icon: McIcons.signature,
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
              tasks: const [VtaTask.signDocument],
              details: [
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
              document: edge.vrc,
              documentTitle: l10n.vtcTrustVouchDocument,
              documentKey: const Key('vtc_vouch_document'),
            ),
            VtcTrailStep(
              key: const Key('vtc_vouch_stored'),
              icon: McIcons.community,
              stage: VtcTrailStage.done,
              title: l10n.vtcTrustStored(communityName),
              flow: VtcFlowDiagram(
                key: const Key('vtc_vouch_flow_stored'),
                nodes: [voucherNode, communityNode],
              ),
              summary: l10n.vtcVouchTrailStoredSummary(communityName),
              highlights: [communityName],
              tasks: const [RelationshipTask.publish],
              details: [
                VtcTrailDetail(
                  McIcons.tag,
                  l10n.vtcVouchTrailRecord,
                  edge.id,
                  isId: true,
                ),
                if (edge.createdAt case final at?)
                  VtcTrailDetail(
                    McIcons.clock,
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

  /// The member's picture and [name]'s, each null until it arrives, or
  /// when there is none.
  (ImageProvider?, ImageProvider?) _usePictures(WidgetRef ref) {
    final communityDid = this.communityDid;
    final service = ref.read(vtcTrustServiceProvider);
    final identities = ref.watch(identitiesServiceProvider);
    final yours = useFuture(
      useMemoized(() async {
        if (communityDid == null) return null;
        final contextId = await service.identityContextId(communityDid);
        final picture = identities.vtaPersonaIn(contextId)?.card.profilePic;
        return picture == null ? null : MemoryImage(base64Decode(picture));
      }, [communityDid, identities]),
    ).data;
    final theirs = useFuture(
      useMemoized(() async {
        if (communityDid == null) return null;
        final shown =
            entry ??
            switch (entryId) {
              final id? => await service.memberEntry(communityDid, entryId: id),
              null => null,
            };
        if (shown == null) return null;
        final picture = await service.memberPicture(communityDid, entry: shown);
        return picture == null ? null : MemoryImage(picture);
      }, [communityDid, entry?.avatarSha256, entryId]),
    ).data;
    return (yours, theirs);
  }
}

/// A handshake beside [name] when the member and [name] vouched for one
/// another in [communityName], either way round; nothing otherwise. An
/// hourglass marks it while the member's vouch waits for [name] to vouch
/// back, a check once both vouched. It opens the story of each vouch
/// ([showVouches]).
class VtcVouchButton extends StatelessWidget {
  const VtcVouchButton({
    super.key,
    required this.edges,
    required this.name,
    required this.communityDid,
    required this.communityName,
    this.entry,
    this.entryId,
  });

  final VtcEdges edges;
  final String name;
  final String communityDid;
  final String communityName;

  /// [name]'s directory entry, or its id, to draw their picture by.
  final DirectoryEntry? entry;
  final String? entryId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tooltip = switch ((edges.outgoing, edges.incoming)) {
      (null, null) => null,
      (_?, _?) => l10n.vtcTrustVouchedForEachOther(name),
      (_?, null) => l10n.vtcTrustWaitingForVouchBack(name),
      (null, _?) => l10n.vtcTrustTheyVouched(name),
    };
    if (tooltip == null) return const SizedBox.shrink();
    final colors = context.customColors;
    final (marker, markerColor) = switch ((edges.outgoing, edges.incoming)) {
      (_?, _?) => (McIcons.check, colors.success),
      (_?, null) => (McIcons.pending, colors.warning),
      _ => (null, null),
    };
    return IconButton(
      key: const Key('vtc_vouches'),
      icon: Badge(
        key: const Key('vtc_vouch_marker'),
        isLabelVisible: marker != null,
        backgroundColor: markerColor,
        padding: EdgeInsets.zero,
        label: Icon(marker, size: 10, color: context.colorScheme.surface),
        child: const Icon(McIcons.handshake, size: 20),
      ),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: () => showVouches(
        context,
        edges: edges,
        communityDid: communityDid,
        communityName: communityName,
        name: name,
        entry: entry,
        entryId: entryId,
      ),
    );
  }
}

/// Shows the story of each vouch in [edges] between the member and [name]
/// in [communityName], the member's own first, as [VtcVouchTrail] draws it.
Future<void> showVouches(
  BuildContext context, {
  required VtcEdges edges,
  required String communityDid,
  required String communityName,
  required String name,
  DirectoryEntry? entry,
  String? entryId,
}) => showOnboardingSheet(
  context,
  Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 24,
    children: [
      if (edges.outgoing case final edge?)
        VtcVouchTrail(
          key: const Key('vtc_vouch_trail_outgoing'),
          edge: edge,
          communityDid: communityDid,
          communityName: communityName,
          name: name,
          isOwn: true,
          entry: entry,
          entryId: entryId,
        ),
      if (edges.incoming case final edge?)
        VtcVouchTrail(
          key: const Key('vtc_vouch_trail_incoming'),
          edge: edge,
          communityDid: communityDid,
          communityName: communityName,
          name: name,
          isOwn: false,
          entry: entry,
          entryId: entryId,
        ),
    ],
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
          style: isDestructive ? context.destructiveElevatedButtonStyle : null,
          child: Text(action),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Runs [work] behind a dialog that cannot be dismissed, saying [title]
/// and [detail], so the member sees it is under way and cannot start it
/// again meanwhile.
Future<T> _whileWorking<T>(
  BuildContext context,
  Future<T> Function() work, {
  required String title,
  required String detail,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          key: const Key('vtc_vouch_progress'),
          content: Row(
            spacing: 16,
            children: [
              const CircularProgressIndicator.adaptive(),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(title, style: context.textTheme.titleMedium),
                    Text(
                      detail,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  try {
    return await work();
  } finally {
    if (navigator.mounted) navigator.pop();
  }
}

void _tell(BuildContext context, String message) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(message)));
