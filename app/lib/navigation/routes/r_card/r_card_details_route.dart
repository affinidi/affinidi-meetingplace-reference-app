part of '../dashboard_routes.dart';

class RCardDetailsRoute extends GoRouteData with $RCardDetailsRoute {
  const RCardDetailsRoute({required this.subjectDid});

  final String subjectDid;

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final extra = state.extra as Map<String, dynamic>?;
    final vcBlob = extra?['vcBlob'] as String?;
    final isFromMe = extra?['isFromMe'] as bool? ?? false;
    return MaterialPage(
      key: state.pageKey,
      child: RCardDetailsScreen(
        subjectDid: subjectDid,
        vcBlob: vcBlob,
        isFromMe: isFromMe,
      ),
    );
  }
}
