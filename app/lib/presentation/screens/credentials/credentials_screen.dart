import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/credential_service/credential_service.dart';
import '../../../application/services/credential_service/credential_service_state.dart';
import '../../../domain/models/credentials/liveness_credential_record.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../widgets/cards/animated_stacked_card_deck.dart';
import '../../widgets/cards/credential_card.dart';
import '../../widgets/section_banner.dart';
import '../../widgets/tab_bar_tab.dart';
import 'credential_details_screen.dart';
import 'membership_credential_details_screen.dart';
import 'membership_credentials_controller.dart';
import 'membership_credentials_list.dart';

/// The member's credentials: their liveness credentials and their
/// community membership cards, under All, and the cards alone under
/// Memberships.
class CredentialsScreen extends HookConsumerWidget {
  const CredentialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final credentials = ref.watch(
      credentialServiceProvider.select((state) => state.credentials),
    );
    final memberships = ref.watch(membershipCredentialsControllerProvider);
    final tabController = useTabController(initialLength: 2);
    final tab = useListenableSelector(tabController, () => tabController.index);
    final hasNone =
        credentials.isEmpty &&
        !memberships.isLoading &&
        memberships.failure == null &&
        memberships.entries.isEmpty;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: ref
            .read(membershipCredentialsControllerProvider.notifier)
            .refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionBanner(
                title: l10n.tabsTitle(Tabs.credentials.name),
                subtitle: l10n.verifiableCredentialWallet,
                showProgress: memberships.isSyncing,
              ),
              TabBar(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                isScrollable: true,
                enableFeedback: true,
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                tabAlignment: TabAlignment.start,
                controller: tabController,
                tabs: [
                  TabBarTab(label: l10n.all),
                  TabBarTab(label: l10n.membershipsTab),
                ],
              ),
              if (tab == 0 && hasNone)
                const _EmptyStateWidget()
              else ...[
                if (tab == 0 && credentials.isNotEmpty)
                  _CredentialsListWidget(credentials: credentials),
                MembershipCredentialsList(
                  onOpen: (entry) => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (context) => MembershipCredentialDetailsScreen(
                        entryKey: entry.key,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          l10n.noCredentialsYet,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _CredentialsListWidget extends StatelessWidget {
  const _CredentialsListWidget({required this.credentials});

  final List<LivenessCredentialRecord> credentials;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: AnimatedStackedCardDeck<LivenessCredentialRecord>(
        items: credentials,
        cardHeight: 208.0,
        overlapOffset: 60.0,
        cardBuilder: (context, credential, index, fadeAnimation) {
          return CredentialCard(
            topLeftText: l10n.livenessCredential,
            bottomLeftText: l10n.verifiableCredential,
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (context) => CredentialDetailsScreen(
                    identityId: credential.identityId,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
