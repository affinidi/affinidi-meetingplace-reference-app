import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../../infrastructure/extensions/box_constraints_extensions.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';

/// A widget that displays an error view for QR code scanning failures.
///
/// [QrScanErrorView] is used to present error messages and UI elements
/// when a QR code scan operation encounters an issue or fails to complete.
/// This widget provides a user-friendly way to communicate scanning errors
/// and potential recovery actions to the user.
///
/// Typically used within a QR scanning flow to handle and display
/// error states gracefully.
class QrScanErrorView extends StatelessWidget {
  const QrScanErrorView({
    required this.message,
    required this.onRetry,
    required this.onCancel,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 24,
              children: [
                _ErrorIcon(),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium,
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.isCompactScreen;
                    return Flex(
                      direction: isCompact ? Axis.vertical : Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: isCompact
                          ? CrossAxisAlignment.stretch
                          : CrossAxisAlignment.center,
                      spacing: 12,
                      children: [
                        Container(
                          constraints: const BoxConstraints(minWidth: 150),
                          child: ElevatedButton(
                            onPressed: onRetry,
                            child: Text(l10n.generalRetry),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(minWidth: 150),
                          child: ElevatedButton(
                            onPressed: onCancel,
                            child: Text(l10n.generalCancel),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.surface,
                              foregroundColor: colorScheme.onPrimary,
                              side: BorderSide(color: colorScheme.primary),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorIcon extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );

    useEffect(
      () {
        animationController.forward();
        HapticFeedback.heavyImpact();

        return;
      },
      [],
    );

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animationController,
        curve: Curves.elasticOut,
      ),
      child: SvgPicture.asset(
        'assets/images/qr_scan_error.svg',
        width: 120,
        height: 120,
      ),
    );
  }
}
