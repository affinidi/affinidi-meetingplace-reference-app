import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/vtc_service/vta_link_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import 'vta_link_screen_controller.dart';

/// Links the member's VTA in the look of onboarding: enter its DID, show the
/// administrator what to grant, wait for the grant, and cancel or remove the
/// link. Meant to sit on [onboardingGradient].
///
/// Messages are shown in place: a SnackBar would sit under the settings
/// drawer.
class VtaLinkContent extends HookConsumerWidget {
  const VtaLinkContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final screen = ref.watch(vtaLinkScreenControllerProvider);
    final state = screen.link;
    final controller = ref.read(vtaLinkScreenControllerProvider.notifier);
    final vtaDidField = useTextEditingController();
    final copied = useState<String?>(null);

    Future<void> copy(String text) async {
      await Clipboard.setData(ClipboardData(text: text));
      copied.value = l10n.copiedToClipboard;
    }

    final failure = vtaLinkFailureText(l10n, screen.failure);
    final message = failure ?? copied.value;
    final vtaDidCard = GlassCard(
      title: l10n.linkedVtaDidLabel,
      copyLabel: l10n.linkedVtaCopyDid,
      onCopy: () => copy(state.vtaDid ?? ''),
      child: MonospaceDid(
        state.vtaDid ?? '',
        textKey: const Key('linked_vta_did'),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...switch (state.status) {
          VtaLinkStatus.loading => const [Center(child: OnboardingSpinner())],
          VtaLinkStatus.unlinked => [
            OnboardingTitle(l10n.linkedVtaScreenTitle),
            const SizedBox(height: 8),
            OnboardingSubtitle(l10n.linkedVtaHelperText),
            const SizedBox(height: 24),
            OnboardingTextField(
              key: const Key('vta_did_field'),
              controller: vtaDidField,
              label: l10n.linkedVtaDidLabel,
              hint: 'did:webvh:…',
              enabled: !screen.isBusy,
              onSubmitted: controller.link,
            ),
            const SizedBox(height: 24),
            OnboardingButton(
              label: l10n.linkedVtaLinkAction,
              isLoading: screen.isBusy,
              onPressed: () => controller.link(vtaDidField.text),
            ),
          ],
          VtaLinkStatus.pending => [
            OnboardingTitle(l10n.linkedVtaPendingTitle),
            const SizedBox(height: 24),
            vtaDidCard,
            const SizedBox(height: 12),
            GlassCard(
              title: l10n.linkedVtaManagerDidLabel,
              copyLabel: l10n.linkedVtaCopyDid,
              onCopy: () => copy(state.managerDid ?? ''),
              child: MonospaceDid(state.managerDid ?? ''),
            ),
            const SizedBox(height: 12),
            GlassCard(
              title: l10n.linkedVtaGrantInstruction,
              copyLabel: l10n.linkedVtaCopyCommand,
              onCopy: () => copy(state.grantCommands.join('\n')),
              child: SelectableText(
                state.grantCommands.join('\n'),
                key: const Key('vta_grant_commands'),
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.linkedVtaGrantWarning,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            _WaitingLine(state),
            if (state.hasTimedOut) ...[
              const SizedBox(height: 16),
              OnboardingButton(
                label: l10n.linkedVtaCheckAgain,
                onPressed: controller.checkAgain,
              ),
            ],
            const SizedBox(height: 8),
            OnboardingTextButton(
              label: l10n.cancel,
              onPressed: screen.isBusy ? null : controller.remove,
            ),
          ],
          VtaLinkStatus.active => [
            OnboardingTitle(l10n.linkedVtaTitle),
            const SizedBox(height: 24),
            vtaDidCard,
            const SizedBox(height: 24),
            OnboardingButton(
              label: l10n.linkedVtaUnlinkAction,
              isOutlined: true,
              isLoading: screen.isBusy,
              onPressed: controller.remove,
            ),
          ],
        },
        if (message != null) ...[
          const SizedBox(height: 16),
          OnboardingMessage(
            message,
            isError: failure != null,
            textKey: const Key('linked_vta_message'),
          ),
        ],
      ],
    );
  }
}

/// The message for a failed linking step, or null.
String? vtaLinkFailureText(AppLocalizations l10n, VtaLinkFailure? failure) =>
    switch (failure) {
      null => null,
      VtaLinkFailure.invalidDid => l10n.linkedVtaInvalidDid,
      VtaLinkFailure.alreadyLinked => l10n.linkedVtaAlreadyLinked,
      VtaLinkFailure.didNotResolved => l10n.linkedVtaDidNotResolved,
      VtaLinkFailure.unreachable => l10n.linkedVtaUnreachable,
      VtaLinkFailure.badAnswer => l10n.linkedVtaBadAnswer,
    };

/// What the phone is doing while a link is pending.
String vtaLinkWaitingText(AppLocalizations l10n, VtaLinkState state) =>
    state.hasTimedOut
    ? l10n.linkedVtaStoppedWaiting
    : switch (state.checkFailure) {
        VtaLinkFailure.badAnswer => l10n.linkedVtaBadAnswer,
        VtaLinkFailure() => l10n.linkedVtaStillTrying,
        null when state.isAdminOnly => l10n.linkedVtaWaitingForPersonaHolder,
        null => l10n.linkedVtaWaiting,
      };

/// What the phone is doing while it waits for the grant.
class _WaitingLine extends StatelessWidget {
  const _WaitingLine(this.state);

  final VtaLinkState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12,
      children: [
        if (!state.hasTimedOut)
          const SizedBox.square(
            dimension: 16,
            child: OnboardingSpinner(strokeWidth: 2),
          ),
        Flexible(
          child: Text(
            vtaLinkWaitingText(context.l10n, state),
            key: const Key('vta_link_waiting'),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
