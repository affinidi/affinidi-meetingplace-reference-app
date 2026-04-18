part of '../dashboard_routes.dart';

class VideoCallRoute extends GoRouteData with _$VideoCallRoute {
  const VideoCallRoute({
    required this.contactId,
    required this.matrixRoomId,
    this.audioOnly = false,
  });

  final String contactId;
  final String matrixRoomId;
  final bool audioOnly;

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) => VideoCallScreen(
    roomId: matrixRoomId,
    contactId: contactId,
    audioOnly: audioOnly,
  );
}
