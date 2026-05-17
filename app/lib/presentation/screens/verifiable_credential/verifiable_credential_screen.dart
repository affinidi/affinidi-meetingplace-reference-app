import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../application/services/vrc_service/vrc_service.dart';
import '../../../domain/models/vrc/vrc_credential.dart';
import '../../../domain/models/vrc/vrc_credential_subject.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/credential/credential_card_components.dart';
import '../../widgets/credential/credential_details_accordion.dart';
import '../../widgets/credential/credential_details_screen_scaffold.dart';

/// Displays the full details of a single Verifiable Relationship Credential.
///
/// Can be opened from a chat attachment (via [vcBlob] + [channelId]) or
/// from a stored credential (via [credentialId]).
class VrcDetailsScreen extends ConsumerWidget {
  const VrcDetailsScreen({
    super.key,
    required this.credentialId,
    this.vcBlob,
    this.channelId,
    this.isFromMe = false,
    this.credential,
  });

  final String credentialId;
  final String? vcBlob;
  final String? channelId;
  final bool isFromMe;

  /// When provided, skips the VRC store lookup and displays this credential
  /// directly. Used when navigating from a chat attachment (both sent and
  /// received cards) so the details screen works without a stored credential.
  final VrcCredential? credential;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    // Direct credential takes priority (avoids store lookup for sent VRCs).
    final displayCredential =
        credential ??
        ref
            .watch(vrcServiceProvider)
            .where((v) => v.id == credentialId)
            .firstOrNull;

    if (displayCredential == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.secureAttachmentsTitle),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return _VrcDetailsContent(credential: displayCredential);
  }
}

class _VrcDetailsContent extends StatelessWidget {
  const _VrcDetailsContent({required this.credential});

  final VrcCredential credential;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFormatter = DateFormat.yMd();

    VrcCredentialSubject? subject;
    var credentialTypes = <String>[];
    try {
      final raw = credential.vc.isNotEmpty
          ? jsonDecode(credential.vc) as Map<String, dynamic>?
          : null;
      if (raw != null) {
        final subjectData = _decodeSubject(credential.vc);
        if (subjectData != null) {
          subject = VrcCredentialSubject.fromJson(subjectData);
        }
        credentialTypes = (raw['type'] as List?)?.cast<String>() ?? [];
      }
    } catch (_) {}

    final issuerSubRows = <CredentialDetailRowData>[
      if (subject?.from.name.isNotEmpty == true)
        CredentialDetailRowData(
          label: l10n.generalName,
          value: subject!.from.name,
        ),
      CredentialDetailRowData(
        label: l10n.generalDid,
        value: credential.issuerIdentityDid,
      ),
    ];

    final holderSubRows = <CredentialDetailRowData>[
      if (subject?.to.name.isNotEmpty == true)
        CredentialDetailRowData(
          label: l10n.generalName,
          value: subject!.to.name,
        ),
      CredentialDetailRowData(
        label: l10n.generalDid,
        value: credential.holderIdentityDid,
      ),
    ];

    final rows = <CredentialDetailRowData>[
      CredentialDetailRowData(
        label: l10n.vrcSectionIssuer,
        value: '',
        subRows: issuerSubRows,
      ),
      CredentialDetailRowData(
        label: l10n.vrcSectionHolder,
        value: '',
        subRows: holderSubRows,
      ),
      if (credentialTypes.isNotEmpty)
        CredentialDetailRowData(
          label: l10n.vrcFieldTypes,
          value: credentialTypes.join(', '),
        ),
      CredentialDetailRowData(
        label: l10n.vrcFieldIssuedAt,
        value: dateFormatter.format(credential.issuedAt),
      ),
    ];

    return CredentialDetailsScreenScaffold(
      title: l10n.secureAttachmentsTitle,
      description: l10n.verifiableCredentialDescription,
      credentialCard: CredentialCardContainer(
        title: l10n.verifiableCredential,
        subtitle: l10n.verified,
        content: CredentialDetailsAccordion(
          title: l10n.verifiableRelationshipCredential,
          sectionHeaderText: l10n.credentialDetails,
          rows: rows,
        ),
      ),
    );
  }

  Map<String, dynamic>? _decodeSubject(String vcJson) {
    try {
      final decoded = jsonDecode(vcJson) as Map<String, dynamic>?;
      if (decoded == null) return null;
      final subject = decoded['credentialSubject'];
      if (subject is Map<String, dynamic>) return subject;
      if (subject is List && subject.isNotEmpty) {
        return subject.first as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }
}
