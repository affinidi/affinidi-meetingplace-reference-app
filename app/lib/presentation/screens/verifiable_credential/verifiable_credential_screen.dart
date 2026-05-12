import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../application/services/vrc_service/vrc_service.dart';
import '../../../domain/models/vrc/vrc_credential.dart';
import '../../../domain/models/vrc/vrc_credential_subject.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../l10n/app_localizations.dart';
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
        appBar: AppBar(title: Text(l10n.vrcDetailsTitle), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return _VrcDetailsContent(
      credential: displayCredential,
      isFromMe: isFromMe,
    );
  }
}

class _VrcDetailsContent extends StatelessWidget {
  const _VrcDetailsContent({required this.credential, required this.isFromMe});

  final VrcCredential credential;
  final bool isFromMe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFormatter = DateFormat.yMMMMd();

    VrcCredentialSubject? subject;
    try {
      final decoded = credential.vc.isNotEmpty
          ? _decodeSubject(credential.vc)
          : null;
      if (decoded != null) {
        subject = VrcCredentialSubject.fromJson(decoded);
      }
    } catch (_) {}

    return CredentialDetailsScreenScaffold(
      title: l10n.vrcDetailsTitle,
      description: l10n.vrcDescription,
      credentialCard: _VrcCredentialCard(
        l10n: l10n,
        issuerName: subject?.from.name ?? '',
        issuerDid: credential.issuerIdentityDid,
        holderName: subject?.to.name ?? '',
        holderDid: credential.holderIdentityDid,
        issuedAt: dateFormatter.format(credential.issuedAt),
        verifiedAt: credential.verifiedAt != null
            ? dateFormatter.format(credential.verifiedAt!)
            : null,
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

class _VrcCredentialCard extends StatelessWidget {
  const _VrcCredentialCard({
    required this.l10n,
    required this.issuerName,
    required this.issuerDid,
    required this.holderName,
    required this.holderDid,
    required this.issuedAt,
    this.verifiedAt,
  });

  final AppLocalizations l10n;
  final String issuerName;
  final String issuerDid;
  final String holderName;
  final String holderDid;
  final String issuedAt;
  final String? verifiedAt;

  @override
  Widget build(BuildContext context) {
    return CredentialCardContainer(
      title: l10n.verifiableRelationshipCredential,
      subtitle: l10n.vrcDetailsTitle,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CredentialDetailsAccordion(
            title: l10n.vrcSectionIssuer,
            sectionHeaderText: l10n.vrcSectionIssuer,
            rows: [
              if (issuerName.isNotEmpty)
                CredentialDetailRowData(
                  icon: Icons.person_outline,
                  label: l10n.vrcFieldName,
                  value: issuerName,
                ),
              CredentialDetailRowData(
                icon: Icons.fingerprint,
                label: l10n.vrcFieldDid,
                value: issuerDid,
              ),
            ],
          ),
          const SizedBox(height: 24),
          CredentialDetailsAccordion(
            title: l10n.vrcSectionHolder,
            sectionHeaderText: l10n.vrcSectionHolder,
            rows: [
              if (holderName.isNotEmpty)
                CredentialDetailRowData(
                  icon: Icons.person_outline,
                  label: l10n.vrcFieldName,
                  value: holderName,
                ),
              CredentialDetailRowData(
                icon: Icons.fingerprint,
                label: l10n.vrcFieldDid,
                value: holderDid,
              ),
            ],
          ),
          const SizedBox(height: 24),
          CredentialDetailsAccordion(
            title: l10n.vrcSectionMetadata,
            sectionHeaderText: l10n.vrcSectionMetadata,
            rows: [
              CredentialDetailRowData(
                icon: Icons.calendar_today_outlined,
                label: l10n.vrcFieldIssuedAt,
                value: issuedAt,
              ),
              if (verifiedAt != null)
                CredentialDetailRowData(
                  icon: Icons.verified_outlined,
                  label: l10n.vrcFieldVerifiedAt,
                  value: verifiedAt!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
