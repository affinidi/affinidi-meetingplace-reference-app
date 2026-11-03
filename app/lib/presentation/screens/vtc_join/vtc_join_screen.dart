import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/services/camera_service/camera_service.dart';
import '../../dialogs/qr_code_picker/qr_code_picker.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import 'vtc_join_controller.dart';
import 'vtc_join_state.dart';

/// Joins a community: scan its code or enter its DID, read what it asks,
/// apply as an identity from the member's VTA. In the look of linking the
/// VTA, each thing the community asks in its own card.
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
    final l10n = context.l10n;
    final name = state.communityName ?? '';
    void close() => Navigator.of(context).pop();

    return OnboardingLayout(
      onClose: close,
      child: switch (state.step) {
        VtcJoinStep.scanning => _EnterCode(onSubmit: controller.onScanned),
        VtcJoinStep.working => const Center(child: OnboardingSpinner()),
        VtcJoinStep.review => _Review(
          state: state,
          onJoin: controller.join,
          onListInDirectory: controller.setListInDirectory,
          onCancel: close,
        ),
        VtcJoinStep.chooseIdentity => _ChooseIdentity(
          state: state,
          onChoose: controller.useIdentity,
          onCancel: close,
        ),
        VtcJoinStep.approveDetails => _ApproveDetails(
          state: state,
          onShare: controller.approveDetails,
          onCancel: close,
        ),
        VtcJoinStep.joined => _Outcome(
          icon: Icons.verified,
          message: state.wasMember
              ? l10n.vtcJoinAlreadyMember(name)
              : l10n.vtcJoinJoined(name),
          onDone: close,
          secondary: OnboardingButton(
            label: l10n.vtcJoinLeaveAction,
            isOutlined: true,
            onPressed: () async {
              if (await _confirmLeave(context, name)) {
                await controller.leave();
              }
            },
          ),
        ),
        VtcJoinStep.left => _Outcome(
          icon: Icons.logout,
          message: l10n.vtcJoinLeft(name),
          onDone: close,
        ),
        VtcJoinStep.pending => _Outcome(
          icon: Icons.hourglass_top,
          message: l10n.vtcJoinPending(name),
          onDone: close,
          secondary: OnboardingButton(
            label: l10n.vtcJoinCheckAgain,
            isOutlined: true,
            onPressed: controller.checkAgain,
          ),
        ),
        VtcJoinStep.denied => _Outcome(
          icon: Icons.block,
          message: switch (state.denialReason) {
            final reason? => l10n.vtcJoinDeniedWithReason(name, reason),
            null => l10n.vtcJoinDenied(name),
          },
          onDone: close,
        ),
        VtcJoinStep.needsMore => _Outcome(
          icon: Icons.info_outline,
          message: l10n.vtcJoinNeedsMore,
          onDone: close,
        ),
        VtcJoinStep.failed => _Failed(
          message: l10n.vtcJoinFailure(
            (state.failure ?? VtcJoinFailure.refused).name,
          ),
          onRetry: controller.restart,
          onCancel: close,
        ),
      },
    );
  }
}

/// Asks the member to confirm leaving the community [name].
Future<bool> _confirmLeave(BuildContext context, String name) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.vtcJoinLeaveTitle(name)),
      content: Text(l10n.vtcJoinLeaveMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.generalCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.error,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.vtcJoinLeaveAction),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Small print on the gradient, such as a note under a card.
TextStyle? _note(BuildContext context) =>
    context.textTheme.bodySmall?.copyWith(color: Colors.white70);

/// Takes a community's code: its DID typed or pasted, or its QR code
/// scanned. Both are read the same way.
class _EnterCode extends HookConsumerWidget {
  const _EnterCode({required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final field = useTextEditingController();
    useListenable(field);
    final code = field.text.trim();
    final hasCamera = ref.watch(
      cameraServiceProvider.select((state) => state.isAvailable ?? false),
    );

    void submit(String text) {
      FocusManager.instance.primaryFocus?.unfocus();
      if (text.trim().isNotEmpty) onSubmit(text.trim());
    }

    Future<void> scan() async {
      final data = await QrCodePicker.show(context: context);
      if (data != null) submit(data);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OnboardingTitle(l10n.vtcJoinIntroTitle),
        const SizedBox(height: 8),
        OnboardingSubtitle(l10n.vtcJoinIntro),
        const SizedBox(height: 24),
        OnboardingTextField(
          key: const Key('vtc_join_did'),
          controller: field,
          label: l10n.vtcJoinDidHint,
          hint: 'did:webvh:…',
          onSubmitted: submit,
          suffixIcon: IconButton(
            tooltip: l10n.vtcJoinPasteAction,
            icon: const Icon(Icons.content_paste),
            onPressed: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data?.text case final text?) field.text = text.trim();
            },
          ),
        ),
        const SizedBox(height: 24),
        OnboardingButton(
          label: l10n.vtcJoinContinueAction,
          onPressed: code.isEmpty ? null : () => submit(code),
        ),
        const SizedBox(height: 12),
        OnboardingButton(
          label: l10n.vtcJoinScanAction,
          isOutlined: true,
          onPressed: hasCamera ? scan : null,
        ),
      ],
    );
  }
}

/// What the community asks, each in its own card, before the member
/// commits to anything.
class _Review extends HookWidget {
  const _Review({
    required this.state,
    required this.onJoin,
    required this.onListInDirectory,
    required this.onCancel,
  });

  final VtcJoinState state;
  final VoidCallback onJoin;
  final ValueChanged<bool> onListInDirectory;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = state.communityName ?? '';
    final did = state.communityDid ?? '';
    final copied = useState<String?>(null);

    Future<void> copyDid() async {
      await Clipboard.setData(ClipboardData(text: did));
      copied.value = l10n.copiedToClipboard;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        // The name falls back to the DID, which the card below shows.
        OnboardingTitle(
          name.isEmpty || name == did
              ? l10n.vtcJoinTitleUnnamed
              : l10n.vtcJoinTitle(name),
        ),
        OnboardingSubtitle(
          !state.canApply
              ? l10n.vtcJoinNoSupportedWay(name)
              : state.admitsAtOnce
              ? l10n.vtcJoinAdmitsAtOnce
              : l10n.vtcJoinReviewed,
        ),
        const SizedBox(height: 4),
        if (state.denialReason case final reason?)
          OnboardingMessage(l10n.vtcJoinLastDenied(reason), isError: true),
        GlassCard(
          title: l10n.vtcJoinWaysHeading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              for (final way in state.ways)
                _Line(
                  icon: way.unsupported != null
                      ? Icons.block
                      : way.automatic
                      ? Icons.how_to_reg
                      : Icons.rate_review,
                  title: switch (way) {
                    VtcJoinWay(:final unsupported?) =>
                      l10n.vtcJoinWayUnsupported(unsupported.name),
                    VtcJoinWay(automatic: true) => l10n.vtcJoinWayAutomatic,
                    _ => l10n.vtcJoinWayReviewed,
                  },
                  subtitle: way.description,
                ),
            ],
          ),
        ),
        if (state.canApply && state.requestedDetails.isNotEmpty)
          GlassCard(
            title: l10n.vtcJoinDetailsHeading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                for (final detail in state.requestedDetails)
                  _Line(
                    icon: Icons.badge,
                    title: detail.required
                        ? l10n.vtcJoinDetailRequired(detail.type)
                        : l10n.vtcJoinDetailOptional(detail.type),
                    subtitle: detail.purpose,
                  ),
                Text(l10n.vtcJoinDetailsNote, style: _note(context)),
              ],
            ),
          ),
        if (state.canApply)
          GlassCard(
            title: l10n.vtcJoinDirectoryHeading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.listsNewMembers case final listed?)
                  Text(
                    listed
                        ? l10n.vtcJoinDirectoryListed
                        : l10n.vtcJoinDirectoryHidden,
                    style: _note(context),
                  ),
                if (state.listsNewMembers != false)
                  // A Row, not a SwitchListTile: the onboarding layout
                  // measures intrinsic heights, which a ListTile misreports.
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(
                              l10n.vtcJoinListMe,
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(l10n.vtcJoinListMeNote, style: _note(context)),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        key: const Key('vtc_join_list_me'),
                        value: state.listInDirectory,
                        onChanged: onListInDirectory,
                        activeTrackColor: Colors.white,
                        activeThumbColor: context.colorScheme.primary,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        if (state.canApply)
          Text(
            l10n.vtcJoinPersonaNote,
            textAlign: TextAlign.center,
            style: _note(context),
          ),
        GlassCard(
          title: l10n.vtcJoinDidHint,
          copyLabel: l10n.linkedVtaCopyDid,
          onCopy: copyDid,
          child: MonospaceDid(
            did,
            textKey: const Key('vtc_join_community_did'),
          ),
        ),
        if (copied.value case final text?)
          OnboardingMessage(text, isError: false),
        const SizedBox(height: 12),
        OnboardingButton(
          label: l10n.vtcJoinAction,
          onPressed: state.canApply ? onJoin : null,
        ),
        OnboardingTextButton(label: l10n.generalCancel, onPressed: onCancel),
      ],
    );
  }
}

/// A line in a glass card: a white icon, a title, and an optional
/// explanation.
class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Icon(icon, size: 20, color: Colors.white),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              if (subtitle case final subtitle?)
                Text(subtitle, style: _note(context)),
            ],
          ),
        ),
      ],
    );
  }
}

/// A choice in a glass card: [child] beside a white icon, tapped to choose.
class _Choice extends StatelessWidget {
  const _Choice({
    super.key,
    required this.icon,
    required this.onTap,
    required this.child,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          spacing: 12,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            Expanded(child: child),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// Which identity on the member's VTA joins: a new one, which no other
/// community can link to, or one the VTA already holds.
class _ChooseIdentity extends StatelessWidget {
  const _ChooseIdentity({
    required this.state,
    required this.onChoose,
    required this.onCancel,
  });

  final VtcJoinState state;
  final ValueChanged<String?> onChoose;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        OnboardingTitle(l10n.vtcJoinChooseIdentity),
        const SizedBox(height: 12),
        GlassCard(
          title: l10n.vtcJoinNewIdentity,
          child: _Choice(
            key: const Key('vtc_join_new_identity'),
            icon: Icons.person_add,
            onTap: () => onChoose(null),
            child: Text(l10n.vtcJoinNewIdentityNote, style: _note(context)),
          ),
        ),
        if (state.identityChoices.isNotEmpty)
          GlassCard(
            title: l10n.vtcJoinIdentityHeading,
            child: Column(
              children: [
                for (final did in state.identityChoices)
                  _Choice(
                    icon: Icons.person,
                    onTap: () => onChoose(did),
                    child: Text(
                      did,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        OnboardingTextButton(label: l10n.generalCancel, onPressed: onCancel),
      ],
    );
  }
}

/// The profile details the community asks for, as the VTA would disclose
/// them; nothing is shared until the member approves.
class _ApproveDetails extends StatelessWidget {
  const _ApproveDetails({
    required this.state,
    required this.onShare,
    required this.onCancel,
  });

  final VtcJoinState state;
  final VoidCallback onShare;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        OnboardingTitle(l10n.vtcJoinShareDetails(state.communityName ?? '')),
        const SizedBox(height: 12),
        GlassCard(
          title: l10n.vtcJoinDetailsHeading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              for (final detail in state.details)
                _Line(
                  icon: Icons.badge,
                  title: detail.value,
                  subtitle: detail.type,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OnboardingButton(label: l10n.vtcJoinShareAction, onPressed: onShare),
        OnboardingTextButton(label: l10n.generalCancel, onPressed: onCancel),
      ],
    );
  }
}

/// How joining ended: a white [icon], the [message], then Done and an
/// optional [secondary] action.
class _Outcome extends StatelessWidget {
  const _Outcome({
    required this.icon,
    required this.message,
    required this.onDone,
    this.secondary,
  });

  final IconData icon;
  final String message;
  final VoidCallback onDone;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Icon(icon, size: 72, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        OnboardingButton(label: context.l10n.generalDone, onPressed: onDone),
        ?secondary,
      ],
    );
  }
}

/// Joining could not go ahead: why, then Retry with another code or Cancel.
class _Failed extends StatelessWidget {
  const _Failed({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        const Icon(Icons.error_outline, size: 72, color: Colors.white),
        const SizedBox(height: 4),
        OnboardingMessage(message, isError: true),
        const SizedBox(height: 12),
        OnboardingButton(label: l10n.generalRetry, onPressed: onRetry),
        OnboardingTextButton(label: l10n.generalCancel, onPressed: onCancel),
      ],
    );
  }
}
