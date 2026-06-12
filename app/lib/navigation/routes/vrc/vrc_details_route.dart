part of '../dashboard_routes.dart';

class VrcDetailsRoute extends GoRouteData with $VrcDetailsRoute {
  const VrcDetailsRoute({required this.credentialId});

  final String credentialId;

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final extra = state.extra as Map<String, dynamic>?;
    final vcBlob = extra?['vcBlob'] as String?;
    final channelId = extra?['channelId'] as String?;
    final isFromMe = extra?['isFromMe'] as bool? ?? false;
    return MaterialPage(
      key: state.pageKey,
      child: VrcDetailsScreen(
        credentialId: credentialId,
        vcBlob: vcBlob,
        channelId: channelId,
        isFromMe: isFromMe,
      ),
    );
  }
}
