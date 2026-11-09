import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/section_banner.dart';

void main() {
  final progress = find.byKey(const Key('section_banner_progress'));

  Future<void> pumpBanner(
    WidgetTester tester, {
    bool? showProgress,
    VoidCallback? onClose,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: SectionBanner(
          title: 'Credentials',
          subtitle: 'Your wallet',
          showProgress: showProgress,
          onClose: onClose,
        ),
      ),
    ),
  );

  testWidgets('shows progress beside the button, which stays usable', (
    tester,
  ) async {
    var closed = 0;
    await pumpBanner(tester, showProgress: true, onClose: () => closed++);

    expect(progress, findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    expect(closed, 1);
    expect(
      tester.getCenter(progress).dx,
      lessThan(tester.getCenter(find.byIcon(Icons.close)).dx),
    );
  });

  testWidgets('shows no progress unless asked', (tester) async {
    await pumpBanner(tester);

    expect(progress, findsNothing);
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });
}
