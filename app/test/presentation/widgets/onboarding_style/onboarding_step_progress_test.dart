import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/onboarding_style/onboarding_style.dart';

void main() {
  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
  ]) {
    testWidgets(
      'names the step and fills the bar up to it in the $name theme',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: OnboardingStepProgress(
                step: 2,
                total: 4,
                title: 'Compare codes',
              ),
            ),
          ),
        );

        expect(find.text('Step 2 of 4 · Compare codes'), findsOneWidget);
        expect(
          tester
              .widget<LinearProgressIndicator>(
                find.byType(LinearProgressIndicator),
              )
              .value,
          0.5,
        );
      },
    );
  }
}
