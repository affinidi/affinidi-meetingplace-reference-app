import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mpx_flutter_reference_app/application/services/control_plane_service/control_plane_service.dart';
import 'package:mpx_flutter_reference_app/application/services/control_plane_service/control_plane_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/notification_service/notification_service.dart';
import 'package:mpx_flutter_reference_app/application/services/notification_service/notification_service_state.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/navigation/tabs/tabs.dart';
import 'package:mpx_flutter_reference_app/presentation/scaffolds/scaffold_with_nav_bar.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/credentials/membership_credentials_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/credentials/membership_credentials_state.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

import '../../fakes/fake_environment.dart';

void main() {
  late int refreshes;

  setUp(() => refreshes = 0);

  Future<void> pumpTabs(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/${Tabs.contacts.name}',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) =>
              ScaffoldWithNavBar(navigationShell: shell),
          branches: [
            for (final tab in Tabs.values)
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/${tab.name}',
                    builder: (context, state) => tab == Tabs.credentials
                        ? const _CredentialsTab()
                        : Text(tab.name),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          environmentProvider.overrideWithValue(_ZkpEnvironment()),
          controlPlaneServiceProvider.overrideWith(
            _FakeControlPlaneService.new,
          ),
          notificationServiceProvider.overrideWith(
            _FakeNotificationService.new,
          ),
          membershipCredentialsControllerProvider.overrideWith(
            () => _CountingController(() => refreshes++),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester, Tabs tab) async {
    await tester.tap(find.byType(NavigationDestination).at(tab.index));
    await tester.pumpAndSettle();
  }

  testWidgets('leaves the first opening of Credentials to read the cards', (
    tester,
  ) async {
    await pumpTabs(tester);

    await open(tester, Tabs.credentials);

    expect(find.text('credentials'), findsOneWidget);
    expect(refreshes, 0);
  });

  testWidgets('reads the cards again on each return to Credentials', (
    tester,
  ) async {
    await pumpTabs(tester);
    await open(tester, Tabs.credentials);

    await open(tester, Tabs.identities);
    await open(tester, Tabs.credentials);
    expect(refreshes, 1);

    await open(tester, Tabs.contacts);
    await open(tester, Tabs.credentials);
    expect(refreshes, 2);
  });

  testWidgets('does not read the cards again when Credentials is shown', (
    tester,
  ) async {
    await pumpTabs(tester);
    await open(tester, Tabs.credentials);

    await open(tester, Tabs.credentials);

    expect(refreshes, 0);
  });
}

class _ZkpEnvironment extends FakeEnvironment {
  @override
  bool get zkpEnabled => true;
}

class _FakeControlPlaneService extends ControlPlaneService {
  @override
  ControlPlaneServiceState build() => const ControlPlaneServiceState();
}

class _FakeNotificationService extends NotificationService {
  @override
  NotificationServiceState build() => NotificationServiceState();
}

class _CountingController extends MembershipCredentialsController {
  _CountingController(this._onRefresh);

  final VoidCallback _onRefresh;

  @override
  MembershipCredentialsState build() => MembershipCredentialsState();

  @override
  Future<void> refresh() async => _onRefresh();
}

/// Stands in for the Credentials tab, which reads its cards.
class _CredentialsTab extends ConsumerWidget {
  const _CredentialsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(membershipCredentialsControllerProvider);
    return const Text('credentials');
  }
}
