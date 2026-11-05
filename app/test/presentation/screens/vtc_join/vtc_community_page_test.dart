import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
    testWidgets('shows a spinner while the card is being fetched', (
      tester,
    ) async {
      await pumpPage(tester, joined.copyWith(gettingCard: true));

      expect(find.byKey(const Key('vtc_membership_card_loading')), findsOne);
      expect(find.byType(CircularProgressIndicator), findsOne);
      expect(find.text('Getting your membership card…'), findsOne);
      expect(
        find.byKey(const Key('vtc_membership_card_pending')),
        findsNothing,
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
