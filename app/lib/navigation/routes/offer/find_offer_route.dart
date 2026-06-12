part of '../dashboard_routes.dart';

class FindOfferRoute extends GoRouteData with $FindOfferRoute {
  const FindOfferRoute({this.identityId});

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  final String? identityId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      FindOfferScreen(identityId: identityId);
}
