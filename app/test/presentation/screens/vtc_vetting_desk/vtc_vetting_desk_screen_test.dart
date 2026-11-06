import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_community_page.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_state.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_vetting_desk/vtc_vetting_desk_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_vetting_desk/vtc_vetting_desk_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

import '../../../fakes/fake_vetter_desk.dart';
import '../../../fakes/fake_vtc_network.dart';

void main() {
  late FakeVetterDesk fixture;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    fixture = FakeVetterDesk();
    await fixture.setUp();
  });

  Future<void> pump(WidgetTester tester, Widget home) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [vtcServiceProvider.overrideWithValue(fixture.service)],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      ),
    );
  }

  Future<void> pumpDesk(WidgetTester tester) => pump(
    tester,
    const VtcVettingDeskScreen(
      communityDid: fakeVtcDid,
      communityName: 'Football club',
    ),
  );

  /// Lets the fake network answer, then the spinners give way.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      // Work begun while building waits on the test's own clock too.
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Lets the fake network answer until [finder] shows, for up to a few
  /// seconds: a check verifies signatures and reads the status list.
  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
      await settle(tester);
    }
  }

  /// Picks up what the applicant sent, as the desk does every few seconds.
  Future<void> check(WidgetTester tester) async {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(VtcVettingDeskScreen)),
    );
    await tester.runAsync(
      () => container
          .read(vtcVettingDeskControllerProvider(fakeVtcDid).notifier)
          .check(),
    );
    await settle(tester);
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await settle(tester);
  }

  /// Closes the desk, so its checks stop, and lets the timeouts of what it
  /// asked lapse.
  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.pump(const Duration(minutes: 10));
  }

  testWidgets('shows a ticket to scan or read out', (tester) async {
    await pumpDesk(tester);
    await waitFor(tester, find.byKey(const Key('vtc_vetter_show_ticket')));

    await tap(tester, find.byKey(const Key('vtc_vetter_show_ticket')));
    await waitFor(tester, find.byKey(const Key('vtc_vetter_ticket_qr')));

    final desk = (await tester.runAsync(
      () => fixture.service.vetterDesk(fakeVtcDid),
    ))!;
    expect(find.byKey(const Key('vtc_vetter_ticket_qr')), findsOneWidget);
    expect(find.text(desk.tickets.single.code), findsOneWidget);
    await close(tester);
  });

  testWidgets('vets an applicant from match code to statement', (tester) async {
    final ticket = (await tester.runAsync(
      () => fixture.service.createVettingTicket(fakeVtcDid),
    ))!;
    await pumpDesk(tester);
    await waitFor(tester, find.byKey(const Key('vtc_vetter_ticket_qr')));
    await tester.runAsync(() => fixture.requestWith(ticket.spoken));
    await check(tester);

    final session = (await tester.runAsync(fixture.sentToApplicant))!.last;
    expect(find.text(vettingMatchCode(session.id)), findsOneWidget);
    await tap(tester, find.byKey(const Key('vtc_vetter_match_yes')));
    await waitFor(tester, find.byKey(const Key('vtc_vetter_card_waiting')));
    expect(find.byKey(const Key('vtc_vetter_card_waiting')), findsOneWidget);

    await tester.runAsync(() => fixture.sendCard(session));
    await check(tester);
    expect(find.text('Ada Lovelace'), findsOneWidget);
    final issue = find.byKey(const Key('vtc_vetter_issue'));
    await tap(tester, issue);
    expect((await tester.runAsync(fixture.sentToApplicant))!, hasLength(2));

    await tap(tester, find.byKey(const Key('vtc_vetter_document_passport')));
    await tap(tester, find.byKey(const Key('vtc_vetter_checked')));
    await tap(tester, issue);
    await waitFor(tester, find.textContaining('Issued'));

    final sent = (await tester.runAsync(fixture.sentToApplicant))!;
    expect(sent.last.type, VettingTask.issue);
    expect(find.byKey(const Key('vtc_vetter_ticket_qr')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('vtc_vetter_issued')),
        matching: find.textContaining('Issued'),
      ),
      findsOneWidget,
    );
    await close(tester);
  });

  testWidgets('declines when the match codes differ', (tester) async {
    final ticket = (await tester.runAsync(
      () => fixture.service.createVettingTicket(fakeVtcDid),
    ))!;
    await pumpDesk(tester);
    await waitFor(tester, find.byKey(const Key('vtc_vetter_ticket_qr')));
    await tester.runAsync(() => fixture.requestWith(ticket.spoken));
    await check(tester);

    await tap(tester, find.byKey(const Key('vtc_vetter_match_no')));
    await waitFor(tester, find.byKey(const Key('vtc_vetter_ticket_qr')));

    final decline = (await tester.runAsync(fixture.sentToApplicant))!.last;
    expect(decline.type, VettingTask.decline);
    expect(
      decline.payload['message'],
      VtcVettingDeskController.mismatchMessage,
    );
    await close(tester);
  });

  testWidgets('says so once the vetter card was withdrawn', (tester) async {
    fixture.network.revoked.add(3);

    await pumpDesk(tester);
    await waitFor(tester, find.byKey(const Key('vtc_vetter_not_vetter')));

    expect(find.byKey(const Key('vtc_vetter_not_vetter')), findsOneWidget);
    expect(find.byKey(const Key('vtc_vetter_show_ticket')), findsNothing);
    await close(tester);
  });

  group('the community page', () {
    Future<void> pumpPage(WidgetTester tester, String role) async {
      await pump(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: VtcCommunityPage(
              state: VtcJoinState(
                communityDid: fakeVtcDid,
                communityName: 'Football club',
                role: role,
              ),
              onDone: () {},
              leave: const SizedBox(key: Key('leave')),
            ),
          ),
        ),
      );
      await waitFor(
        tester,
        find.byKey(const Key('vtc_community_vetting_desk')),
      );
      addTearDown(() => close(tester));
    }

    testWidgets('offers the vetting desk to a vetter', (tester) async {
      await pumpPage(tester, 'vetter');

      expect(
        find.byKey(const Key('vtc_community_vetting_desk')),
        findsOneWidget,
      );
      expect(find.text('Vetter'), findsOneWidget);
    });

    testWidgets('offers no vetting desk once the card is withdrawn', (
      tester,
    ) async {
      fixture.network.revoked.add(3);

      await pumpPage(tester, 'vetter');

      expect(find.byKey(const Key('vtc_community_vetting_desk')), findsNothing);
    });

    testWidgets('offers no vetting desk to a member', (tester) async {
      await pumpPage(tester, 'member');

      expect(find.byKey(const Key('vtc_community_vetting_desk')), findsNothing);
    });
  });
}
