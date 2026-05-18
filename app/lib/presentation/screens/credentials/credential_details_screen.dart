import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/credential_service/credential_service.dart';
import '../../../application/services/credential_service/credential_service_state.dart';
import '../../../domain/models/credentials/liveness_credential_record.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/cards/credential_card.dart';
import '../../widgets/credentials/liveness_credential_details_table.dart';

class CredentialDetailsScreen extends ConsumerWidget {
  const CredentialDetailsScreen({
    required this.identityId,
    this.allowDelete = true,
    super.key,
  });

  final String identityId;
  final bool allowDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final record = ref.watch(
      credentialServiceProvider.select(
        (state) => state.credentialFor(identityId),
      ),
    );

    if (record == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.credentialDetails,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        body: Center(child: Text(l10n.noCredentialsYet)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.credentialDetails,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          if (allowDelete)
            IconButton(
              onPressed: () async {
                await ref
                    .read(credentialServiceProvider.notifier)
                    .deleteCredentialForIdentity(identityId);
                if (context.mounted) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.delete_outline, size: 24),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CredentialCard(
              topLeftText: l10n.livenessCredential,
              bottomLeftText: l10n.verifiableCredential,
            ),
            const SizedBox(height: 24),
            _DetailsSection(record: record),
          ],
        ),
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({required this.record});

  final LivenessCredentialRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: LivenessCredentialDetailsTable(record: record),
    );
  }
}
