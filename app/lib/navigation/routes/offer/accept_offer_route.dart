part of '../dashboard_routes.dart';

class AcceptOfferRoute extends GoRouteData with _$AcceptOfferRoute {
  AcceptOfferRoute({required String mnemonic, required String identityId})
    : _mnemonic = mnemonic,
      _identityId = identityId;

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  final String _mnemonic;
  final String _identityId;

  String get mnemonic => _mnemonic;
  String get identityId => _identityId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AcceptOfferScreen(mnemonic: _mnemonic, identityId: _identityId);
}
