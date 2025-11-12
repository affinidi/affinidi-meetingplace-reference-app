part of '../dashboard_routes.dart';

class ChatRoute extends GoRouteData with _$ChatRoute {
  const ChatRoute({required this.contactId});

  final String contactId;

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ChatScreen(contactId: contactId);
}
