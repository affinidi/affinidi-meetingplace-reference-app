part of '../dashboard_routes.dart';

class ConnectionDetailsRoute extends GoRouteData with _$ConnectionDetailsRoute {
  const ConnectionDetailsRoute({required this.contactId});

  final String contactId;

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ConnectionDetailsScreen(contactId: contactId);
}
