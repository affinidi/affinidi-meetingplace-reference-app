part of '../dashboard_routes.dart';

class OOBScanQrRoute extends GoRouteData with _$OOBScanQrRoute {
  const OOBScanQrRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OOBScanQrScreen();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideUpTransitionPage(
      key: state.pageKey,
      child: const OOBScanQrScreen(),
    );
  }
}
