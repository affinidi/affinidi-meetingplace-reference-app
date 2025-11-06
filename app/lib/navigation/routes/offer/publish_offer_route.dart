part of '../dashboard_routes.dart';

class PublishOfferRoute extends GoRouteData with _$PublishOfferRoute {
  PublishOfferRoute({required this.identityId});

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  final String identityId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      PublishOfferScreen(identityId: identityId);
}
