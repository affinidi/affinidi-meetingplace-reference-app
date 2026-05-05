import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';

import '../../../application/services/r_cards_service/r_cards_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';

/// Shows the full details of a single received R-Card.
class RCardDetailsScreen extends ConsumerWidget {
  const RCardDetailsScreen({super.key, required this.subjectDid});

  final String subjectDid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    final card = ref
        .watch(rCardsServiceProvider)
        .where((c) => c.subjectDid == subjectDid)
        .firstOrNull;

    if (card == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.rCardDetailsTitle)),
        body: Center(child: Text(l10n.rCardsEmpty)),
      );
    }

    final subject = RCardSubject.fromVcBlob(card.vcBlob);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rCardDetailsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailCard(
            title: l10n.rCardSectionIdentity,
            rows: [
              if (subject?.firstName != null || subject?.lastName != null)
                _Row(
                  icon: Icons.person_outline,
                  label: l10n.rCardFieldName,
                  value: [
                    subject?.firstName,
                    subject?.lastName,
                  ].whereType<String>().join(' '),
                ),
              if (subject?.email != null)
                _Row(
                  icon: Icons.email_outlined,
                  label: l10n.rCardFieldEmail,
                  value: subject!.email!,
                ),
              if (subject?.phone != null)
                _Row(
                  icon: Icons.phone_outlined,
                  label: l10n.rCardFieldPhone,
                  value: subject!.phone!,
                ),
              if (subject?.company != null)
                _Row(
                  icon: Icons.business_outlined,
                  label: l10n.rCardFieldCompany,
                  value: subject!.company!,
                ),
              if (subject?.position != null)
                _Row(
                  icon: Icons.work_outline,
                  label: l10n.rCardFieldPosition,
                  value: subject!.position!,
                ),
              if (subject?.website != null)
                _Row(
                  icon: Icons.language_outlined,
                  label: l10n.rCardFieldWebsite,
                  value: subject!.website!,
                ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailCard(
            title: l10n.rCardSectionMetadata,
            rows: [
              _Row(
                icon: Icons.fingerprint,
                label: l10n.rCardFieldSubjectDid,
                value: card.subjectDid,
              ),
              _Row(
                icon: Icons.verified_outlined,
                label: l10n.rCardFieldIssuerDid,
                value: card.issuerDid,
              ),
              _Row(
                icon: Icons.access_time_outlined,
                label: l10n.rCardFieldReceivedAt,
                value: DateFormat(
                  'MMM d y, h:mma',
                ).format(card.receivedAt.toLocal()),
              ),
              _Row(
                icon: Icons.calendar_today_outlined,
                label: l10n.rCardFieldIssuedAt,
                value: DateFormat(
                  'MMM d y',
                ).format(card.issuanceDate.toLocal()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.rows});

  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(value, style: context.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
