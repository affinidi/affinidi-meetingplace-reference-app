part of '../dashboard_routes.dart';

class OfferDetailsRoute extends GoRouteData with _$OfferDetailsRoute {
  const OfferDetailsRoute(this.offerLink);

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  final String offerLink;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      OfferDetailsScreen(offerLink: offerLink);
}
