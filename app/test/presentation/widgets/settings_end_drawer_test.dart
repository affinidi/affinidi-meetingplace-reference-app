import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/navigation/routes/route_paths.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_colors.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_icons.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/settings_end_drawer.dart';

void main() {
  Future<void> pumpOpenDrawer(WidgetTester tester, ThemeData theme) async {
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
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    scaffold.currentState!.openEndDrawer();
    await tester.pumpAndSettle();
  }

  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
  ]) {
    testWidgets(
      'opens the mock credentials from the drawer in the $name theme',
      (tester) async {
        await pumpOpenDrawer(tester, theme);

        await tester.tap(find.text('Mock credentials'));
        await tester.pumpAndSettle();

        expect(find.text('mock credentials screen'), findsOneWidget);
      },
    );

    testWidgets('draws the drawer with the $name tokens', (tester) async {
      await pumpOpenDrawer(tester, theme);
      final mc = theme.extension<McColors>()!;

      final panel = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(Drawer),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(panel.color, mc.raised);
      expect((panel.shape! as RoundedRectangleBorder).side.color, mc.hairline);
      expect(
        find.descendant(
          of: find.byType(DrawerController),
          matching: find.byWidgetPredicate(
            (widget) => widget is ColoredBox && widget.color == mc.scrim,
          ),
        ),
        findsOneWidget,
      );

      final itemIcon = tester.widget<RichText>(
        find.descendant(
          of: find.byIcon(McIcons.settings),
          matching: find.byType(RichText),
        ),
      );
      expect(itemIcon.text.style?.color, mc.textSecondary);
    });
  }
}
