import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/credentials/liveness_credential_record.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../zkp/credential/credential_detail_row.dart';

/// Standard field order for liveness credential detail views.
class LivenessCredentialDetailsTable extends StatelessWidget {
  const LivenessCredentialDetailsTable({
    super.key,
    required this.record,
    this.labelWidth = 100,
    this.lightTheme = true,
    this.dividerColor,
  });

  final LivenessCredentialRecord record;
  final double labelWidth;
  final bool lightTheme;
  final Color? dividerColor;

  static const _credentialTypes = '[VerifiableCredential, LivenessCredential]';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final divider = dividerColor ?? colorScheme.primary;
    final issuedOn = DateFormat('d MMMM y').format(record.issuedAt);

    final rows = [
      CredentialDetailRowData(label: l10n.types, value: _credentialTypes),
      CredentialDetailRowData(label: l10n.issuer, value: record.displayIssuer),
      CredentialDetailRowData(label: l10n.issuedOn, value: issuedOn),
      CredentialDetailRowData(label: l10n.issuedTo, value: record.issuedToDid),
      CredentialDetailRowData(label: l10n.human, value: 'Yes'),
    ];

    if (lightTheme) {
      return _LightDetailsTable(
        rows: rows,
        labelWidth: labelWidth,
        dividerColor: divider,
      );
    }

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          CredentialDetailRow(label: rows[i].label, value: rows[i].value),
          if (i < rows.length - 1) Divider(color: divider, height: 16),
        ],
      ],
    );
  }
}

class _LightDetailsTable extends StatelessWidget {
  const _LightDetailsTable({
    required this.rows,
    required this.labelWidth,
    required this.dividerColor,
  });

  final List<CredentialDetailRowData> rows;
  final double labelWidth;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: labelWidth,
                  child: Text(
                    '${rows[i].label}:',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: SelectableText(
                    rows[i].value,
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          if (i < rows.length - 1) Divider(color: dividerColor, height: 24),
        ],
      ],
    );
  }
}
