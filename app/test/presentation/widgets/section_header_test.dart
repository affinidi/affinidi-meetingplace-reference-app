import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_icons.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/section_header.dart';

void main() {
  Future<void> pumpHeader(
    WidgetTester tester, {
    ThemeData? theme,
    String subtitle = 'Who you are connected with',
    bool? showProgress,
    VoidCallback? onClose,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.dark,
        home: Scaffold(
          body: SectionHeader(
            icon: McIcons.connections,
            title: 'Connections',
            subtitle: subtitle,
            showProgress: showProgress,
            onClose: onClose,
          ),
        ),
      ),
    );
  }

  for (final (name, theme) in [
    ('dark', AppTheme.dark),
    ('light', AppTheme.light),
  ]) {
    testWidgets('shows the title and lead in the $name theme', (tester) async {
      await pumpHeader(tester, theme: theme);

      expect(find.byIcon(McIcons.connections), findsOneWidget);
      expect(find.text('Connections'), findsOneWidget);
      expect(find.text('Who you are connected with'), findsOneWidget);
      expect(find.byIcon(McIcons.menu), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('grows with a long lead instead of overflowing', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpHeader(tester, subtitle: 'A lead long enough to wrap ' * 6);

    expect(tester.takeException(), isNull);
  });

  testWidgets('closes through onClose when given', (tester) async {
    var closed = false;
    await pumpHeader(tester, onClose: () => closed = true);

    await tester.tap(find.byIcon(McIcons.close));

    expect(closed, isTrue);
  });

  testWidgets('shows progress beside the action, which stays usable', (
    tester,
  ) async {
    var closed = 0;
    await pumpHeader(tester, showProgress: true, onClose: () => closed++);

    final progress = find.byKey(const Key('section_header_progress'));
    expect(progress, findsOneWidget);
    await tester.tap(find.byIcon(McIcons.close));
    expect(closed, 1);
    expect(
      tester.getCenter(progress).dx,
      lessThan(tester.getCenter(find.byIcon(McIcons.close)).dx),
    );
  });

  testWidgets('shows no progress unless asked', (tester) async {
    await pumpHeader(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(McIcons.menu), findsOneWidget);
  });

  testWidgets('centres the icon on the title line', (tester) async {
    await pumpHeader(tester);

    final icon = tester.getCenter(find.byIcon(McIcons.connections));
    final title = tester.getRect(find.text('Connections'));
    final lineHeight =
        AppTheme.dark.textTheme.headlineSmall!.fontSize! *
        AppTheme.dark.textTheme.headlineSmall!.height!;

    expect(icon.dy, closeTo(title.top + lineHeight / 2, 1));
    expect(icon.dx, lessThan(title.left));
  });
}
