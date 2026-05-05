import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

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
  });

  final String title;
  final String description;
  final Widget credentialCard;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text(title),
        centerTitle: true,
      ),
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
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
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
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
