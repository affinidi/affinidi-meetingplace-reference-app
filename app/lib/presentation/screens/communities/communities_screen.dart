import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/models/vtc/vtc_community.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../helpers/screensize_helper.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_spacing.dart';
import '../../widgets/common/hairline_grid.dart';
import '../../widgets/images/logo_avatar.dart';
import '../../widgets/section_header.dart';
import '../credentials/membership_credentials_list.dart';
import '../vtc_join/vtc_join_screen.dart';
import 'communities_controller.dart';
import 'community_logo_provider.dart';

/// Room for a community's logo, wider than the icon shown without one.
const _logoSize = 32.0;

/// Communities to a row on a phone held upright, and where there is more
/// width.
const _narrowColumns = 2;
const _wideColumns = 3;

/// A long name wraps once, then ends in an ellipsis.
const _nameMaxLines = 2;

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
    final hasNone = communities.value?.isEmpty ?? false;

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
                icon: Tabs.contacts.iconData,
                title: l10n.tabsTitle(Tabs.contacts.name),
                subtitle: l10n.communitiesSubtitle,
              ),
              // With no community yet, the call to action below joins one.
              if (!hasNone)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: McSpacing.s4,
                    ),
                    child: TextButton.icon(
                      key: const Key('join_community_button'),
                      icon: const Icon(McIcons.add),
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
                      horizontal: McSpacing.s4,
                      vertical: McSpacing.s2,
                    ),
                    child: HairlineGrid(
                      columns: _columns(context),
                      children: [
                        for (final community in communities)
                          _CommunityCell(
                            key: Key('community_${community.communityDid}'),
                            community: community,
                            onTap: () => open(community),
                          ),
                      ],
                    ),
                  ),
                AsyncData() => _JoinCallToAction(onJoin: join),
                AsyncError() => Padding(
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

  /// More communities to a row where the screen is wide enough.
  int _columns(BuildContext context) {
    final helper = ScreensizeHelper();
    return helper.isLandscape(context) || helper.isBigScreen(context)
        ? _wideColumns
        : _narrowColumns;
  }
}

/// Invites a member with no community on the phone yet to join one.
class _JoinCallToAction extends StatelessWidget {
  const _JoinCallToAction({required this.onJoin});

  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(McSpacing.s6),
      child: Column(
        spacing: McSpacing.s3,
        children: [
          Icon(McIcons.community, size: 48, color: colors.onSurfaceVariant),
          Text(
            l10n.communitiesNone,
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
            ),
          ),
          Text(
            l10n.communitiesJoinHint,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          FilledButton.icon(
            key: const Key('join_community_cta'),
            icon: const Icon(McIcons.add),
            label: Text(l10n.vtcJoinMenuTitle),
            onPressed: onJoin,
          ),
        ],
      ),
    );
  }
}

/// One community's grid cell: its logo, if it gives one, its name, and
/// whether its decision on the member's application is pending. The whole
/// cell opens it, with the flat hover wash and no ripple.
class _CommunityCell extends StatelessWidget {
  const _CommunityCell({super.key, required this.community, this.onTap});

  final VtcCommunity community;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mc = context.mcColors;

    return InkWell(
      onTap: onTap,
      hoverColor: mc.hoverWash,
      highlightColor: mc.hoverWash,
      splashFactory: NoSplash.splashFactory,
      child: Padding(
        padding: const EdgeInsets.all(McSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: McSpacing.s3,
          children: [
            _CommunityLogo(communityDid: community.communityDid),
            Text(
              community.name ?? l10n.membershipCredentialUnnamed,
              maxLines: _nameMaxLines,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleSmall?.copyWith(
                color: mc.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (community.isApplying)
              StatusChip(label: l10n.communityPending, color: mc.warning),
          ],
        ),
      ),
    );
  }
}

/// The community's logo; the community icon until it loads, or when it
/// gives none or cannot load.
class _CommunityLogo extends ConsumerWidget {
  const _CommunityLogo({required this.communityDid});

  final String communityDid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = Icon(McIcons.community, color: context.colorScheme.onSurface);
    final url = ref.watch(communityLogoProvider(communityDid)).value;
    if (url == null) return icon;
    return LogoAvatar(
      key: Key('community_logo_$communityDid'),
      url: url,
      size: _logoSize,
      fallback: icon,
    );
  }
}
