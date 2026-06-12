import 'package:flutter/material.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';

/// A reusable scaffold for displaying credential details.
///
/// Provides a consistent layout: gradient app bar, description banner,
/// and a scrollable credential card body.
class CredentialDetailsScreenScaffold extends StatelessWidget {
  const CredentialDetailsScreenScaffold({
    super.key,
    required this.title,
    required this.description,
    required this.credentialCard,
    this.startColor,
    this.endColor,
  });

  final String title;
  final String description;
  final Widget credentialCard;
  final Color? startColor;
  final Color? endColor;

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;
    final effectiveStartColor = startColor ?? customColors.fromMeColor;
    final effectiveEndColor = endColor ?? customColors.fromMeDarkColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text(title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
          child: Column(
            children: [
              _DescriptionBanner(
                description: description,
                startColor: effectiveStartColor,
                endColor: effectiveEndColor,
              ),
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
  const _DescriptionBanner({
    required this.description,
    required this.startColor,
    required this.endColor,
  });

  final String description;
  final Color startColor;
  final Color endColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user, size: 24, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
