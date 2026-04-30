import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../widgets/cards/credential_card.dart';
import '../../widgets/section_banner.dart';
import 'credential_details_screen.dart';
import 'credentials_screen_controller.dart';

class CredentialsScreen extends ConsumerWidget {
  const CredentialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final hasCredentials = ref.watch(
      credentialsScreenControllerProvider.select((state) => state.hasCredentials),
    );

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionBanner(
              title: l10n.tabsTitle(Tabs.credentials.name),
              subtitle: 'Verifiable Credential wallet',
              icon: Icon(
                Icons.credit_card,
                color: colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            // Content
            hasCredentials
                ? _buildCredentialsList(context, ref)
                : _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'You don\'t have any credentials yet.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildCredentialsList(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Stack(
            children: [
              CredentialCard(
                topLeftText: 'Liveness Credential',
                bottomLeftText: 'Verifiable Credential',
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) => const CredentialDetailsScreen(),
                    ),
                  );
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    ref.read(credentialsScreenControllerProvider.notifier).deleteCredential();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
