part of 'audio_video_call_screen.dart';

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final errorMessage = l10n.videoCallError('');
    return Scaffold(
      backgroundColor: context.customColors.grey900,
      appBar: AppBar(
        backgroundColor: context.customColors.grey900,
        foregroundColor: context.colorScheme.onSurface,
        title: Text(l10n.videoCallTitle),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text(
          errorMessage,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.customColors.rose,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
