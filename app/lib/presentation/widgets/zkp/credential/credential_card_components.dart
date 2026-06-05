import 'package:flutter/material.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';

/// Data model for a single detail row in a credential card.
class CredentialDetailRowData {
  const CredentialDetailRowData({
    required this.label,
    required this.value,
    this.icon,
    this.subRows,
  });

  final IconData? icon;
  final String label;
  final String value;
  final List<CredentialDetailRowData>? subRows;
}

/// Reusable container card that wraps credential details.
class CredentialCardContainer extends StatelessWidget {
  const CredentialCardContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
  });

  final String title;
  final String subtitle;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(color: customColors.fromMeColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.1647, 0.8365],
                colors: [
                  customColors.fromMeColor,
                  customColors.fromMeDarkColor,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Container(padding: const EdgeInsets.all(24), child: content),
        ],
      ),
    );
  }
}
