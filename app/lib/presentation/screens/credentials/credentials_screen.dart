import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../widgets/cards/credential_card.dart';
import '../../widgets/section_banner.dart';
import '../../widgets/tab_bar_tab.dart';
import 'credential_details_screen.dart';
import 'credentials_screen_controller.dart';

class CredentialsScreen extends ConsumerWidget {
  const CredentialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final hasCredentials = ref.watch(
      credentialsScreenControllerProvider.select(
        (state) => state.hasCredentials,
      ),
    );

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionBanner(
              title: l10n.tabsTitle(Tabs.credentials.name),
              subtitle: l10n.verifiableCredentialWallet,
              icon: Icon(
                Icons.credit_card,
                color: colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            // Content
            hasCredentials
                ? const _CredentialsListWidget()
                : const _EmptyStateWidget(),
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
      child: Text(
        l10n.noCredentialsYet,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}

class _CredentialsListWidget extends HookConsumerWidget {
  const _CredentialsListWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tabController = useTabController(initialLength: 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TabBar(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                isScrollable: true,
                enableFeedback: true,
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                tabAlignment: TabAlignment.start,
                controller: tabController,
                tabs: const [TabBarTab(label: 'All')],
              ),
            ),
            IconButton(
              onPressed: () async {
                await ref
                    .read(credentialsScreenControllerProvider.notifier)
                    .deleteCredential();
              },
              icon: const Icon(Icons.delete),
              color: Colors.white,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CredentialCard(
            topLeftText: l10n.livenessCredential,
            bottomLeftText: l10n.verifiableCredential,
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (context) => const CredentialDetailsScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
