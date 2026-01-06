import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../application/services/authentication_service/authentication_service.dart';
import '../application/services/identities_service/identities_service.dart';
import '../application/services/settings_service/settings_service.dart';
import '../presentation/screens/authentication/authentication_screen/authentication_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen/onboarding_screen.dart';
import 'routes/app_routes.dart';
import 'routes/route_paths.dart';

part 'router_config_provider.g.dart';

/// Global navigator key used for accessing the root [Navigator] instance
/// outside of the widget tree.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Holds the return URL for navigation after authentication/onboarding.
String? returnUrl;

/// Logger key for this router configuration.
const logKey = 'routerConfigProvider';

Future<bool> _shouldRedirectToIdentities(Ref ref) async {
  await ref.read(identitiesServiceProvider.notifier).ensureInitialized();
  final identitiesState = ref.read(identitiesServiceProvider);
  return identitiesState.identities.isEmpty;
}

/// Route guard used to control navigation based on authentication and
/// onboarding state.
///
/// Returns a redirect path if conditions require it, otherwise `null`
/// to continue with the requested navigation.
///
/// [ref] - Reference to providers for reading state.
/// [context] - The current build context.
/// [state] - The current [GoRouterState].
/// [defaultRoute] - The default route to redirect to if conditions are not met.
Future<String?> _guard(
  Ref ref,
  BuildContext context,
  GoRouterState state,
  String defaultRoute,
) async {
  final alreadyOnboarded = ref.read(settingsServiceProvider).alreadyOnboarded;
  final isAuthenticated =
      ref.read(authenticationServiceProvider).isAuthenticated;

  if (!isAuthenticated) {
    return RoutePaths.authentication;
  }

  if (!alreadyOnboarded) {
    return RoutePaths.onboarding;
  }

  if (await _shouldRedirectToIdentities(ref)) {
    return RoutePaths.identities;
  }

  if ((state.matchedLocation == RoutePaths.authentication &&
          isAuthenticated == true) ||
      (state.matchedLocation == RoutePaths.onboarding &&
          alreadyOnboarded == true)) {
    if (await _shouldRedirectToIdentities(ref)) {
      return RoutePaths.identities;
    }

    return defaultRoute;
  }

  return null;
}

/// Notifier to refresh [GoRouter] when authentication or
///  onboarding state changes.
///
/// Listens to:
/// - [authenticationServiceProvider]
/// - [settingsServiceProvider]
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this.ref) {
    ref.listen(
      authenticationServiceProvider.select((state) => state.isAuthenticated),
      (previous, next) {
        if (previous != next) {
          notifyListeners();
        }
      },
      fireImmediately: true,
    );

    ref.listen(
      settingsServiceProvider.select((state) => state.alreadyOnboarded),
      (previous, next) {
        if (previous != next) {
          notifyListeners();
        }
      },
      fireImmediately: true,
    );
  }
  final Ref ref;
}

/// Provides the app's [GoRouter] configuration.
///
/// Sets up navigation guards, refresh logic, and the main route table.
///
/// [ref] - Used to read dependencies like authentication and settings state.
@Riverpod(keepAlive: true)
GoRouter routerConfig(Ref ref) {
  final defaultRoute = RoutePaths.contacts;

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: defaultRoute,
    debugLogDiagnostics: kDebugMode,
    redirect: (BuildContext context, GoRouterState state) =>
        _guard(ref, context, state, defaultRoute),
    refreshListenable: GoRouterRefreshNotifier(ref),
    routes: [
      GoRoute(
        path: RoutePaths.root,
        redirect: (context, state) => defaultRoute,
      ),
      ...appRoutes,
      GoRoute(
        path: RoutePaths.authentication,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AuthenticationScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnboardingScreen(),
        ),
      ),
    ],
  );
}
