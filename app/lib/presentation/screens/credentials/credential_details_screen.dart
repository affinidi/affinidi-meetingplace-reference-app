import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../widgets/cards/credential_card.dart';
import 'credentials_screen_controller.dart';

class CredentialDetailsScreen extends ConsumerWidget {
  const CredentialDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credential Details'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(credentialsScreenControllerProvider.notifier).deleteCredential();
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
              const CredentialCard(
                topLeftText: 'Liveness Credential',
                bottomLeftText: 'Verifiable Credential',
              ),
              const SizedBox(height: 24),
              // Table with dividers
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      'Types',
                      '[VerifiableCredential, LivenessCredential]',
                    ),
                    Divider(
                      color: colorScheme.primary,
                      height: 24,
                    ),
                    _buildDetailRow(context, 'Issuer', 'Affinidi'),
                    Divider(
                      color: colorScheme.primary,
                      height: 24,
                    ),
                    _buildDetailRow(context, 'Issued on', '17 April 2026'),
                    Divider(
                      color: colorScheme.primary,
                      height: 24,
                    ),
                    _buildDetailRow(context, 'Human', 'Yes'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
