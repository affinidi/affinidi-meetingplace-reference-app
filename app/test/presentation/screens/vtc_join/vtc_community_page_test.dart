import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_community_page.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_state.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester, VtcJoinState state) {
    return tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: VtcCommunityPage(
                state: state,
                onDone: () {},
                leave: const SizedBox(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  final joined = VtcJoinState(
    step: VtcJoinStep.joined,
    communityName: 'Football club',
  );

  group('VtcCommunityPage membership card', () {
    /// The step [key] names: a tick, a spinner, or a dimmed circle.
    Finder marker(String key, Finder matching) =>
        find.descendant(of: find.byKey(Key(key)), matching: matching);

    testWidgets('shows each step of finding the card on the VTA', (
      tester,
    ) async {
      await pumpPage(
        tester,
        joined.copyWith(
          gettingCard: true,
          cardStep: MembershipCardStep.reading,
        ),
      );

      expect(find.text('Getting your membership card…'), findsOne);
      expect(
        find.text('Looking on your VTA for the card Football club issued you'),
        findsOne,
      );
      expect(find.text('Opening your card'), findsOne);
      expect(
        marker('vtc_card_step_finding', find.byIcon(Icons.check_circle)),
        findsOne,
      );
      expect(
        marker('vtc_card_step_reading', find.byType(CircularProgressIndicator)),
        findsOne,
      );
      expect(
        find.byKey(const Key('vtc_membership_card_pending')),
        findsNothing,
      );
    });

    testWidgets('starts with looking on the VTA', (tester) async {
      await pumpPage(tester, joined.copyWith(gettingCard: true));

      expect(
        marker('vtc_card_step_finding', find.byType(CircularProgressIndicator)),
        findsOne,
      );
      expect(
        marker(
          'vtc_card_step_reading',
          find.byIcon(Icons.radio_button_unchecked),
        ),
        findsOne,
      );
    });

    testWidgets('says the card is on its way while nothing fetches it', (
      tester,
    ) async {
      await pumpPage(tester, joined);

      expect(find.byKey(const Key('vtc_membership_card_pending')), findsOne);
      expect(
        find.byKey(const Key('vtc_membership_card_loading')),
        findsNothing,
      );
    });
  });
}
