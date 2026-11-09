part of '../dashboard_routes.dart';

class CommunityRoute extends GoRouteData with $CommunityRoute {
  const CommunityRoute({required this.communityDid});

  final String communityDid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      CommunityScreen(communityDid: communityDid);
}
