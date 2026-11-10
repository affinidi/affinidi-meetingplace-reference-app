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
    Uri? logoUrl,
    bool? showProgress,
    VoidCallback? onClose,
    VoidCallback? onBack,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.dark,
        home: Scaffold(
          body: SectionHeader(
            icon: McIcons.connections,
            title: 'Connections',
            subtitle: subtitle,
            logoUrl: logoUrl,
            showProgress: showProgress,
            onClose: onClose,
            onBack: onBack,
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

  testWidgets('shows the logo in place of the icon when given', (tester) async {
    final url = Uri.parse('https://chess.example/logo.png');
    await pumpHeader(tester, logoUrl: url);

    final logo = find.byKey(const Key('section_header_logo'));
    expect(logo, findsOneWidget);
    final image = tester.widget<Image>(
      find.descendant(of: logo, matching: find.byType(Image)),
    );
    expect((image.image as NetworkImage).url, url.toString());
    expect(tester.getSize(logo), const Size.square(48));
  });

  testWidgets('shows the title below the way back', (tester) async {
    var wentBack = false;
    await pumpHeader(tester, onBack: () => wentBack = true);

    final back = find.byKey(const Key('section_header_back'));
    expect(
      tester.getBottomLeft(back).dy,
      lessThanOrEqualTo(tester.getTopLeft(find.text('Connections')).dy),
    );
    expect(find.byIcon(McIcons.menu), findsOneWidget);

    await tester.tap(back);
    expect(wentBack, isTrue);
  });

  testWidgets('shows the icon without a logo', (tester) async {
    await pumpHeader(tester);

    expect(find.byKey(const Key('section_header_logo')), findsNothing);
    expect(find.byIcon(McIcons.connections), findsOneWidget);
  });

  testWidgets('closes through onClose when given', (tester) async {
    var closed = false;
    await pumpHeader(tester, onClose: () => closed = true);

    await tester.tap(find.byIcon(McIcons.close));

    expect(closed, isTrue);
  });

  testWidgets('labels the action for screen readers', (tester) async {
    await pumpHeader(tester);
    expect(find.byTooltip('Open navigation menu'), findsOneWidget);

    await pumpHeader(tester, onClose: () {});
    expect(find.byTooltip('Close'), findsOneWidget);
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
