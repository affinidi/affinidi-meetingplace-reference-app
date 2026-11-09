import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../vtc_join/vtc_join_json_dialog.dart';
import 'vtc_vouch.dart';

/// Beside a member's name: opens every credential of theirs the community
/// shows the member ([VtcMemberCredentialsView]).
class VtcMemberCredentialsButton extends StatelessWidget {
  const VtcMemberCredentialsButton({
    super.key,
    required this.communityDid,
    required this.communityName,
    required this.entry,
    required this.name,
    this.names = const {},
  });

  final String communityDid;
  final String communityName;
  final DirectoryEntry entry;
  final String name;

  /// Names of other members by their DID, for the vouches that name them.
  final Map<String, String> names;

  @override
  Widget build(BuildContext context) => IconButton(
    key: const Key('vtc_member_credentials'),
    icon: const Icon(Icons.wallet_outlined, size: 20),
    tooltip: context.l10n.vtcMemberCredentialsTitle(name),
    visualDensity: VisualDensity.compact,
    onPressed: () => showOnboardingSheet(
      context,
      VtcMemberCredentialsView(
        communityDid: communityDid,
        communityName: communityName,
        entry: entry,
        name: name,
        names: names,
      ),
    ),
  );
}

/// Every credential of the member of [entry] that the community shows the
/// member: the vouches naming them, either way round and with anyone, their
/// external card if they published one, and the membership pair when the
/// member manages members. Each opens as it was signed.
class VtcMemberCredentialsView extends HookConsumerWidget {
  const VtcMemberCredentialsView({
    super.key,
    required this.communityDid,
    required this.communityName,
    required this.entry,
    required this.name,
    this.names = const {},
  });

  final String communityDid;
  final String communityName;
  final DirectoryEntry entry;
  final String name;
  final Map<String, String> names;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final service = ref.read(vtcTrustServiceProvider);
    final load = useMemoized(
      () async => (
        await service.memberCredentials(communityDid, entry: entry),
        await service.identityDid(communityDid),
      ),
      [communityDid, entry.entryId],
    );
    final loaded = useFuture(load);
    String time(DateTime at) =>
        DateFormat.yMMMd(l10n.localeName).add_Hm().format(at.toLocal());

    String nameOf(String did, String? me) {
      if (did == me) return l10n.vtcVouchTrailYou;
      if (did == entry.did) return name;
      return names[did] ?? l10n.vtcMemberCredentialsAnotherMember;
    }

    Widget line({
      required Key key,
      required IconData icon,
      required String title,
      String? subtitle,
      required Map<String, dynamic> document,
    }) => OnboardingLine(
      key: key,
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: IconButton(
        icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
        tooltip: l10n.vtcJoinTrailShowDocument,
        visualDensity: VisualDensity.compact,
        onPressed: () => showVtcJoinJson(context, title: title, json: document),
      ),
    );

    final body = switch (loaded) {
      AsyncSnapshot(hasError: true, :final error) => [
        OnboardingMessage(
          vtcTrustFailureMessage(
            l10n,
            error is VtcTrustException ? error.failure : VtcTrustFailure.failed,
            community: communityName,
            name: name,
          ),
          isError: true,
        ),
      ],
      AsyncSnapshot(data: (final shown, _)) when shown.isEmpty => [
        Text(
          l10n.vtcMemberCredentialsNone(communityName, name),
          style: onboardingNote(context),
        ),
      ],
      AsyncSnapshot(data: (final shown, final me)) => [
        if (shown.membership case final membership?) ...[
          if (membership.membershipCredential case final card?)
            line(
              key: const Key('vtc_member_membership'),
              icon: Icons.card_membership_outlined,
              title: l10n.vtcMemberCredentialsMembership,
              subtitle: l10n.vtcMemberCredentialsIssuedBy(communityName),
              document: card,
            ),
          if (membership.roleCredential case final card?)
            line(
              key: const Key('vtc_member_role'),
              icon: Icons.badge_outlined,
              title: l10n.vtcMemberCredentialsRole,
              subtitle: l10n.vtcMemberCredentialsIssuedBy(communityName),
              document: card,
            ),
          if (membership.memberVmc case final card?)
            line(
              key: const Key('vtc_member_acknowledgement'),
              icon: Icons.verified_outlined,
              title: l10n.vtcMemberCredentialsAcknowledgement,
              subtitle: membership.isMemberVmcBound
                  ? l10n.vtcMemberCredentialsAcknowledgementBound(name)
                  : l10n.vtcMemberCredentialsAcknowledgementStale(name),
              document: card,
            ),
        ],
        if (shown.publicCard case final card?)
          line(
            key: const Key('vtc_member_public_card'),
            icon: Icons.contact_page_outlined,
            title: l10n.vtcMemberCredentialsPublicCard,
            subtitle: l10n.vtcMemberCredentialsSignedBy(name),
            document: card,
          ),
        for (final vouch in shown.vouches)
          line(
            key: Key('vtc_member_vouch_${vouch.id}'),
            icon: Icons.handshake_outlined,
            title: l10n.vtcMemberCredentialsVouch(
              nameOf(vouch.issuerDid, me),
              nameOf(vouch.subjectDid, me),
            ),
            subtitle: switch (vouch.createdAt) {
              final at? => l10n.vtcMemberCredentialsStoredAt(time(at)),
              null => null,
            },
            document: vouch.toJson(),
          ),
      ],
      _ => [const Center(child: CircularProgressIndicator())],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(
          l10n.vtcMemberCredentialsTitle(name),
          style: context.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          l10n.vtcMemberCredentialsNote(communityName),
          style: onboardingNote(context),
        ),
        ...body,
      ],
    );
  }
}
