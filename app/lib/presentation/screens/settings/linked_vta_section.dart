import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../widgets/form_rows/form_card.dart';

/// Links Meeting Place to the member's VTA, so this phone can approve
/// sign-ins to their communities.
class LinkedVtaSection extends HookConsumerWidget {
  const LinkedVtaSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final service = ref.read(vtcServiceProvider);
    final reload = useState(0);
    final linkedVta = useMemoized(service.linkedVta, [reload.value]);
    final managerDid = useMemoized(service.managerDid, [reload.value]);
    final vtaSnapshot = useFuture(linkedVta);
    final managerSnapshot = useFuture(managerDid);
    final vtaDidField = useTextEditingController();
    final isBusy = useState(false);
    // Shown in the card: a SnackBar would sit under the settings drawer.
    final message = useState<String?>(null);

    Future<void> run(Future<String?> Function() action) async {
      isBusy.value = true;
      message.value = null;
      try {
        message.value = await action();
      } on InvalidVtaDidException {
        message.value = l10n.linkedVtaInvalidDid;
      } on MeetingPlaceVtcSDKException catch (error, stackTrace) {
        _log(ref, error, stackTrace);
        message.value =
            error.code == MeetingPlaceVtcSDKErrorCode.didResolutionFailed
            ? l10n.linkedVtaDidNotResolved
            : l10n.linkedVtaUnreachable;
      } on Exception catch (error, stackTrace) {
        // E.g. the approval key cannot be created without enrolled biometrics.
        _log(ref, error, stackTrace);
        message.value = l10n.linkedVtaApprovalKeyFailed;
      } finally {
        isBusy.value = false;
        reload.value++;
      }
    }

    final vta = vtaSnapshot.data;
    final Widget content;
    if (vta == null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.linkedVtaHelperText),
          const SizedBox(height: 12),
          TextField(
            controller: vtaDidField,
            decoration: InputDecoration(labelText: l10n.linkedVtaDidLabel),
            autocorrect: false,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: isBusy.value
                ? null
                : () => run(() async {
                    await service.startLink(vtaDidField.text);
                    return null;
                  }),
            child: Text(l10n.linkedVtaLinkAction),
          ),
        ],
      );
    } else if (!vta.isGranted) {
      final did = managerSnapshot.data ?? '';
      final command =
          'pnm --vta <name> acl create --did $did --role admin '
          '--label meeting-place';
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.linkedVtaGrantInstruction),
          const SizedBox(height: 8),
          SelectableText(command, style: context.textTheme.bodySmall),
          TextButton.icon(
            icon: const Icon(Icons.copy),
            label: Text(l10n.linkedVtaCopyCommand),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: command));
              message.value = l10n.copiedToClipboard;
            },
          ),
          FilledButton(
            onPressed: isBusy.value
                ? null
                : () => run(
                    () async => await service.confirmLink()
                        ? null
                        : l10n.linkedVtaNotGrantedYet,
                  ),
            child: Text(l10n.linkedVtaConfirmAction),
          ),
          TextButton(
            onPressed: isBusy.value ? null : () => run(_unlink(service)),
            child: Text(l10n.cancel),
          ),
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.linkedVtaLinked(vta.vtaDid)),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: isBusy.value ? null : () => run(_unlink(service)),
            child: Text(l10n.linkedVtaUnlinkAction),
          ),
        ],
      );
    }

    return FormCard(
      title: l10n.linkedVtaTitle,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            content,
            if (isBusy.value) ...[
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ],
            if (message.value case final text?) ...[
              const SizedBox(height: 12),
              Text(text, key: const Key('linked_vta_message')),
            ],
          ],
        ),
      ),
    );
  }

  static Future<String?> Function() _unlink(VtcService service) => () async {
    await service.unlink();
    return null;
  };

  /// Logs the failure's type and code; never a DID, key or document.
  static void _log(WidgetRef ref, Exception error, StackTrace stackTrace) {
    ref
        .read(appLoggerProvider)
        .error(
          'Linking the VTA failed',
          error: error,
          stackTrace: stackTrace,
          name: 'LinkedVtaSection',
        );
  }
}
