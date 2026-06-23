part of 'connection_details_screen.dart';

class _GroupMembersPanel extends ConsumerWidget {
  _GroupMembersPanel(String contactId) : _contactId = contactId;

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(_contactId);
    final group = ref.watch(provider.select((state) => state.group));

    if (group == null) return const SizedBox.shrink();

    return FormCard(
      title: context.l10n.groupMembers,
      trailing: _ShowDeletedMembersSwitch(_contactId),
      child: Column(
        children: [
          _GroupMembersList(_contactId),
          _GroupMembersEmptyRoom(_contactId),
        ],
      ),
    );
  }
}

class _ShowDeletedMembersSwitch extends ConsumerWidget {
  _ShowDeletedMembersSwitch(String contactId) : _contactId = contactId;

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final showDeletedMembers = ref.watch(
      provider.select((state) => state.showDeletedMembers),
    );
    final isLoneMember = ref.watch(provider.isLoneMember);

    if (isLoneMember) return const SizedBox.shrink();

    return Row(
      children: [
        Text(context.l10n.showExited),
        Switch.adaptive(
          value: showDeletedMembers,
          onChanged: controller.showDeletedMembers,
        ),
      ],
    );
  }
}

class _GroupMembersEmptyRoom extends ConsumerWidget {
  _GroupMembersEmptyRoom(String contactId) : _contactId = contactId;

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(_contactId);
    final hasMembersAvailableToChat = ref.watch(
      provider.hasMembersAvailableToChat,
    );

    if (hasMembersAvailableToChat) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: const Color.fromARGB(255, 244, 165, 68),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        context.l10n.groupNoMembersToChat,
        style: const TextStyle(color: Colors.black, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _GroupMembersList extends ConsumerWidget {
  const _GroupMembersList(String contactId) : _contactId = contactId;

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(_contactId);
    final contact = ref.watch(provider.select((state) => state.contact));
    final members = ref.watch(provider.members);
    final isOwner = ref.watch(
      provider.select((state) => state.connection?.ownedByMe ?? false),
    );
    final isDebugMode = ref.watch(
      provider.select((state) => state.isDebugMode),
    );
    final cacheManager = ref.read(cacheManagerProvider);

    String getMemberText(GroupMember member) {
      final isYou = (member.did == contact?.channelDid);
      final isAdmin = (member.membershipType == GroupMembershipType.admin);

      final extras = [
        if (isYou) context.l10n.you,
        if (isAdmin) context.l10n.groupAdmin,
      ].join(', ');

      return [
        member.contactCard.fullName,
        if (extras.isNotEmpty) '($extras)',
      ].join(' ');
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        final isDeleted = member.status == GroupMemberStatus.deleted;
        final isSelf = member.did == contact?.channelDid;
        final isAdmin = member.membershipType == GroupMembershipType.admin;
        final canRemove = isOwner && !isDeleted && !isSelf && !isAdmin;

        return ListTile(
          leading: ProfileCircleAvatar(
            radius: 18,
            image: ContactCardUtils.fromSdkContactCard(
              member.contactCard,
            ).image(cacheManager: cacheManager),
          ),
          title: Text(
            getMemberText(member),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDebugMode) ...[
                Text(
                  member.did.topAndTail(),
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Text(
                  member.status.name,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
              Text(
                isDeleted
                    ? context.l10n.groupMemberExited
                    : '''${context.l10n.generalJoined} ${member.dateAdded.timeAgo(context.l10n)}''',
                style: TextStyle(
                  fontSize: 12,
                  color: isDeleted ? Colors.red : Colors.white70,
                ),
              ),
            ],
          ),
          trailing: canRemove
              ? IconButton(
                  icon: const Icon(Icons.person_remove_outlined),
                  onPressed: () => _RemoveMemberDialog.show(
                    context,
                    contactId: _contactId,
                    member: member,
                  ),
                )
              : null,
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}
