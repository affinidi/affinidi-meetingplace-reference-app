import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_trail_step.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

void main() {
  Future<void> pumpStep(WidgetTester tester, VtcTrailStage stage) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: VtcTrailStep(
              icon: Icons.inbox_outlined,
              stage: stage,
              title: 'Signed in',
              summary: 'Trying again',
              isLast: true,
            ),
          ),
        ),
      );

  group('VtcTrailStep', () {
    testWidgets('marks a failed step in the error colour', (tester) async {
      await pumpStep(tester, VtcTrailStage.failed);

      final marker = tester.widget<Container>(
        find.byKey(const Key('vtc_trail_marker_failed')),
      );
      final decoration = marker.decoration! as BoxDecoration;
      expect(decoration.color, AppTheme.dark.colorScheme.error);
      expect(find.byIcon(Icons.priority_high), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    });

    testWidgets('names who did it first among its details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: VtcTrailStep(
              key: Key('step'),
              icon: Icons.draw_outlined,
              stage: VtcTrailStage.done,
              title: 'Signed',
              summary: 'As your identity',
              actor: 'Your VTA',
              details: [
                VtcTrailDetail(Icons.key_outlined, 'Signing key', 'key-1'),
              ],
              isLast: true,
            ),
          ),
        ),
      );
      expect(find.text('Your VTA'), findsNothing);

      await tester.tap(find.byKey(const Key('step')));
      await tester.pumpAndSettle();

      expect(find.text('Done by'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Your VTA')).dy,
        lessThan(tester.getTopLeft(find.text('key-1')).dy),
      );
    });

    testWidgets('sets the names in its summary apart', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: VtcTrailStep(
              icon: Icons.card_membership_outlined,
              stage: VtcTrailStage.done,
              title: 'Issued by Chess club',
              summary: 'Your card for Ada, signed by Chess club on Nov 4',
              highlights: ['Ada', 'Chess club'],
              isLast: true,
            ),
          ),
        ),
      );

      final summary = tester.widget<Text>(
        find.text('Your card for Ada, signed by Chess club on Nov 4'),
      );
      final bold = <String>[];
      summary.textSpan!.visitChildren((span) {
        if (span is TextSpan && span.style?.fontWeight == FontWeight.bold) {
          bold.add(span.text!);
        }
        return true;
      });
      expect(bold, ['Ada', 'Chess club']);
    });

    testWidgets('shows its own icon otherwise', (tester) async {
      await pumpStep(tester, VtcTrailStage.current);

      expect(find.byKey(const Key('vtc_trail_marker_failed')), findsNothing);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });
  });
}
