import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/credential_service/credential_service.dart';
import '../../../application/services/credential_service/credential_service_state.dart';
import '../../../domain/models/credentials/liveness_credential_record.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../widgets/cards/credential_card.dart';
import '../../widgets/section_banner.dart';
import '../../widgets/tab_bar_tab.dart';
import 'credential_details_screen.dart';

class CredentialsScreen extends ConsumerWidget {
  const CredentialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final credentials = ref.watch(
      credentialServiceProvider.select((state) => state.credentials),
    );

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionBanner(
              title: l10n.tabsTitle(Tabs.credentials.name),
              subtitle: l10n.verifiableCredentialWallet,
            ),
            credentials.isEmpty
                ? const _EmptyStateWidget()
                : _CredentialsListWidget(credentials: credentials),
          ],
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

class _CredentialsListWidget extends HookConsumerWidget {
  const _CredentialsListWidget({required this.credentials});

  final List<LivenessCredentialRecord> credentials;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tabController = useTabController(initialLength: 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          isScrollable: true,
          enableFeedback: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 10),
          tabAlignment: TabAlignment.start,
          controller: tabController,
          tabs: [TabBarTab(label: l10n.all)],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final record in credentials) ...[
                CredentialCard(
                  topLeftText: l10n.livenessCredential,
                  bottomLeftText: l10n.verifiableCredential,
                  onTap: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (context) => CredentialDetailsScreen(
                          identityId: record.identityId,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
