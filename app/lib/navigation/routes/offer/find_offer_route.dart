part of '../dashboard_routes.dart';

class FindOfferRoute extends GoRouteData with _$FindOfferRoute {
  const FindOfferRoute({this.identityId, this.mnemonic});

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  final String? identityId;
  final String? mnemonic;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      FindOfferScreen(identityId: identityId, mnemonic: mnemonic);
}
