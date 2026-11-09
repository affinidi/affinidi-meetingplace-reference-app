import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_colors.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_icons.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/badged_icon.dart';

void main() {
  Future<void> pumpIcon(
    WidgetTester tester, {
    required ThemeData theme,
    required int count,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: BadgedIcon(
              label: 'Invitations',
              icon: const Icon(McIcons.connections),
              count: count,
            ),
          ),
        ),
      ),
    );
  }

  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
  ]) {
    testWidgets('fills the count in blue in the $name theme', (tester) async {
      await pumpIcon(tester, theme: theme, count: 3);

      final badge = tester.widget<Badge>(find.byType(Badge));
      final badgeTheme = theme.badgeTheme;

      expect(
        badge.backgroundColor ?? badgeTheme.backgroundColor,
        McColors.blue,
      );
      expect(badge.textColor ?? badgeTheme.textColor, McColors.textOnPrimary);
      expect(find.text('3'), findsOneWidget);
    });
  }

  testWidgets('shows only the icon without a count', (tester) async {
    await pumpIcon(tester, theme: AppTheme.dark, count: 0);

    expect(find.byType(Badge), findsNothing);
    expect(find.byIcon(McIcons.connections), findsOneWidget);
  });
}
