import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_sign_in/vtc_sign_in_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_sign_in/vtc_sign_in_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_sign_in/vtc_sign_in_state.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/onboarding_style/onboarding_style.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/vta_identity_card.dart';

import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_identities_service.dart';

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
        overrides: [
          vtcSignInControllerProvider.overrideWith(() => controller),
          identitiesServiceProvider.overrideWith(
            () => FakeIdentitiesService(
              IdentitiesServiceState(
                identities: [FakeIdentities.primaryIdentity],
              ),
            ),
          ),
        ],
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
          personaDid: FakeIdentities.primaryIdentity.did,
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
      expect(find.text('Signing in as'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(VtaIdentityCard),
          matching: find.text('John Doe'),
        ),
        findsOneWidget,
      );
      expect(find.byType(OnboardingLine), findsNWidgets(3));

      await tapVisible(tester, find.text('Approve'));
      await tapVisible(tester, find.text('Decline'));
      expect(controller.calls, ['approve', 'decline']);
    });

    testWidgets('asks to sign in as the identity card found on the VTA', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        VtcSignInState(
          step: VtcSignInStep.confirmMembership,
          communityName: 'Rivendell',
          personaDid: 'did:webvh:abc:vta.example',
        ),
      );

      expect(
        find.text(
          'Your membership of Rivendell was found on your VTA. '
          'Sign in as this identity?',
        ),
        findsOneWidget,
      );
      // An identity not on this phone shows by its DID and host.
      expect(find.text('did:webvh:abc:vta.example'), findsOneWidget);
      expect(find.text('vta.example'), findsOneWidget);
    });

    testWidgets('shows a bad number in place', (tester) async {
      await pumpScreen(
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
    });

    group('number', () {
      Finder digit(int index) => find.descendant(
        of: find.byKey(Key('vtc_sign_in_digit_$index')),
        matching: find.byType(EditableText),
      );

      String textOf(WidgetTester tester, int index) =>
          tester.widget<EditableText>(digit(index)).controller.text;

      Future<_FixedSignIn> pumpNumber(WidgetTester tester) => pumpScreen(
        tester,
        VtcSignInState(
          step: VtcSignInStep.number,
          communityName: 'Rivendell',
          decisionDeadline: deadline(),
        ),
      );

      testWidgets('takes one digit per box and sends both', (tester) async {
        final controller = await pumpNumber(tester);

        await tester.enterText(digit(0), '4');
        await tester.pump();
        expect(
          tester.widget<EditableText>(digit(1)).focusNode.hasFocus,
          isTrue,
        );
        await tester.enterText(digit(1), '2');
        await tester.pump();

        expect(controller.calls, ['42']);
      });

      testWidgets('spreads pasted digits over the boxes', (tester) async {
        final controller = await pumpNumber(tester);

        await tester.enterText(digit(0), '4a27');
        await tester.pump();

        expect(textOf(tester, 0), '4');
        expect(textOf(tester, 1), '2');
        expect(controller.calls, ['42']);
      });

      testWidgets('goes back a box on backspace in an empty one', (
        tester,
      ) async {
        await pumpNumber(tester);

        await tester.enterText(digit(0), '4');
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
        await tester.pump();

        expect(textOf(tester, 0), isEmpty);
        expect(
          tester.widget<EditableText>(digit(0)).focusNode.hasFocus,
          isTrue,
        );
      });

      testWidgets('sends what is typed on Continue', (tester) async {
        final controller = await pumpNumber(tester);

        await tester.enterText(digit(0), '7');
        await tapVisible(tester, find.text('Continue'));

        expect(controller.calls, ['7']);
      });
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
