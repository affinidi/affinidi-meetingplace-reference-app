import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../themes/tokens/mc_icons.dart';

class CameraPermissionInstruction extends StatelessWidget {
  const CameraPermissionInstruction({
    super.key,
    required this.onOpenSettings,
    required this.onRetry,
    this.onCancel,
  });

  final Future<void> Function() onOpenSettings;
  final Future<void> Function() onRetry;
  final VoidCallback? onCancel;

  String _platformInstruction(BuildContext context) {
    final l10n = context.l10n;
    final platform = Theme.of(context).platform;
    switch (platform) {
      case TargetPlatform.android:
        return l10n.cameraInstructionAndroid;
      case TargetPlatform.iOS:
        return l10n.cameraInstructionIos;
      case TargetPlatform.macOS:
        return l10n.cameraInstructionMacos;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final mc = context.mcColors;
    final instruction = _platformInstruction(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.cameraAccessDenied,
                style: context.textTheme.titleMedium?.copyWith(
                  color: mc.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (instruction.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  instruction,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: mc.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(McIcons.settings),
                  label: Text(l10n.cameraOpenSettings),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: onOpenSettings,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(McIcons.refresh),
                  label: Text(l10n.generalRetry),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: onRetry,
                ),
              ),
              if (onCancel != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onCancel,
                  child: Text(l10n.generalCancel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
