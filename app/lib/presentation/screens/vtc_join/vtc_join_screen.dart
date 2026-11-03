import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../dialogs/qr_code_picker/qr_code_picker.dart';
import 'vtc_join_controller.dart';
import 'vtc_join_state.dart';

/// Joins a community: scan its code or enter its DID, read what it asks,
/// apply as an identity from the member's VTA.
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
    if (state.step == VtcJoinStep.scanning) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.vtcJoinMenuTitle)),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: QrCodePicker(onDetectCode: controller.onScanned)),
              _EnterDid(onSubmit: controller.onScanned),
            ],
          ),
        ),
      );
    }

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
              onListInDirectory: controller.setListInDirectory,
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

/// Takes a community's DID typed or pasted, for when there is no code to
/// scan. Read exactly as a scanned code is.
class _EnterDid extends HookWidget {
  const _EnterDid({required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final field = useTextEditingController();
    useListenable(field);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('vtc_join_did'),
              controller: field,
              decoration: InputDecoration(
                labelText: l10n.vtcJoinEnterDidLabel,
                suffixIcon: IconButton(
                  tooltip: l10n.vtcJoinPasteAction,
                  icon: const Icon(Icons.content_paste),
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text case final text?) field.text = text.trim();
                  },
                ),
              ),
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.url,
              onSubmitted: (text) => onSubmit(text.trim()),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: field.text.trim().isEmpty
                ? null
                : () => onSubmit(field.text.trim()),
            child: Text(l10n.vtcJoinContinueAction),
          ),
        ],
      ),
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
    final name = state.communityName ?? '';
    final small = context.textTheme.bodySmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              Text(
                l10n.vtcJoinTitle(name),
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.vtcJoinWaysHeading,
                style: context.textTheme.titleSmall,
              ),
              for (final way in state.ways)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    way.unsupported != null
                        ? Icons.block
                        : way.automatic
                        ? Icons.how_to_reg
                        : Icons.rate_review,
                  ),
                  title: Text(switch (way) {
                    VtcJoinWay(:final unsupported?) =>
                      l10n.vtcJoinWayUnsupported(unsupported.name),
                    VtcJoinWay(automatic: true) => l10n.vtcJoinWayAutomatic,
                    _ => l10n.vtcJoinWayReviewed,
                  }),
                  subtitle: way.description == null
                      ? null
                      : Text(way.description!),
                ),
              const SizedBox(height: 8),
              if (!state.canApply)
                Text(l10n.vtcJoinNoSupportedWay(name))
              else ...[
                Text(
                  state.admitsAtOnce
                      ? l10n.vtcJoinAdmitsAtOnce
                      : l10n.vtcJoinReviewed,
                ),
                if (state.requestedDetails.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.vtcJoinDetailsHeading,
                    style: context.textTheme.titleSmall,
                  ),
                  for (final detail in state.requestedDetails)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(
                        detail.required
                            ? l10n.vtcJoinDetailRequired(detail.type)
                            : l10n.vtcJoinDetailOptional(detail.type),
                      ),
                      subtitle: detail.purpose == null
                          ? null
                          : Text(detail.purpose!),
                    ),
                  Text(l10n.vtcJoinDetailsNote, style: small),
                ],
                const SizedBox(height: 16),
                if (state.listsNewMembers case final listed?)
                  Text(
                    listed
                        ? l10n.vtcJoinDirectoryListed
                        : l10n.vtcJoinDirectoryHidden,
                  ),
                if (state.listsNewMembers != false)
                  SwitchListTile(
                    key: const Key('vtc_join_list_me'),
                    contentPadding: EdgeInsets.zero,
                    value: state.listInDirectory,
                    onChanged: onListInDirectory,
                    title: Text(l10n.vtcJoinListMe),
                    subtitle: Text(l10n.vtcJoinListMeNote),
                  ),
                const SizedBox(height: 8),
                Text(l10n.vtcJoinPersonaNote, style: small),
              ],
            ],
          ),
        ),
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
