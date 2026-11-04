import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/navigation/routes/route_paths.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/settings_end_drawer.dart';

void main() {
  testWidgets('opens the mock credentials from the drawer', (tester) async {
    final scaffold = GlobalKey<ScaffoldState>();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            key: scaffold,
            endDrawer: const SettingsEndDrawer(),
            body: const SizedBox.shrink(),
          ),
        ),
        GoRoute(
          path: RoutePaths.mockCredentials,
          builder: (context, state) => const Text('mock credentials screen'),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    scaffold.currentState!.openEndDrawer();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mock credentials'));
    await tester.pumpAndSettle();

    expect(find.text('mock credentials screen'), findsOneWidget);
  });
}
