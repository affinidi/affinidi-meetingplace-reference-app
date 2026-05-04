import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/cards/credential_card.dart';
import 'credentials_screen_controller.dart';

class CredentialDetailsScreen extends ConsumerWidget {
  const CredentialDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.credentialDetails),
        actions: [
          IconButton(
            onPressed: () {
              ref
                  .read(credentialsScreenControllerProvider.notifier)
                  .deleteCredential();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show the credential card
              CredentialCard(
                topLeftText: l10n.livenessCredential,
                bottomLeftText: l10n.verifiableCredential,
              ),
              const SizedBox(height: 24),
              // Table with dividers
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const _DetailRow(
                      label: 'Types',
                      value: '[VerifiableCredential, LivenessCredential]',
                    ),
                    Divider(color: colorScheme.primary, height: 24),
                    const _DetailRow(label: 'Issuer', value: 'Affinidi'),
                    Divider(color: colorScheme.primary, height: 24),
                    const _DetailRow(
                      label: 'Issued on',
                      value: '17 April 2026',
                    ),
                    Divider(color: colorScheme.primary, height: 24),
                    const _DetailRow(label: 'Human', value: 'Yes'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
