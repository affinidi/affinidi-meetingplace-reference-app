import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';

import '../../../application/services/r_cards_service/r_cards_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/credential/credential_card_components.dart';
import '../../widgets/credential/credential_details_accordion.dart';
import '../../widgets/credential/credential_details_screen_scaffold.dart';

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

    String valueOrDash(String? value) {
      final v = value?.trim();
      return (v == null || v.isEmpty) ? '—' : v;
    }

    final issuedAt = _extractIssuanceDate(card.vcBlob);
    final issuedAtText = issuedAt == null
        ? '—'
        : '${DateFormat('MMM d y').format(issuedAt.toLocal())} at '
            '${DateFormat('h:mma').format(issuedAt.toLocal())}';

    final rows = <CredentialDetailRowData>[
      if (subject?.firstName != null || subject?.lastName != null)
        CredentialDetailRowData(
          icon: Icons.person_outline,
          label: l10n.rCardFieldName,
          value: valueOrDash(subject?.name),
        ),
      if (subject?.email != null)
        CredentialDetailRowData(
          icon: Icons.email_outlined,
          label: l10n.rCardFieldEmail,
          value: valueOrDash(subject?.email),
        ),
      if (subject?.phone != null)
        CredentialDetailRowData(
          icon: Icons.phone_outlined,
          label: l10n.rCardFieldPhone,
          value: valueOrDash(subject?.phone),
        ),
      if (subject?.company != null)
        CredentialDetailRowData(
          icon: Icons.business_outlined,
          label: l10n.rCardFieldCompany,
          value: valueOrDash(subject?.company),
        ),
      if (subject?.position != null)
        CredentialDetailRowData(
          icon: Icons.work_outline,
          label: l10n.rCardFieldPosition,
          value: valueOrDash(subject?.position),
        ),
      if (subject?.website != null)
        CredentialDetailRowData(
          icon: Icons.language_outlined,
          label: l10n.rCardFieldWebsite,
          value: valueOrDash(subject?.website),
        ),
      CredentialDetailRowData(
        icon: Icons.access_time,
        label: l10n.rCardFieldIssuedAt,
        value: issuedAtText,
      ),
    ].where((r) => r.value != '—').toList();

    return CredentialDetailsScreenScaffold(
      title: l10n.secureAttachmentsTitle,
      description: l10n.verifiableCredentialDescription,
      credentialCard: CredentialCardContainer(
        title: l10n.verifiableCredential,
        subtitle: l10n.verified,
        content: CredentialDetailsAccordion(
          title: l10n.rCardTitle,
          sectionHeaderText: l10n.credentialDetails,
          rows: rows,
        ),
      ),
    );
  }

  DateTime? _extractIssuanceDate(String vcBlob) {
    try {
      final decoded = jsonDecode(vcBlob);
      if (decoded is! Map<String, dynamic>) return null;
      final raw = decoded['issuanceDate'];
      if (raw is! String) return null;
      return DateTime.tryParse(raw);
    } catch (_) {
      return null;
    }
  }
}
