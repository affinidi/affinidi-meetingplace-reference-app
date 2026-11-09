import 'package:flutter/material.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../themes/tokens/mc_radius.dart';
import 'credential_card_components.dart';

/// Displays credential field rows grouped under a titled section.
class CredentialDetailsAccordion extends StatelessWidget {
  const CredentialDetailsAccordion({
    super.key,
    required this.title,
    required this.sectionHeaderText,
    required this.rows,
  });

  final String title;
  final String sectionHeaderText;
  final List<CredentialDetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.mcColors.textPrimary,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.07,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        _SectionHeader(title: sectionHeaderText),
        const SizedBox(height: 16),
        _DetailsContainer(rows: rows),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(McRadius.full),
        border: Border.all(color: context.mcColors.hairlineStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            color: context.mcColors.textSecondary,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.mcColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsContainer extends StatelessWidget {
  const _DetailsContainer({required this.rows});

  final List<CredentialDetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _DetailRow(row: rows[i]),
            if (i != rows.length - 1)
              Divider(color: context.mcColors.hairline, height: 16),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.row});

  final CredentialDetailRowData row;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  '${row.label}:',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: mc.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  row.value,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: mc.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (row.subRows != null && row.subRows!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              children: row.subRows!
                  .map(
                    (subRow) =>
                        _DetailSubRow(label: subRow.label, value: subRow.value),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _DetailSubRow extends StatelessWidget {
  const _DetailSubRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.mcColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.mcColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
