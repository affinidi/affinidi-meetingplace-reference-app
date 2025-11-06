part of 'settings_screen.dart';

class _MeetingPlaceControlPlaneSection extends ConsumerWidget {
  const _MeetingPlaceControlPlaneSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(settingsScreenControllerProvider.notifier);
    final isDebugMode = ref
        .watch(settingsScreenControllerProvider.select((s) => s.isDebugMode));
    final shouldShowMeetingPlaceQR = ref.watch(settingsScreenControllerProvider
        .select((s) => s.shouldShowMeetingPlaceQR));

    if (!isDebugMode) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: FormCard(
        title: context.l10n.meetingPlaceControlPlane,
        child: Column(
          children: [
            FormRowToggle(
              icon: Icons.qr_code,
              iconColor: context.colorScheme.primary,
              label: context.l10n.showQrScannerForOffers,
              value: shouldShowMeetingPlaceQR,
              onChanged: (value) {
                controller.toggleShouldShowMeetingPlaceQR();
              },
            ),
          ],
        ),
      ),
    );
  }
}
