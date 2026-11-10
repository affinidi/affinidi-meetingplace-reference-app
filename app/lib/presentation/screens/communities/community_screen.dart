import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../widgets/filter_tab_bar.dart';
import '../../widgets/section_header.dart';
import '../contacts/contacts_screen.dart';
import '../contacts/contacts_screen_controller.dart';
import '../vtc_join/vtc_findable_controller.dart';
import '../vtc_vetting_desk/vtc_vetting_desk_screen.dart';
import 'communities_controller.dart';
import 'community_info_view.dart';
import 'community_join_phrase_action.dart';
import 'community_logo_provider.dart';
import 'community_members_controller.dart';
import 'community_members_view.dart';
import 'community_membership_view.dart';
import 'community_tabs_providers.dart';
import 'removal_notice.dart';

/// A community the member belongs to, under its logo if it gives one, with
/// its channels, its groups' chats, its members, the member's role and
/// membership card there, what it publishes about itself, and the vetting
/// desk for a vetter; its join phrase beside its name for an
/// administrator. Opened from the Communities tab.
class CommunityScreen extends HookConsumerWidget {
  const CommunityScreen({super.key, required this.communityDid});

  final String communityDid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    useEffect(() {
      // Not while building: showing the community changes the channels.
      Future.microtask(() {
        ref
            .read(contactsScreenControllerProvider.notifier)
            .showCommunity(communityDid);
        // Read the members and the member's directory card now, for the
        // Members tab to show them at once.
        ref
          ..read(communityMembersControllerProvider(communityDid))
          ..read(vtcFindableControllerProvider(communityDid));
      });
      // Keep the cards the community pushes while it shows, e.g. a new
      // role card, for its tabs to show them at once.
      final service = ref.read(vtcServiceProvider);
      unawaited(service.watchCommunity(communityDid));
      return () => unawaited(service.unwatchCommunity(communityDid));
    }, [communityDid]);
    // The member no longer belongs to a community that removed them; the
    // shell tells them.
    ref.listen(vtcRemovalsProvider, (_, next) {
      if (next.value?.communityDid == communityDid && context.mounted) {
        unawaited(Navigator.of(context).maybePop());
      }
    });
    // Read what the header and the Membership and Info tabs show as soon
    // as the community opens, and keep it while it shows, for them to show
    // it at once.
    ref
      ..listen(communityRoleProvider(communityDid), (_, _) {})
      ..listen(communityMembershipCardProvider(communityDid), (_, _) {})
      ..listen(communityInfoProvider(communityDid), (_, _) {});
    final community = ref
        .watch(communitiesControllerProvider)
        .value
        ?.where((community) => community.communityDid == communityDid)
        .firstOrNull;

    final name = community?.name ?? l10n.membershipCredentialUnnamed;
    final logoUrl = ref.watch(communityLogoProvider(communityDid)).value;
    // Last, so the other tabs keep their place as it comes and goes. Until
    // the VTA answers, its last answer stands, for the tab to show at once;
    // the desk checks the card again before any ticket.
    final canVetCheck = ref.watch(communityCanVetProvider(communityDid));
    final canVet =
        canVetCheck.value ??
        (!canVetCheck.hasError && (community?.isVetter ?? false));
    final tabCount = canVet ? 5 : 4;
    // The tab on show stays on show as the Vetting tab comes and goes.
    final shownTab = useRef(0);
    final tabController = useTabController(
      initialLength: tabCount,
      initialIndex: min(shownTab.value, tabCount - 1),
      keys: [tabCount],
    );
    useEffect(() {
      void keep() => shownTab.value = tabController.index;
      tabController.addListener(keep);
      return () => tabController.removeListener(keep);
    }, [tabController]);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            icon: Tabs.contacts.iconData,
            logoUrl: logoUrl,
            title: name,
            titleAction: CommunityJoinPhraseAction(
              communityDid: communityDid,
              communityName: name,
            ),
            subtitle: l10n.contactsPanelSubtitle,
            onBack: () => Navigator.of(context).pop(),
          ),
          FilterTabBar(
            controller: tabController,
            labels: [
              l10n.communityChannelsTab,
              l10n.communityMembersTab,
              l10n.communityMembershipTab,
              l10n.communityInfoTab,
              if (canVet) l10n.communityVettingTab,
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
                CommunityMembershipView(
                  communityDid: communityDid,
                  communityName: name,
                ),
                CommunityInfoView(communityDid: communityDid),
                if (canVet)
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: VtcVettingDeskView(
                      communityDid: communityDid,
                      communityName: name,
                      showBackgroundTasks: false,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
