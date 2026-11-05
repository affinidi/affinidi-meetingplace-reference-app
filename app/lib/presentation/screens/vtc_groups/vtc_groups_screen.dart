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
/// creates it, and members join it with the group's credential.
class VtcGroupsScreen extends ConsumerWidget {
  const VtcGroupsScreen({
    super.key,
    required this.communityDid,
    required this.communityName,
  });

  /// DID of the community whose groups are shown.
  final String communityDid;

  /// The community's name, for the title.
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.vtcGroupsTitle(communityName),
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
        VtcGroupsState(failure: final failure?) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(switch (failure) {
              VtcGroupsFailure.vtaMissing => l10n.vtcGroupsVtaMissing,
              VtcGroupsFailure.unreachable => l10n.vtcGroupsUnreachable,
            }, textAlign: TextAlign.center),
          ),
        ),
        VtcGroupsState(groups: []) => Center(
          child: Text(l10n.vtcGroupsNone, textAlign: TextAlign.center),
        ),
        _ => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.groups.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final group = state.groups[index].group;
            return _GroupCard(
              group: group,
              status: state.chats[group.groupId] ?? VtcGroupChatStatus.unknown,
              isBusy: state.busy.contains(group.groupId),
              onCreate: () => controller.createChat(group),
              onJoin: () => controller.joinChat(group),
            );
          },
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canCreate =
        group.isManagedByCaller &&
        group.showsMembersToMembers &&
        status == VtcGroupChatStatus.none;
    return Card(
      key: Key('vtc_group_${group.groupId}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (group.isManagedByCaller)
                  Chip(label: Text(l10n.vtcGroupManager)),
              ],
            ),
            if (group.description case final description?) Text(description),
            Text(switch (status) {
              VtcGroupChatStatus.unknown => l10n.vtcGroupChatUnknown,
              VtcGroupChatStatus.none when !group.showsMembersToMembers =>
                l10n.vtcGroupChatHidesMembers,
              VtcGroupChatStatus.none => l10n.vtcGroupChatNone,
              VtcGroupChatStatus.linked => l10n.vtcGroupChatLinked,
              VtcGroupChatStatus.owned => l10n.vtcGroupChatOwned,
              VtcGroupChatStatus.joined => l10n.vtcGroupChatJoined,
            }, style: context.textTheme.bodySmall),
            if (canCreate || status == VtcGroupChatStatus.linked)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  key: Key(
                    canCreate
                        ? 'vtc_group_create_${group.groupId}'
                        : 'vtc_group_join_${group.groupId}',
                  ),
                  onPressed: isBusy ? null : (canCreate ? onCreate : onJoin),
                  child: isBusy
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          canCreate
                              ? l10n.vtcGroupChatCreate
                              : l10n.vtcGroupChatJoin,
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
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
