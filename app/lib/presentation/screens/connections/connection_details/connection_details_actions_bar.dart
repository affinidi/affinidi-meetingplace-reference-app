part of 'connection_details_screen.dart';

class _ActionBar extends ConsumerWidget {
  const _ActionBar(this.contactId);

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(contactId);
    final controller = ref.read(provider.notifier);
    final canApprove = ref.watch(provider.canApprove);

    void approveContact() {
      controller.approveContact();
    }

    void rejectContact() {
      controller.rejectContact();
    }

    if (!canApprove) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 12,
        spacing: 12,
        children: [
          ElevatedLoadingButton(
            child: Text(context.l10n.generalReject),
            onPressed: rejectContact,
            color: context.colorScheme.error,
          ),
          ElevatedLoadingButton(
            child: Text(context.l10n.generalApprove),
            onPressed: approveContact,
          ),
        ],
      ),
    );
  }
}
