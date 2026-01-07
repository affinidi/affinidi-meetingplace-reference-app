import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';

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
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (instruction.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  instruction,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withAlpha(180),
                    fontSize: 15,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: Icon(Icons.settings, color: colorScheme.onSurface),
                  label: Text(
                    l10n.cameraOpenSettings,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  style: OutlinedButton.styleFrom(
                    side:
                        BorderSide(color: colorScheme.onSurface.withAlpha(180)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: onOpenSettings,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.refresh, color: colorScheme.onSurface),
                  label: Text(
                    l10n.generalRetry,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: onRetry,
                ),
              ),
              if (onCancel != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    l10n.generalCancel,
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
