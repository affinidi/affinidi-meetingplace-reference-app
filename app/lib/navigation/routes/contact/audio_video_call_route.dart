part of '../dashboard_routes.dart';

class AudioVideoCallRoute extends GoRouteData with $AudioVideoCallRoute {
  const AudioVideoCallRoute({
    required this.contactId,
    this.isAudioOnly = false,
  });

  final String contactId;
  final bool isAudioOnly;

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return AudioVideoCallScreen(contactId: contactId, isAudioOnly: isAudioOnly);
  }
}
