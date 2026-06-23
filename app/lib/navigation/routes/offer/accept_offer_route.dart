part of '../dashboard_routes.dart';

class AcceptOfferRoute extends GoRouteData with $AcceptOfferRoute {
  AcceptOfferRoute({required this.mnemonic, required this.identityId});

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  final String mnemonic;
  final String identityId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AcceptOfferScreen(mnemonic: mnemonic, identityId: identityId);
}
