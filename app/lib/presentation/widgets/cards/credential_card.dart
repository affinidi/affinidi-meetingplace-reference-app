import 'package:flutter/material.dart';

import '../../themes/app_custom_colors.dart';

class CredentialCard extends StatelessWidget {
  const CredentialCard({
    super.key,
    required this.topLeftText,
    required this.bottomLeftText,
    this.onTap,
  });

  final String topLeftText;
  final String bottomLeftText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<AppCustomColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 208,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.primary, width: 1),
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: const Alignment(-0.5, -0.866),
              end: const Alignment(0.5, 0.866),
              colors: [
                customColors.credentialCardGradientStart,
                colorScheme.primary,
              ],
              stops: const [0.5705, 0.9362],
            ),
            boxShadow: [
              BoxShadow(
                color: customColors.credentialCardShadow,
                offset: const Offset(0, 25),
                blurRadius: 50,
                spreadRadius: -12,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  topLeftText,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  bottomLeftText,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
