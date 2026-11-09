import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../widgets/filter_tab_bar.dart';
import '../../widgets/section_header.dart';
import '../contacts/contacts_screen.dart';
import '../contacts/contacts_screen_controller.dart';
import 'communities_controller.dart';
import 'community_info_view.dart';
import 'community_members_view.dart';

/// A community the member belongs to, with its channels, its groups' chats,
/// its members, and what it publishes about itself. Opened from the
/// Communities tab.
class CommunityScreen extends HookConsumerWidget {
  const CommunityScreen({super.key, required this.communityDid});

  final String communityDid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    useEffect(() {
      // Not while building: showing the community changes the channels.
      Future.microtask(
        () => ref
            .read(contactsScreenControllerProvider.notifier)
            .showCommunity(communityDid),
      );
      return null;
    }, [communityDid]);
    final community = ref
        .watch(communitiesControllerProvider)
        .value
        ?.where((community) => community.communityDid == communityDid)
        .firstOrNull;

    final name = community?.name ?? l10n.membershipCredentialUnnamed;
    final tabController = useTabController(initialLength: 3);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            icon: Tabs.contacts.iconData,
            title: name,
            subtitle: l10n.contactsPanelSubtitle,
            onBack: () => Navigator.of(context).pop(),
          ),
          FilterTabBar(
            controller: tabController,
            labels: [
              l10n.communityChannelsTab,
              l10n.communityMembersTab,
              l10n.communityInfoTab,
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                const ContactsScreen(),
                CommunityMembersView(
                  communityDid: communityDid,
                  communityName: name,
                ),
                CommunityInfoView(communityDid: communityDid),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
