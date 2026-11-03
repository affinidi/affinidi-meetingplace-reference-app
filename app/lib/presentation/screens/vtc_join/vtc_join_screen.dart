import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/form_rows/form_card.dart';
import '../../widgets/form_rows/form_row_toggle.dart';
import '../../widgets/form_rows/label_icon.dart';
import '../../widgets/offer_banner.dart';
import '../../widgets/qr/qr_scan_button.dart';
import '../../widgets/qr/qr_scan_error_view.dart';
import 'vtc_join_controller.dart';
import 'vtc_join_state.dart';

/// Joins a community: scan its code or enter its DID, read what it asks,
/// apply as an identity from the member's VTA. Laid out like finding and
/// accepting an offer.
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
    final customColors = context.customColors;
    final colorScheme = context.colorScheme;
    void close() => Navigator.of(context).pop();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.vtcJoinMenuTitle)),
        body: SafeArea(
          child: switch (state.step) {
            VtcJoinStep.scanning => _EnterCode(onSubmit: controller.onScanned),
            VtcJoinStep.working => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
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
              color: customColors.success,
              message: state.wasMember
                  ? l10n.vtcJoinAlreadyMember(name)
                  : l10n.vtcJoinJoined(name),
              onDone: close,
              secondary: ElevatedButton(
                style: context.destructiveElevatedButtonStyle,
                onPressed: () async {
                  if (await _confirmLeave(context, name)) {
                    await controller.leave();
                  }
                },
                child: Text(l10n.vtcJoinLeaveAction),
              ),
            ),
            VtcJoinStep.left => _Outcome(
              icon: Icons.logout,
              color: colorScheme.primary,
              message: l10n.vtcJoinLeft(name),
              onDone: close,
            ),
            VtcJoinStep.pending => _Outcome(
              icon: Icons.hourglass_top,
              color: customColors.orange,
              message: l10n.vtcJoinPending(name),
              onDone: close,
              secondary: ElevatedButton(
                onPressed: controller.checkAgain,
                child: Text(l10n.vtcJoinCheckAgain),
              ),
            ),
            VtcJoinStep.denied => _Outcome(
              icon: Icons.block,
              color: colorScheme.error,
              message: switch (state.denialReason) {
                final reason? => l10n.vtcJoinDeniedWithReason(name, reason),
                null => l10n.vtcJoinDenied(name),
              },
              onDone: close,
            ),
            VtcJoinStep.needsMore => _Outcome(
              icon: Icons.info_outline,
              color: colorScheme.secondary,
              message: l10n.vtcJoinNeedsMore,
              onDone: close,
            ),
            VtcJoinStep.failed => QrScanErrorView(
              message: l10n.vtcJoinFailure(
                (state.failure ?? VtcJoinFailure.refused).name,
              ),
              onRetry: controller.restart,
              onCancel: close,
            ),
          },
        ),
      ),
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

/// A step of joining: scrolling [children] under the banner, centred on
/// wide screens, with [actions] pinned below.
class _JoinPage extends StatelessWidget {
  const _JoinPage({required this.children, this.actions = const []});

  static const double _maxWidth = 900;

  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final inset = width > _maxWidth ? (width - _maxWidth) / 2 : 20.0;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(inset, 0, inset, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [const OfferBanner(), ...children],
            ),
          ),
        ),
        if (actions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 12,
              spacing: 12,
              children: actions,
            ),
          ),
      ],
    );
  }
}

/// A step's question, bold and centred as on the offer screens.
class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// A row of a [FormCard]: a coloured label icon, a bold title and an
/// optional explanation.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.titleStyle,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: LabelIcon(icon: icon, iconColor: iconColor, label: title),
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style:
            titleStyle ??
            context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: context.textTheme.bodySmall),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
    );
  }
}

/// A short note under a card, as the offer screens explain their pickers.
class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(text, style: context.textTheme.bodySmall),
    );
  }
}

/// Takes a community's code: scanned with the camera, or its DID typed or
/// pasted. Both are read the same way.
class _EnterCode extends HookWidget {
  const _EnterCode({required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final field = useTextEditingController();
    useListenable(field);
    final code = field.text.trim();

    void submit(String text) {
      FocusManager.instance.primaryFocus?.unfocus();
      if (text.trim().isNotEmpty) onSubmit(text.trim());
    }

    return _JoinPage(
      children: [
        _Heading(l10n.vtcJoinIntroTitle),
        Text(l10n.vtcJoinIntro, style: context.textTheme.bodyMedium),
        Row(
          spacing: 8,
          children: [
            QrScanButton(
              onScanned: (data) {
                if (data != null) submit(data);
              },
            ),
            Expanded(
              child: TextField(
                key: const Key('vtc_join_did'),
                controller: field,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.go,
                onSubmitted: submit,
                decoration: context.roundedInputDecoration.copyWith(
                  hintText: l10n.vtcJoinDidHint,
                  suffixIcon: IconButton(
                    tooltip: l10n.vtcJoinPasteAction,
                    icon: const Icon(Icons.content_paste),
                    onPressed: () async {
                      final data = await Clipboard.getData(
                        Clipboard.kTextPlain,
                      );
                      if (data?.text case final text?) field.text = text.trim();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: code.isEmpty ? null : () => submit(code),
          child: Text(l10n.vtcJoinContinueAction),
        ),
      ],
    );
  }
}

/// What the community asks, in plain words, before the member commits to
/// anything.
class _Review extends StatelessWidget {
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
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final name = state.communityName ?? '';

    return _JoinPage(
      actions: [
        ElevatedButton(
          style: context.destructiveElevatedButtonStyle,
          onPressed: onCancel,
          child: Text(l10n.generalCancel),
        ),
        ElevatedButton(
          onPressed: state.canApply ? onJoin : null,
          child: Text(l10n.vtcJoinAction),
        ),
      ],
      children: [
        Column(
          spacing: 8,
          children: [
            Text(
              name,
              style: context.textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            Text(
              !state.canApply
                  ? l10n.vtcJoinNoSupportedWay(name)
                  : state.admitsAtOnce
                  ? l10n.vtcJoinAdmitsAtOnce
                  : l10n.vtcJoinReviewed,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        if (state.denialReason case final reason?)
          ColoredBox(
            color: colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                l10n.vtcJoinLastDenied(reason),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        FormCard(
          title: l10n.vtcJoinWaysHeading,
          child: Column(
            children: [
              for (final way in state.ways)
                _InfoRow(
                  icon: way.unsupported != null
                      ? Icons.block
                      : way.automatic
                      ? Icons.how_to_reg
                      : Icons.rate_review,
                  iconColor: way.unsupported != null
                      ? colorScheme.onSurfaceVariant
                      : way.automatic
                      ? customColors.success
                      : customColors.orange,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormCard(
                title: l10n.vtcJoinDetailsHeading,
                child: Column(
                  children: [
                    for (final detail in state.requestedDetails)
                      _InfoRow(
                        icon: Icons.badge,
                        iconColor: customColors.purple,
                        title: detail.required
                            ? l10n.vtcJoinDetailRequired(detail.type)
                            : l10n.vtcJoinDetailOptional(detail.type),
                        subtitle: detail.purpose,
                      ),
                  ],
                ),
              ),
              _Note(l10n.vtcJoinDetailsNote),
            ],
          ),
        if (state.canApply)
          FormCard(
            title: l10n.vtcJoinDirectoryHeading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.listsNewMembers case final listed?)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(
                      listed
                          ? l10n.vtcJoinDirectoryListed
                          : l10n.vtcJoinDirectoryHidden,
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                if (state.listsNewMembers != false)
                  FormRowToggle(
                    switchKey: const Key('vtc_join_list_me'),
                    icon: Icons.contacts,
                    iconColor: colorScheme.secondary,
                    label: l10n.vtcJoinListMe,
                    value: state.listInDirectory,
                    onChanged: onListInDirectory,
                    helperText: l10n.vtcJoinListMeNote,
                  ),
              ],
            ),
          ),
        if (state.canApply) _Note(l10n.vtcJoinPersonaNote),
      ],
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
    return _JoinPage(
      actions: [
        ElevatedButton(
          style: context.destructiveElevatedButtonStyle,
          onPressed: onCancel,
          child: Text(l10n.generalCancel),
        ),
      ],
      children: [
        _Heading(l10n.vtcJoinChooseIdentity),
        FormCard(
          title: l10n.vtcJoinIdentityHeading,
          child: Column(
            children: [
              _InfoRow(
                key: const Key('vtc_join_new_identity'),
                icon: Icons.person_add,
                iconColor: context.customColors.success,
                title: l10n.vtcJoinNewIdentity,
                subtitle: l10n.vtcJoinNewIdentityNote,
                onTap: () => onChoose(null),
              ),
              for (final did in state.identityChoices)
                _InfoRow(
                  icon: Icons.person,
                  iconColor: context.colorScheme.primary,
                  title: did,
                  titleStyle: context.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                  onTap: () => onChoose(did),
                ),
            ],
          ),
        ),
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
    return _JoinPage(
      actions: [
        ElevatedButton(
          style: context.destructiveElevatedButtonStyle,
          onPressed: onCancel,
          child: Text(l10n.generalCancel),
        ),
        ElevatedButton(
          onPressed: onShare,
          child: Text(l10n.vtcJoinShareAction),
        ),
      ],
      children: [
        _Heading(l10n.vtcJoinShareDetails(state.communityName ?? '')),
        FormCard(
          title: l10n.vtcJoinDetailsHeading,
          child: Column(
            children: [
              for (final detail in state.details)
                _InfoRow(
                  icon: Icons.badge,
                  iconColor: context.customColors.purple,
                  title: detail.value,
                  subtitle: detail.type,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// How joining ended: an icon in [color], the [message], and Done with an
/// optional [secondary] action beside it.
class _Outcome extends StatelessWidget {
  const _Outcome({
    required this.icon,
    required this.color,
    required this.message,
    required this.onDone,
    this.secondary,
  });

  final IconData icon;
  final Color color;
  final String message;
  final VoidCallback onDone;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: [
            Icon(icon, size: 96, color: color),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 12,
              spacing: 12,
              children: [
                ?secondary,
                ElevatedButton(
                  onPressed: onDone,
                  child: Text(context.l10n.generalDone),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
