part of 'audio_video_call_screen.dart';

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customColors.grey900,
      appBar: AppBar(
        backgroundColor: context.customColors.grey900,
        foregroundColor: context.colorScheme.onSurface,
        title: Text(context.l10n.videoCallTitle),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text(
          context.l10n.videoCallFailedToJoin(
            context.l10n.videoCallUnknownError,
          ),
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.customColors.rose,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
