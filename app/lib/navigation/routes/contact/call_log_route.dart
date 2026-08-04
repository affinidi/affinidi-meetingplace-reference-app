part of '../dashboard_routes.dart';

class CallLogRoute extends GoRouteData with $CallLogRoute {
  const CallLogRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CallLogScreen();
}
