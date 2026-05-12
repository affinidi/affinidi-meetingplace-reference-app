part of '../dashboard_routes.dart';

class VrcDetailsRoute extends GoRouteData with _$VrcDetailsRoute {
  const VrcDetailsRoute({required this.credentialId});

  final String credentialId;

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final extra = state.extra as Map<String, dynamic>?;
    final vcBlob = extra?['vcBlob'] as String?;
    final channelId = extra?['channelId'] as String?;
    final isFromMe = extra?['isFromMe'] as bool? ?? false;
    return CustomTransitionPage(
      key: state.pageKey,
      child: VrcDetailsScreen(
        credentialId: credentialId,
        vcBlob: vcBlob,
        channelId: channelId,
        isFromMe: isFromMe,
      ),
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
          ),
        );
        return FadeTransition(opacity: fadeAnimation, child: child);
      },
    );
  }
}
