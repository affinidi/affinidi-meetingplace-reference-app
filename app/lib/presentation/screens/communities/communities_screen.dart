import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/models/vtc/vtc_community.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../widgets/section_header.dart';
import '../credentials/membership_credentials_list.dart';
import '../vtc_join/vtc_join_screen.dart';
import 'communities_controller.dart';

/// The communities the member belongs to or is applying to. A community the
/// member belongs to opens with its channels; one they are applying to opens
/// where they joined it, to check on or withdraw the application.
class CommunitiesScreen extends ConsumerWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final communities = ref.watch(communitiesControllerProvider);
    final controller = ref.read(communitiesControllerProvider.notifier);

    // Joining sends, withdraws or decides an application, which fires no
    // membership change: read again once it closes.
    Future<void> join({String? code}) async {
      await VtcJoinScreen.show(context, code: code);
      await controller.refresh();
    }

    Future<void> open(VtcCommunity community) async {
      if (community.isApplying) return join(code: community.communityDid);
      await CommunityRoute(
        communityDid: community.communityDid,
      ).push<void>(context);
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: controller.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: l10n.tabsTitle(Tabs.contacts.name),
                subtitle: l10n.communitiesSubtitle,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextButton.icon(
                    key: const Key('join_community_button'),
                    icon: const Icon(Icons.group_add),
                    label: Text(l10n.vtcJoinMenuTitle),
                    onPressed: join,
                  ),
                ),
              ),
              switch (communities) {
                AsyncData(value: final communities)
                    when communities.isNotEmpty =>
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 12,
                      children: [
                        for (final community in communities)
                          _CommunityRow(
                            key: Key('community_${community.communityDid}'),
                            community: community,
                            onTap: () => open(community),
                          ),
                      ],
                    ),
                  ),
                AsyncData() || AsyncError() => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.communitiesNone,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                AsyncLoading() => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

/// One community: its name, and whether its decision on the member's
/// application is pending.
class _CommunityRow extends StatelessWidget {
  const _CommunityRow({super.key, required this.community, this.onTap});

  final VtcCommunity community;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colorScheme;

    return Material(
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            spacing: 12,
            children: [
              Icon(Icons.groups_outlined, color: colors.onSurface),
              Expanded(
                child: Text(
                  community.name ?? l10n.membershipCredentialUnnamed,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (community.isApplying)
                StatusChip(label: l10n.communityPending, color: Colors.amber)
              else
                Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
