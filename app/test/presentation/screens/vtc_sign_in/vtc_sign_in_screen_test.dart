import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_sign_in/vtc_sign_in_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_sign_in/vtc_sign_in_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_sign_in/vtc_sign_in_state.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/onboarding_style/onboarding_style.dart';

/// A sign-in held at one step, recording what the member chose.
class _FixedSignIn extends VtcSignInController {
  _FixedSignIn(this.fixed);

  final VtcSignInState fixed;
  final calls = <String>[];

  @override
  VtcSignInState build() => fixed;

  @override
  Future<void> approve() async => calls.add('approve');

  @override
  Future<void> decline() async => calls.add('decline');

  @override
  Future<void> submitNumber(String number) async => calls.add(number);
}

void main() {
  /// Seconds since the epoch, well before the sign-in expires.
  int deadline() =>
      DateTime.now().add(const Duration(minutes: 2)).millisecondsSinceEpoch ~/
      1000;

  Future<_FixedSignIn> pumpScreen(
    WidgetTester tester,
    VtcSignInState state,
  ) async {
    final controller = _FixedSignIn(state);
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [vtcSignInControllerProvider.overrideWith(() => controller)],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const VtcSignInScreen(),
        ),
      ),
    );
    await tester.pump();
    return controller;
  }

  /// Taps [finder] once it is scrolled into view.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  group('VtcSignInScreen', () {
    testWidgets('reviews the sign-in in a glass card, as joining does', (
      tester,
    ) async {
      final controller = await pumpScreen(
        tester,
        VtcSignInState(
          step: VtcSignInStep.review,
          communityName: 'Rivendell',
          website: 'https://rivendell.example',
          personaDid: 'did:key:z6Mk',
          decisionDeadline: deadline(),
          requester: const SignInRequester(
            browser: 'Firefox',
            os: 'Linux',
            location: 'Imladris',
            sameNetwork: true,
            createdAt: '2026-11-04T10:00:00Z',
          ),
        ),
      );

      expect(find.byType(OnboardingLayout), findsOneWidget);
      expect(find.text('Sign in to Rivendell'), findsOneWidget);
      expect(
        find.widgetWithText(GlassCard, 'Approve this sign-in?'),
        findsOneWidget,
      );
      expect(find.byType(OnboardingLine), findsNWidgets(4));

      await tapVisible(tester, find.text('Approve'));
      await tapVisible(tester, find.text('Decline'));
      expect(controller.calls, ['approve', 'decline']);
    });

    testWidgets('takes two digits and shows a bad number in place', (
      tester,
    ) async {
      final controller = await pumpScreen(
        tester,
        VtcSignInState(
          step: VtcSignInStep.number,
          communityName: 'Rivendell',
          decisionDeadline: deadline(),
          failure: SignInFailure.badNumber,
        ),
      );

      expect(
        find.widgetWithText(
          OnboardingMessage,
          'Enter the two digits shown on the sign-in page.',
        ),
        findsOneWidget,
      );

      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('vtc_sign_in_number')),
          matching: find.byType(EditableText),
        ),
        '4a27',
      );
      await tapVisible(tester, find.text('Continue'));
      expect(controller.calls, ['42']);
    });

    testWidgets('shows why it failed as an error on the gradient', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        VtcSignInState(
          step: VtcSignInStep.failed,
          failure: SignInFailure.expired,
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(
        find.widgetWithText(
          OnboardingMessage,
          'This code has expired. Get a new one.',
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(OnboardingButton, 'Done'), findsOneWidget);
    });
  });
}
