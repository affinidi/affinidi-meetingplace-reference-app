part of 'settings_screen.dart';

/// Links Meeting Place to the member's VTA, so this phone can approve
/// sign-ins to their communities.
class _LinkedVtaSection extends HookConsumerWidget {
  const _LinkedVtaSection();

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

    void showMessage(String message) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    Future<void> run(Future<void> Function() action) async {
      isBusy.value = true;
      try {
        await action();
      } on InvalidVtaDidException {
        showMessage(l10n.linkedVtaInvalidDid);
      } on MeetingPlaceVtcSDKException {
        showMessage(l10n.linkedVtaUnreachable);
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
                : () => run(() => service.startLink(vtaDidField.text)),
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
              showMessage(l10n.copiedToClipboard);
            },
          ),
          FilledButton(
            onPressed: isBusy.value
                ? null
                : () => run(() async {
                    if (!await service.confirmLink()) {
                      showMessage(l10n.linkedVtaNotGrantedYet);
                    }
                  }),
            child: Text(l10n.linkedVtaConfirmAction),
          ),
          TextButton(
            onPressed: isBusy.value ? null : () => run(service.unlink),
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
            onPressed: isBusy.value ? null : () => run(service.unlink),
            child: Text(l10n.linkedVtaUnlinkAction),
          ),
        ],
      );
    }

    return FormCard(
      title: l10n.linkedVtaTitle,
      child: Padding(padding: const EdgeInsets.all(16.0), child: content),
    );
  }
}
