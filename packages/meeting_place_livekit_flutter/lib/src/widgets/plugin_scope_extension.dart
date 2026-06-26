import 'package:flutter/widgets.dart';
import 'package:meeting_place_matrix_livekit/meeting_place_matrix_livekit.dart';

import '../../meeting_place_livekit_flutter.dart'
    show AudioVideoCallView, FlutterLiveKitRoom, MeetingPlaceLiveKitVideoView;
import '../widgets/plugin_scope.dart';

/// Flutter-layer extension on [MeetingPlaceLiveKitCallPlugin] that adds
/// widget-scope support. Kept in the Flutter consumer package so the SDK
/// plugin class stays pure Dart.
extension MeetingPlaceLiveKitCallPluginScopeExtension
    on MeetingPlaceLiveKitCallPlugin {
  /// Wraps [child] in the Riverpod scope for the active call session.
  ///
  /// The call screen must be a descendant of this scope so that
  /// [AudioVideoCallView] and [MeetingPlaceLiveKitVideoView] can resolve
  /// the correct [FlutterLiveKitRoom] instance.
  Widget scope({required Widget child}) {
    final session = activeSession;
    if (session == null) {
      throw const MeetingPlaceLiveKitCallMisconfiguredException(
        'No active session. Call startCall() first.',
      );
    }
    return PluginScope(container: session.container, child: child);
  }
}
