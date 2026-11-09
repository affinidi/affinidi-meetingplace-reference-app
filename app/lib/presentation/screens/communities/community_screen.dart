import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/section_banner.dart';
import '../contacts/contacts_screen.dart';
import 'communities_controller.dart';

/// A community the member belongs to, with its channels. Opened from the
/// Communities tab.
class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key, required this.communityDid});

  final String communityDid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final community = ref
        .watch(communitiesControllerProvider)
        .value
        ?.where((community) => community.communityDid == communityDid)
        .firstOrNull;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionBanner(
            title: community?.name ?? l10n.membershipCredentialUnnamed,
            subtitle: l10n.contactsPanelSubtitle,
            onClose: () => Navigator.of(context).pop(),
          ),
          const Expanded(child: ContactsScreen()),
        ],
      ),
    );
  }
}
