import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../dialogs/qr_code_picker/qr_code_picker.dart';
import 'vtc_join_controller.dart';
import 'vtc_join_state.dart';

/// Joins a community: scan its code, read what it asks, apply as a new
/// identity from the member's VTA.
class VtcJoinScreen extends ConsumerWidget {
  const VtcJoinScreen({super.key});

  /// Opens joining over the current screen.
  static Future<void> show(BuildContext context) =>
      Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(builder: (context) => const VtcJoinScreen()),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vtcJoinControllerProvider);
    final controller = ref.read(vtcJoinControllerProvider.notifier);

    if (state.step == VtcJoinStep.scanning) {
      return QrCodePicker(onDetectCode: controller.onScanned);
    }

    final l10n = context.l10n;
    final name = state.communityName ?? '';
    void close() => Navigator.of(context).pop();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vtcJoinMenuTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (state.step) {
            VtcJoinStep.scanning || VtcJoinStep.working => const Center(
              child: CircularProgressIndicator(),
            ),
            VtcJoinStep.review => _Review(
              state: state,
              onJoin: controller.join,
              onCancel: close,
            ),
            VtcJoinStep.joined => _Outcome(
              message: state.wasMember
                  ? l10n.vtcJoinAlreadyMember(name)
                  : l10n.vtcJoinJoined(name),
              onDone: close,
            ),
            VtcJoinStep.pending => _Outcome(
              message: l10n.vtcJoinPending(name),
              onDone: close,
              action: TextButton(
                onPressed: controller.checkAgain,
                child: Text(l10n.vtcJoinCheckAgain),
              ),
            ),
            VtcJoinStep.denied => _Outcome(
              message: l10n.vtcJoinDenied(name),
              onDone: close,
            ),
            VtcJoinStep.needsMore => _Outcome(
              message: l10n.vtcJoinNeedsMore,
              onDone: close,
            ),
            VtcJoinStep.failed => _Outcome(
              message: l10n.vtcJoinFailure(
                (state.failure ?? VtcJoinFailure.refused).name,
              ),
              onDone: close,
            ),
          },
        ),
      ),
    );
  }
}

class _Review extends StatelessWidget {
  const _Review({
    required this.state,
    required this.onJoin,
    required this.onCancel,
  });

  final VtcJoinState state;
  final VoidCallback onJoin;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.vtcJoinTitle(state.communityName ?? ''),
          style: context.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (state.canApply) ...[
          Text(
            state.admitsAtOnce
                ? l10n.vtcJoinAdmitsAtOnce
                : l10n.vtcJoinReviewed,
          ),
          const SizedBox(height: 8),
          Text(l10n.vtcJoinPersonaNote, style: context.textTheme.bodySmall),
        ] else
          Text(l10n.vtcJoinCannotApply),
        const Spacer(),
        if (state.canApply)
          FilledButton(onPressed: onJoin, child: Text(l10n.vtcJoinAction)),
        TextButton(onPressed: onCancel, child: Text(l10n.cancel)),
      ],
    );
  }
}

class _Outcome extends StatelessWidget {
  const _Outcome({required this.message, required this.onDone, this.action});

  final String message;
  final VoidCallback onDone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(message, style: context.textTheme.bodyLarge),
        const Spacer(),
        ?action,
        FilledButton(
          onPressed: onDone,
          child: Text(context.l10n.vtcSignInDone),
        ),
      ],
    );
  }
}
