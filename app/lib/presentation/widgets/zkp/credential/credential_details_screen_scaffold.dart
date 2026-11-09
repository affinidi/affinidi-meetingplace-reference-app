import 'package:flutter/material.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../themes/tokens/mc_icons.dart';
import '../../../themes/tokens/mc_radius.dart';

/// A reusable scaffold for displaying credential details.
///
/// Provides a consistent layout: app bar, description banner, and a
/// scrollable credential card body.
class CredentialDetailsScreenScaffold extends StatelessWidget {
  const CredentialDetailsScreenScaffold({
    super.key,
    required this.title,
    required this.description,
    required this.credentialCard,
  });

  final String title;
  final String description;
  final Widget credentialCard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
          child: Column(
            children: [
              _DescriptionBanner(description: description),
              const SizedBox(height: 32),
              credentialCard,
            ],
          ),
        ),
      ),
    );
  }
}

class _DescriptionBanner extends StatelessWidget {
  const _DescriptionBanner({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        border: Border.all(color: mc.hairline),
        borderRadius: BorderRadius.circular(McRadius.sm),
      ),
      child: Row(
        children: [
          Icon(McIcons.credentials, size: 24, color: mc.highlightSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: mc.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
