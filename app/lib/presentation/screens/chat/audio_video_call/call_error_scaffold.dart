part of 'audio_video_call_screen.dart';

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({this._errorCode});

  final AudioVideoCallErrorCode? _errorCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final errorMessage = l10n.videoCallFailedToJoin(
      l10n.videoCallError(_errorCode?.name ?? ''),
    );
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
