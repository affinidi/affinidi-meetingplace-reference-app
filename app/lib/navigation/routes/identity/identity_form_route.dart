part of '../dashboard_routes.dart';

class IdentityFormRoute extends GoRouteData with _$IdentityFormRoute {
  const IdentityFormRoute({this.identityId});

  final String? identityId;

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      IdentityFormScreen(identityId: identityId);
}
