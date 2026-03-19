part of '../dashboard_routes.dart';

class VideoCallRoute extends GoRouteData with _$VideoCallRoute {
  const VideoCallRoute({required this.contactId, required this.matrixRoomId});

  final String contactId;
  final String matrixRoomId;

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      VideoCallScreen(roomId: matrixRoomId, contactId: contactId);
}
