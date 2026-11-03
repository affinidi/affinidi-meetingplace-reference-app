import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/vtc_service/vta_link_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/buttons/elevated_loading_button.dart';
import '../../widgets/form_rows/form_card.dart';
import '../../widgets/form_rows/form_row_text_field.dart';
import 'vta_link_screen_controller.dart';

/// Links the member's VTA: enter its DID, show the administrator what to
/// grant, wait for the grant, and cancel or remove the link.
///
/// Messages are shown in the panel: a SnackBar would sit under the settings
/// drawer.
class VtaLinkPanel extends HookConsumerWidget {
  const VtaLinkPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final screen = ref.watch(vtaLinkScreenControllerProvider);
    final state = screen.link;
    final controller = ref.read(vtaLinkScreenControllerProvider.notifier);
    final vtaDidField = useTextEditingController();
    final copied = useState<String?>(null);

    Future<void> copy(String text) async {
      await Clipboard.setData(ClipboardData(text: text));
      copied.value = l10n.copiedToClipboard;
    }

    final failure = _failureText(l10n, screen.failure);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 20,
      children: [
        ...switch (state.status) {
          VtaLinkStatus.loading => [
            const Center(child: CircularProgressIndicator()),
          ],
          VtaLinkStatus.unlinked => [
            FormCard(
              title: l10n.linkedVtaTitle,
              child: FormRowTextField(
                textFieldKey: const Key('vta_did_field'),
                color: context.colorScheme.primary,
                label: l10n.linkedVtaDidLabel,
                controller: vtaDidField,
                placeholder: 'did:webvh:…',
                hint: l10n.linkedVtaHelperText,
                enabled: !screen.isBusy,
              ),
            ),
            ElevatedLoadingButton(
              isLoading: screen.isBusy,
              onPressed: () => controller.link(vtaDidField.text),
              child: Text(l10n.linkedVtaLinkAction),
            ),
          ],
          VtaLinkStatus.pending => [
            FormCard(
              title: l10n.linkedVtaManagerDidLabel,
              child: _Body(
                children: [
                  Text(
                    l10n.linkedVtaPendingFor(state.vtaDid ?? ''),
                    style: _muted(context),
                  ),
                  _Copyable(
                    label: l10n.linkedVtaCopyDid,
                    onCopy: () => copy(state.managerDid ?? ''),
                    child: SelectableText(
                      state.managerDid ?? '',
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            FormCard(
              title: l10n.linkedVtaTitle,
              child: _Body(
                children: [
                  Text(l10n.linkedVtaGrantInstruction),
                  _Copyable(
                    label: l10n.linkedVtaCopyCommand,
                    onCopy: () => copy(state.grantCommands.join('\n')),
                    child: _Commands(state.grantCommands),
                  ),
                  Text(l10n.linkedVtaGrantWarning, style: _muted(context)),
                ],
              ),
            ),
            _Waiting(state: state),
            if (state.hasTimedOut)
              ElevatedLoadingButton(
                onPressed: controller.checkAgain,
                child: Text(l10n.linkedVtaCheckAgain),
              ),
            ElevatedLoadingButton(
              isOutlined: true,
              isLoading: screen.isBusy,
              onPressed: controller.remove,
              child: Text(l10n.cancel),
            ),
          ],
          VtaLinkStatus.active => [
            FormCard(
              title: l10n.linkedVtaTitle,
              child: _Body(
                children: [Text(l10n.linkedVtaLinked(state.vtaDid ?? ''))],
              ),
            ),
            ElevatedLoadingButton(
              isOutlined: true,
              color: context.colorScheme.error,
              isLoading: screen.isBusy,
              onPressed: controller.remove,
              child: Text(l10n.linkedVtaUnlinkAction),
            ),
          ],
        },
        for (final text in [?failure, ?copied.value])
          Text(
            text,
            key: const Key('linked_vta_message'),
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              color: text == failure
                  ? context.colorScheme.error
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  static TextStyle? _muted(BuildContext context) => context.textTheme.bodySmall
      ?.copyWith(color: context.colorScheme.onSurfaceVariant);

  static String? _failureText(AppLocalizations l10n, VtaLinkFailure? failure) =>
      vtaLinkFailureText(l10n, failure);
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

/// The padded content of a card.
class _Body extends StatelessWidget {
  const _Body({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: children,
      ),
    );
  }
}

/// [child] with a compact copy action beside it, which also fits the
/// settings drawer.
class _Copyable extends StatelessWidget {
  const _Copyable({
    required this.label,
    required this.onCopy,
    required this.child,
  });

  final String label;
  final VoidCallback onCopy;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: child),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          tooltip: label,
          visualDensity: VisualDensity.compact,
          onPressed: onCopy,
        ),
      ],
    );
  }
}

/// The grant commands, one per line, in a block that reads as code.
class _Commands extends StatelessWidget {
  const _Commands(this.commands);

  final List<String> commands;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SelectableText(
          commands.join('\n'),
          key: const Key('vta_grant_commands'),
          style: context.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            color: context.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// What the phone is doing while it waits for the grant.
class _Waiting extends StatelessWidget {
  const _Waiting({required this.state});

  final VtaLinkState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isWaiting = !state.hasTimedOut;
    final text = vtaLinkWaitingText(l10n, state);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12,
      children: [
        if (isWaiting)
          SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.colorScheme.primary,
            ),
          ),
        Flexible(
          child: Text(
            text,
            key: const Key('vta_link_waiting'),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
