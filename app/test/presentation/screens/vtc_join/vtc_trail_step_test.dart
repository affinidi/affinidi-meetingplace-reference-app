import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_trail_step.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_colors.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_icons.dart';

void main() {
  Future<void> pumpStep(WidgetTester tester, VtcTrailStage stage) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: VtcTrailStep(
              icon: McIcons.inbox,
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
      final danger = AppTheme.dark.extension<McColors>()!.dangerText;
      // A danger ring, never a red fill.
      expect((decoration.border! as Border).top.color, danger);
      expect(decoration.color, danger.withValues(alpha: 0.12));
      expect(find.byIcon(McIcons.error), findsOneWidget);
      expect(find.byIcon(McIcons.inbox), findsNothing);
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
              icon: McIcons.signature,
              stage: VtcTrailStage.done,
              title: 'Signed',
              summary: 'As your identity',
              actor: 'Your VTA',
              details: [VtcTrailDetail(McIcons.key, 'Signing key', 'key-1')],
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
              icon: McIcons.membership,
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
        if (span is TextSpan && span.style?.fontWeight == FontWeight.w500) {
          bold.add(span.text!);
        }
        return true;
      });
      expect(bold, ['Ada', 'Chess club']);
    });

    testWidgets('shows its own icon otherwise', (tester) async {
      await pumpStep(tester, VtcTrailStage.current);

      expect(find.byKey(const Key('vtc_trail_marker_failed')), findsNothing);
      expect(find.byIcon(McIcons.inbox), findsOneWidget);
    });

    Future<void> pumpTasks(WidgetTester tester, List<String> tasks) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: VtcTrailStep(
              key: const Key('step'),
              icon: McIcons.signature,
              stage: VtcTrailStage.done,
              title: 'Signed',
              summary: 'As your identity',
              actor: 'Your VTA',
              tasks: tasks,
              details: const [
                VtcTrailDetail(McIcons.key, 'Signing key', 'key-1'),
              ],
              isLast: true,
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('step')));
      await tester.pumpAndSettle();
    }

    testWidgets('names its one Trust Task after who did it', (tester) async {
      await pumpTasks(tester, ['https://trusttasks.org/spec/a/0.1']);

      expect(find.text('Trust Task'), findsOneWidget);
      final task = find.text('https://trusttasks.org/spec/a/0.1');
      expect(
        tester.getTopLeft(find.text('Your VTA')).dy,
        lessThan(tester.getTopLeft(task).dy),
      );
      expect(
        tester.getTopLeft(task).dy,
        lessThan(tester.getTopLeft(find.text('key-1')).dy),
      );
    });

    testWidgets('lists several Trust Tasks under one label', (tester) async {
      await pumpTasks(tester, [
        'https://trusttasks.org/spec/a/0.1',
        'https://trusttasks.org/spec/b/0.1',
      ]);

      expect(find.text('Trust Tasks'), findsOneWidget);
      expect(find.text('https://trusttasks.org/spec/a/0.1'), findsOneWidget);
      expect(find.text('https://trusttasks.org/spec/b/0.1'), findsOneWidget);
    });

    testWidgets('names no Trust Task when it took none', (tester) async {
      await pumpTasks(tester, []);

      expect(find.text('Trust Task'), findsNothing);
      expect(find.text('Trust Tasks'), findsNothing);
    });
  });
}
