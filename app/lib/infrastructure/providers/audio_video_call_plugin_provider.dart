import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_livekit_flutter/meeting_place_livekit_flutter.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../configuration/environment.dart';
import 'app_logger_provider.dart';
import 'meeting_place_sdk_provider.dart';

/// Supplies the active [AudioVideoCallPlugin].
///
/// The plugin is built lazily on first read — not at app startup — so the
/// asynchronous [meetingPlaceSdkProvider] initialization does not block the
/// launch path.
final audioVideoCallPluginProvider = FutureProvider<AudioVideoCallPlugin?>((
  ref,
) async {
  const logKey = 'AudioVideoCallPluginProvider';
  final logger = ref.read(appLoggerProvider);

  logger.info('Building audio/video call plugin', name: logKey);
  final sdk = await ref.read(meetingPlaceSdkProvider.future);
  final plugin = MeetingPlaceLiveKitCallPlugin(
    options: MeetingPlaceLiveKitCallPluginOptions(
      livekitServiceUrl: Uri.parse(Environment.instance.livekitServiceUrl),
      livekitSfuUrl: Uri.tryParse(Environment.instance.livekitSfuUrl),
      outgoingCallTimeout: Environment.instance.outgoingCallTimeout,
    ),
    rtcDelegate: FlutterMatrixRTCDelegate(),
    roomFactory: (_) => FlutterLiveKitRoom(),
  );
  plugin.initialize(sdk: sdk);
  logger.info('Audio/video call plugin initialized', name: logKey);
  return plugin;
});
