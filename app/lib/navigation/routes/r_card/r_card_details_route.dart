part of '../dashboard_routes.dart';

class RCardDetailsRoute extends GoRouteData with _$RCardDetailsRoute {
  const RCardDetailsRoute({required this.subjectDid});

  final String subjectDid;

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      RCardDetailsScreen(subjectDid: subjectDid);
}
