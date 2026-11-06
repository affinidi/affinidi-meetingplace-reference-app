import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_group_chat_service/vtc_group_chat_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../l10n/app_localizations.dart';
import 'vtc_groups_controller.dart';
import 'vtc_groups_state.dart';

/// The member's groups in one community, each with its chat: a manager
/// creates it, and members join it with the group's credential. Opened from
/// a membership card, and drawn as that card's screen is.
class VtcGroupsScreen extends ConsumerWidget {
  const VtcGroupsScreen({
    super.key,
    required this.communityDid,
    this.communityName,
  });

  /// DID of the community whose groups are shown.
  final String communityDid;

  /// The community's name, above its groups; left out when unknown.
  final String? communityName;

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.vtcGroupsTitle,
          style: context.textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            key: const Key('vtc_groups_refresh'),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.vtcJoinCheckAgain,
            onPressed: state.isLoading ? null : controller.refresh,
          ),
        ],
      ),
      body: switch (state) {
        VtcGroupsState(isLoading: true, groups: []) => const Center(
          child: CircularProgressIndicator(),
        ),
        VtcGroupsState(failure: final failure?) => _Message(switch (failure) {
          VtcGroupsFailure.vtaMissing => l10n.vtcGroupsVtaMissing,
          VtcGroupsFailure.unreachable => l10n.vtcGroupsUnreachable,
        }),
        VtcGroupsState(groups: []) => _Message(l10n.vtcGroupsNone),
        _ => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              if (communityName case final name?)
                Text(
                  name,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              for (final listing in state.groups)
                _GroupCard(
                  group: listing.group,
                  status:
                      state.chats[listing.group.groupId] ??
                      VtcGroupChatStatus.unknown,
                  isBusy: state.busy.contains(listing.group.groupId),
                  onCreate: () async {
                    final posting = await _askPosting(context);
                    if (posting == null) return;
                    await controller.createChat(
                      listing.group,
                      posting: posting,
                    );
                  },
                  onJoin: () => controller.joinChat(listing.group),
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
    };
  }
}

/// A message in place of the groups, such as why they can't be shown.
class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, textAlign: TextAlign.center),
      ),
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
  });

  final VtcGroup group;
  final VtcGroupChatStatus status;
  final bool isBusy;
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  static const _radius = 16.0;
  static const _tint = 20;

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(_tint),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Text(
            group.name,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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
              icon: Icons.badge_outlined,
              title: l10n.vtcCommunityRole,
              subtitle: l10n.vtcGroupManager,
            ),
          _Line(
            icon: Icons.forum_outlined,
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
                  : Icon(canCreate ? Icons.add_comment_outlined : Icons.login),
              label: Text(
                canCreate ? l10n.vtcGroupChatCreate : l10n.vtcGroupChatJoin,
              ),
              onPressed: isBusy ? null : (canCreate ? onCreate : onJoin),
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

/// Asks the manager who may post in the chat about to be created; null when
/// they dismiss the question.
Future<GroupChatPosting?> _askPosting(BuildContext context) {
  final l10n = context.l10n;
  return showDialog<GroupChatPosting>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(l10n.vtcGroupChatPostingTitle),
      children: [
        for (final (posting, title, subtitle) in [
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
        ])
          SimpleDialogOption(
            key: Key('vtc_group_posting_${posting.name}'),
            onPressed: () => Navigator.of(context).pop(posting),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(title),
              subtitle: Text(subtitle),
            ),
          ),
      ],
    ),
  );
}

/// The service entry the community's operator adds to the group's DID
/// document, so members can find the chat and know the community linked
/// it.
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
              style: context.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: service));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.vtcGroupChatLinkCopied)),
            );
          },
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
