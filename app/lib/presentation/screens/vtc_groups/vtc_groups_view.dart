import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_group_chat_service/vtc_group_chat_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_radius.dart';
import '../../themes/tokens/mc_spacing.dart';
import '../../themes/tokens/mc_typography.dart';
import '../../widgets/bottom_sheet_menu.dart';
import 'vtc_group_members_screen.dart';
import 'vtc_groups_controller.dart';
import 'vtc_groups_state.dart';

/// The member's groups in one community, each with its chat: a manager
/// creates it, and members join it with the group's credential. The Groups
/// tab of a community's page; pulled down, it reads them again.
class VtcGroupsView extends ConsumerWidget {
  const VtcGroupsView({
    super.key,
    required this.communityDid,
    required this.communityName,
  });

  /// DID of the community whose groups are shown.
  final String communityDid;

  /// The community's name, above a group's members.
  final String communityName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = vtcGroupsControllerProvider(communityDid);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    ref.listen(provider, (previous, next) {
      final message = _failureMessage(l10n, next);
      if (message != null && message != _failureMessage(l10n, previous)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
      final link = next.createdLink;
      final groupDid = next.createdForGroupDid;
      if (link != null && groupDid != null && previous?.createdLink == null) {
        controller.dismissCreatedLink();
        showDialog<void>(
          context: context,
          builder: (_) => _ChatLinkDialog(link: link, groupDid: groupDid),
        );
      }
    });

    if (state case VtcGroupsState(isLoading: true, groups: [])) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: switch (state) {
        VtcGroupsState(failure: final failure?) => _Message(switch (failure) {
          VtcGroupsFailure.vtaMissing => l10n.vtcGroupsVtaMissing,
          VtcGroupsFailure.unreachable => l10n.vtcGroupsUnreachable,
          VtcGroupsFailure.notAMember => l10n.vtcGroupsNotAMember,
        }),
        VtcGroupsState(groups: []) => _Message(l10n.vtcGroupsNone),
        _ => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              for (final listing in state.groups)
                _GroupCard(
                  group: listing.group,
                  status:
                      state.chats[listing.group.groupId] ??
                      VtcGroupChatStatus.unknown,
                  isBusy: state.busy.contains(listing.group.groupId),
                  credentialUntil:
                      state.credentialsUntil[listing.group.groupId],
                  onCreate: () async {
                    final posting = await _askPosting(context);
                    if (posting == null) return;
                    await controller.createChat(
                      listing.group,
                      posting: posting,
                    );
                  },
                  onJoin: () => controller.joinChat(listing.group),
                  onShowLink: () => controller.showChatLink(listing.group),
                  onMembers: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => VtcGroupMembersScreen(
                        communityDid: communityDid,
                        communityName: communityName,
                        group: listing.group,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      },
    );
  }

  static String? _failureMessage(AppLocalizations l10n, VtcGroupsState? state) {
    if (state == null) return null;
    if (state.actionFailed) return l10n.vtcGroupChatFailed;
    return switch (state.chatFailure) {
      null => null,
      VtcGroupChatFailure.notAManager => l10n.vtcGroupChatNotAManager,
      VtcGroupChatFailure.hidesMembers => l10n.vtcGroupChatHidesMembers,
      VtcGroupChatFailure.alreadyLinked => l10n.vtcGroupChatAlreadyLinked,
      VtcGroupChatFailure.notLinked => l10n.vtcGroupChatNotLinked,
      VtcGroupChatFailure.otherMeetingPlace => l10n.vtcGroupChatElsewhere,
      VtcGroupChatFailure.notTheGroupsChat => l10n.vtcGroupChatNotTheGroups,
      VtcGroupChatFailure.noGroupCredential => l10n.vtcGroupChatNoCredential,
      VtcGroupChatFailure.memberNotHere => l10n.vtcGroupChatMemberNotHere,
    };
  }
}

/// A message in place of the groups, such as why they can't be shown;
/// scrollable, so pulling it down reads them again.
class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(text, textAlign: TextAlign.center),
            ),
          ),
        ),
      ],
    );
  }
}

/// A group in a frosted box, as a membership card's steps are drawn: what it
/// is, the member's role in it, where its chat stands, and the action the
/// member can take on the chat.
class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.status,
    required this.isBusy,
    required this.onCreate,
    required this.onJoin,
    required this.onShowLink,
    this.credentialUntil,
    required this.onMembers,
  });

  final VtcGroup group;
  final VtcGroupChatStatus status;
  final bool isBusy;

  /// Until when the member's credential of the group holds, when their VTA
  /// keeps one.
  final DateTime? credentialUntil;
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  /// Shows again the link to publish in the group's DID document, for the
  /// chat this phone owns.
  final VoidCallback onShowLink;

  /// Opens the group's members, to vouch for them.
  final VoidCallback onMembers;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canCreate =
        group.isManagedByCaller &&
        group.showsMembersToMembers &&
        status == VtcGroupChatStatus.none;
    final canJoin = status == VtcGroupChatStatus.linked;
    return Container(
      key: Key('vtc_group_${group.groupId}'),
      // The hairline border takes its width from the padding, so the
      // content keeps its size.
      padding: const EdgeInsets.all(16 - McSpacing.hairline),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(McRadius.lg),
        border: Border.all(color: context.mcColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (status == VtcGroupChatStatus.owned)
                IconButton(
                  key: Key('vtc_group_link_${group.groupId}'),
                  icon: Icon(
                    McIcons.link,
                    color: context.mcColors.textSecondary,
                  ),
                  tooltip: l10n.vtcGroupChatLinkShow,
                  visualDensity: VisualDensity.compact,
                  onPressed: onShowLink,
                ),
            ],
          ),
          if (group.description case final description?)
            Text(
              description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          if (group.isManagedByCaller)
            _Line(
              icon: McIcons.badge,
              title: l10n.vtcCommunityRole,
              subtitle: l10n.vtcGroupManager,
            ),
          if (credentialUntil case final until?)
            _Line(
              icon: McIcons.verified,
              title: l10n.vtcGroupCredential,
              subtitle: l10n.vtcGroupCredentialUntil(
                DateFormat.yMMMd(l10n.localeName).format(until.toLocal()),
              ),
            ),
          _Line(
            icon: McIcons.chats,
            title: l10n.vtcGroupChatHeading,
            subtitle: switch (status) {
              VtcGroupChatStatus.unknown => l10n.vtcGroupChatUnknown,
              VtcGroupChatStatus.none when !group.showsMembersToMembers =>
                l10n.vtcGroupChatHidesMembers,
              VtcGroupChatStatus.none => l10n.vtcGroupChatNone,
              VtcGroupChatStatus.linked => l10n.vtcGroupChatLinked,
              VtcGroupChatStatus.owned => l10n.vtcGroupChatOwned,
              VtcGroupChatStatus.joined => l10n.vtcGroupChatJoined,
            },
          ),
          if (canCreate || canJoin)
            FilledButton.icon(
              key: Key(
                canCreate
                    ? 'vtc_group_create_${group.groupId}'
                    : 'vtc_group_join_${group.groupId}',
              ),
              icon: isBusy
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(canCreate ? McIcons.addComment : McIcons.login),
              label: Text(
                canCreate ? l10n.vtcGroupChatCreate : l10n.vtcGroupChatJoin,
              ),
              onPressed: isBusy ? null : (canCreate ? onCreate : onJoin),
            ),
          if (group.showsMembersToMembers)
            OutlinedButton.icon(
              key: Key('vtc_group_members_${group.groupId}'),
              icon: const Icon(McIcons.group),
              label: Text(l10n.vtcGroupMembersOpen),
              onPressed: onMembers,
            ),
        ],
      ),
    );
  }
}

/// A line in a group's box: an icon, a title, and what it says.
class _Line extends StatelessWidget {
  const _Line({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Icon(icon, size: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(title, style: context.textTheme.bodyMedium),
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Asks the manager, in a bottom sheet, who may post in the chat about to be
/// created; null when they dismiss the sheet.
Future<GroupChatPosting?> _askPosting(BuildContext context) {
  final l10n = context.l10n;
  final options = [
    (
      GroupChatPosting.everyone,
      l10n.vtcGroupChatPostingEveryone,
      l10n.vtcGroupChatPostingEveryoneHint,
    ),
    (
      GroupChatPosting.managers,
      l10n.vtcGroupChatPostingManagers,
      l10n.vtcGroupChatPostingManagersHint,
    ),
  ];
  return showModalBottomSheet<GroupChatPosting>(
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    context: context,
    builder: (context) => BottomSheetMenu(
      header: l10n.vtcGroupChatPostingTitle,
      itemCount: options.length,
      itemBuilder: (context, index) {
        final (posting, title, subtitle) = options[index];
        return ListTile(
          key: Key('vtc_group_posting_${posting.name}'),
          title: Text(title),
          subtitle: Text(subtitle),
          onTap: () => Navigator.of(context, rootNavigator: true).pop(posting),
        );
      },
    ),
  );
}

/// The service entry the community's operator adds to the group's DID
/// document, so members can find the chat and know the community linked
/// it: shown once the chat is created, and again from the group's icon. An
/// operator using `pnm` can copy the command that adds it to that document
/// directly.
class _ChatLinkDialog extends StatelessWidget {
  const _ChatLinkDialog({required this.link, required this.groupDid});

  final GroupChatLink link;
  final String groupDid;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final service = const JsonEncoder.withIndent(
      '  ',
    ).convert(link.toService(groupDid));

    Future<void> copy(String text) async {
      await Clipboard.setData(ClipboardData(text: text));
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.vtcGroupChatLinkCopied)));
    }

    return AlertDialog(
      title: Text(l10n.vtcGroupChatLinkTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(l10n.vtcGroupChatLinkBody),
            SelectableText(
              service,
              key: const Key('vtc_group_chat_link_service'),
              style: McTypography.code.copyWith(
                color: context.mcColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('vtc_group_chat_link_copy_command'),
          onPressed: () =>
              copy(_pnmAddServiceCommand(groupDid, link.toService(groupDid))),
          child: Text(l10n.vtcGroupChatLinkCopyCommand),
        ),
        TextButton(
          onPressed: () => copy(service),
          child: Text(l10n.vtcGroupChatLinkCopy),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.vtcGroupChatLinkDone),
        ),
      ],
    );
  }
}

/// The `pnm` command that publishes [groupDid]'s current DID document with
/// [service] added, in place of any entry with the same id, so no editor
/// opens. It needs `jq`, and runs in bash and zsh; `pnm` still asks before
/// publishing.
String _pnmAddServiceCommand(String groupDid, Map<String, dynamic> service) {
  // Single-quoted for the shell, so a quote in the service closes and
  // reopens the quoting rather than ending the argument.
  final serviceArg = "'${jsonEncode(service).replaceAll("'", r"'\''")}'";
  return 'pnm did-mgmt dids edit --did $groupDid --document <('
      'pnm did-mgmt dids get-log $groupDid'
      ' | jq -s --argjson s $serviceArg'
      r" 'last.state | .service = [(.service // [])[] | select(.id != $s.id)]"
      r" + [$s]')";
}
