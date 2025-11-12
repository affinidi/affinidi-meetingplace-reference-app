part of '../dashboard_routes.dart';

class OOBShareQrRoute extends GoRouteData with _$OOBShareQrRoute {
  const OOBShareQrRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OOBShareQrScreen();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideUpTransitionPage(
      key: state.pageKey,
      child: const OOBShareQrScreen(),
    );
  }
}
