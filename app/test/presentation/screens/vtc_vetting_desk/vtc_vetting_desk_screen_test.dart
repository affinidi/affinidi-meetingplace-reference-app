import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_vetter_desk.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_community_page.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_state.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_vetting_desk/vtc_vetting_desk_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_vetting_desk/vtc_vetting_desk_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_vetting_desk/vtc_vetting_desk_state.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

import '../../../fakes/fake_vetter_desk.dart';
import '../../../fakes/fake_vtc_network.dart';

void main() {
  late FakeVetterDesk fixture;

  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/vtc_vetting_desk_screen_test.log'),
    );
  });

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

  /// The desk, also while the vetting flow covers it.
  final desk = find.byType(VtcVettingDeskScreen, skipOffstage: false);

  /// Picks up what the applicant sent, as the desk does every few seconds.
  Future<void> check(WidgetTester tester) async {
    final container = ProviderScope.containerOf(tester.element(desk));
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

  /// Whether the desk on show waits on the applicant.
  bool waiting(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(desk))
          .read(vtcVettingDeskControllerProvider(fakeVtcDid))
          .waitingOnApplicant(DateTime.now());

  /// Goes back to the ticket left open on the desk.
  Future<void> resume(WidgetTester tester) async {
    await waitFor(tester, find.byKey(const Key('vtc_vetter_resume')));
    await tap(tester, find.byKey(const Key('vtc_vetter_resume')));
    await waitFor(tester, find.byKey(const Key('vtc_vetter_ticket_qr')));
  }

  /// The step of vetting an applicant the desk on show is at.
  VtcVettingFlowStep? flowStep(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(desk))
          .read(vtcVettingDeskControllerProvider(fakeVtcDid))
          .flowStep(DateTime.now());

  /// Closes the desk, so its checks stop, and lets the timeouts of what it
  /// asked lapse.
  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.pump(const Duration(minutes: 10));
  }

  test('says how far creating a ticket got', () async {
    final container = ProviderContainer(
      overrides: [vtcServiceProvider.overrideWithValue(fixture.service)],
    );
    addTearDown(container.dispose);
    final provider = vtcVettingDeskControllerProvider(fakeVtcDid);
    final steps = <VtcTicketStep?>[];
    container.listen(
      provider.select((state) => state.ticketStep),
      (_, next) => steps.add(next),
    );

    await container.read(provider.notifier).startVetting();

    expect(steps, [VtcTicketStep.checkingCard, VtcTicketStep.creating, null]);
    expect(
      container.read(provider).flowStep(DateTime.now()),
      VtcVettingFlowStep.ticket,
    );
  });

  testWidgets('shows a ticket to scan or read out', (tester) async {
    await pumpDesk(tester);
    await waitFor(tester, find.byKey(const Key('vtc_vetter_show_ticket')));

    final showTicket = find.byKey(const Key('vtc_vetter_show_ticket'));
    await tester.ensureVisible(showTicket);
    await tester.tap(showTicket);
    // The flow opens at once and says what it does before the ticket shows.
    await tester.pump();
    await tester.pump();
    expect(find.byType(VtcVettingFlowScreen), findsOneWidget);
    expect(find.byKey(const Key('vtc_vetter_ticket_progress')), findsOneWidget);
    expect(find.text('Checking your vetter card is still valid'), findsOne);
    expect(find.text('Creating your ticket'), findsOne);
    expect(find.byKey(const Key('vtc_vetter_new_ticket')), findsNothing);

    await waitFor(tester, find.byKey(const Key('vtc_vetter_ticket_qr')));
    expect(find.byKey(const Key('vtc_vetter_ticket_progress')), findsNothing);

    final recorded = (await tester.runAsync(
      () => fixture.service.vetterDesk(fakeVtcDid),
    ))!;
    expect(find.text('Step 1 of 4 · Show your ticket'), findsOneWidget);
    expect(find.byKey(const Key('vtc_vetter_ticket_qr')), findsOneWidget);
    expect(find.text(recorded.tickets.single.code), findsOneWidget);
    await close(tester);
  });

  testWidgets('keeps the ticket open when the flow is closed', (tester) async {
    await pumpDesk(tester);
    await waitFor(tester, find.byKey(const Key('vtc_vetter_show_ticket')));
    await tap(tester, find.byKey(const Key('vtc_vetter_show_ticket')));
    await waitFor(tester, find.byKey(const Key('vtc_vetter_ticket_qr')));

    await tap(
      tester,
      find.descendant(
        of: find.byType(VtcVettingFlowScreen),
        matching: find.byIcon(Icons.close),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(VtcVettingFlowScreen), findsNothing);
    expect(find.byKey(const Key('vtc_vetter_show_ticket')), findsNothing);

    await resume(tester);
    expect(find.text('Step 1 of 4 · Show your ticket'), findsOneWidget);
    await close(tester);
  });

  testWidgets('vets an applicant from match code to statement', (tester) async {
    final ticket = (await tester.runAsync(
      () => fixture.service.createVettingTicket(fakeVtcDid),
    ))!;
    await pumpDesk(tester);
    await resume(tester);
    expect(flowStep(tester), VtcVettingFlowStep.ticket);
    expect(waiting(tester), isTrue);
    await tester.runAsync(() => fixture.requestWith(ticket.spoken));
    await check(tester);

    final session = (await tester.runAsync(fixture.sentToApplicant))!.last;
    expect(flowStep(tester), VtcVettingFlowStep.match);
    expect(waiting(tester), isFalse);
    expect(find.text('Step 2 of 4 · Compare codes'), findsOneWidget);
    expect(find.text(vettingMatchCode(session.id)), findsOneWidget);
    await tap(tester, find.byKey(const Key('vtc_vetter_match_yes')));
    await waitFor(tester, find.byKey(const Key('vtc_vetter_card_waiting')));
    expect(flowStep(tester), VtcVettingFlowStep.details);
    expect(waiting(tester), isTrue);
    expect(find.text('Step 3 of 4 · Check their details'), findsOneWidget);
    expect(find.byKey(const Key('vtc_vetter_card_waiting')), findsOneWidget);

    await tester.runAsync(() => fixture.sendCard(session));
    await check(tester);
    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(waiting(tester), isFalse);
    final issue = find.byKey(const Key('vtc_vetter_issue'));
    await tap(tester, issue);
    expect((await tester.runAsync(fixture.sentToApplicant))!, hasLength(2));

    await tap(tester, find.byKey(const Key('vtc_vetter_document_passport')));
    await tap(tester, find.byKey(const Key('vtc_vetter_checked')));
    await tap(tester, issue);
    await waitFor(tester, find.byKey(const Key('vtc_vetter_outcome')));

    final sent = (await tester.runAsync(fixture.sentToApplicant))!;
    expect(sent.last.type, VettingTask.issue);
    expect(flowStep(tester), VtcVettingFlowStep.done);
    expect(find.text('Step 4 of 4 · Done'), findsOneWidget);
    expect(
      find.text('You vouched for them. They now hold your statement.'),
      findsOneWidget,
    );

    await tap(tester, find.byKey(const Key('vtc_vetter_outcome_done')));
    await waitFor(tester, find.textContaining('Issued'));
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
    await resume(tester);
    await tester.runAsync(() => fixture.requestWith(ticket.spoken));
    await check(tester);

    await tap(tester, find.byKey(const Key('vtc_vetter_match_no')));
    await waitFor(tester, find.byKey(const Key('vtc_vetter_outcome')));
    expect(find.text('You declined to vouch for them.'), findsOneWidget);

    final decline = (await tester.runAsync(fixture.sentToApplicant))!.last;
    expect(decline.type, VettingTask.decline);
    expect(
      decline.payload['message'],
      VtcVettingDeskController.mismatchMessage,
    );
    await close(tester);
  });

  testWidgets('declines while waiting for the applicant\'s details', (
    tester,
  ) async {
    final ticket = (await tester.runAsync(
      () => fixture.service.createVettingTicket(fakeVtcDid),
    ))!;
    await pumpDesk(tester);
    await resume(tester);
    await tester.runAsync(() => fixture.requestWith(ticket.spoken));
    await check(tester);
    await tap(tester, find.byKey(const Key('vtc_vetter_match_yes')));
    await waitFor(tester, find.byKey(const Key('vtc_vetter_card_waiting')));

    await tap(tester, find.byKey(const Key('vtc_vetter_decline')));
    await waitFor(tester, find.byKey(const Key('vtc_vetter_outcome')));
    await tap(tester, find.byKey(const Key('vtc_vetter_outcome_done')));
    // The ticket was good once, so a new one is offered.
    await waitFor(tester, find.byKey(const Key('vtc_vetter_show_ticket')));

    final decline = (await tester.runAsync(fixture.sentToApplicant))!.last;
    expect(decline.type, VettingTask.decline);
    expect(find.byKey(const Key('vtc_vetter_show_ticket')), findsOneWidget);
    await close(tester);
  });

  testWidgets('lists what the community asks the vetter to check', (
    tester,
  ) async {
    final criteria = fixture.network.joinManifest['criteria'] as List;
    final vetting =
        (criteria.last as Map<String, dynamic>)['vetting']
            as Map<String, dynamic>;
    vetting
      ..['requiredClaims'] = ['name.given', 'name.family']
      ..['acceptedDocumentClasses'] = ['passport'];

    await pumpDesk(tester);
    await waitFor(tester, find.byKey(const Key('vtc_vetter_requirements')));

    final card = find.byKey(const Key('vtc_vetter_requirements'));
    for (final text in ['first name', 'last name', 'Passport']) {
      expect(
        find.descendant(of: card, matching: find.textContaining(text)),
        findsOneWidget,
        reason: text,
      );
    }
    await close(tester);
  });

  testWidgets('opens the desk before the vetter card is checked', (
    tester,
  ) async {
    fixture.network.revoked.add(3);

    await pumpDesk(tester);
    // The desk reads from this phone; the check needs the network.
    await tester.pump();
    expect(find.byKey(const Key('vtc_vetter_show_ticket')), findsOneWidget);

    await waitFor(tester, find.byKey(const Key('vtc_vetter_not_vetter')));
    expect(find.byKey(const Key('vtc_vetter_show_ticket')), findsNothing);
    await close(tester);
  });

  testWidgets('opens the desk before the requirements are read', (
    tester,
  ) async {
    final requirements = find.byKey(const Key('vtc_vetter_requirements'));
    final progress = find.byKey(const Key('vtc_vetter_progress'));

    await pumpDesk(tester);
    await tester.pump();
    expect(find.byKey(const Key('vtc_vetter_show_ticket')), findsOneWidget);
    expect(requirements, findsNothing);
    expect(find.text('Checking your vetter card is still valid'), findsOne);
    expect(find.text('Getting what Football club asks you to check'), findsOne);

    await waitFor(tester, requirements);
    expect(requirements, findsOneWidget);
    for (var i = 0; i < 100 && progress.evaluate().isNotEmpty; i++) {
      await settle(tester);
    }
    expect(progress, findsNothing);
    await close(tester);
  });

  testWidgets('shows the vetter card it checked', (tester) async {
    final card = find.byKey(const Key('vtc_vetter_role_card'));

    await pumpDesk(tester);
    await tester.pump();
    // Shown once checked, not from what the phone recorded.
    expect(card, findsNothing);

    await waitFor(tester, card);
    expect(
      find.descendant(of: card, matching: find.text('Vetter card')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text(fixture.vetter.did)),
      findsOneWidget,
    );
    await close(tester);
  });

  testWidgets('says so once the vetter card was withdrawn', (tester) async {
    fixture.network.revoked.add(3);

    await pumpDesk(tester);
    await waitFor(tester, find.byKey(const Key('vtc_vetter_not_vetter')));

    expect(find.byKey(const Key('vtc_vetter_not_vetter')), findsOneWidget);
    expect(find.byKey(const Key('vtc_vetter_show_ticket')), findsNothing);
    expect(find.byKey(const Key('vtc_vetter_role_card')), findsNothing);
    await close(tester);
  });

  group('the community page', () {
    Future<void> showPage(WidgetTester tester, String? role) => pump(
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

    /// Shows the page once its vetter card check answered, rather than
    /// waiting out [waitFor] for a desk that may never show.
    Future<void> pumpPage(WidgetTester tester, String? role) async {
      await showPage(tester, role);
      for (var i = 0; i < 100 && fixture.service.vetterChecks == 0; i++) {
        await settle(tester);
      }
      await tester.pump();
    }

    testWidgets('offers the vetting desk to a vetter', (tester) async {
      await pumpPage(tester, 'vetter');

      expect(
        find.byKey(const Key('vtc_community_vetting_desk')),
        findsOneWidget,
      );
      expect(find.text('Vetter'), findsOneWidget);
      await close(tester);
    });

    testWidgets('offers the vetting desk as an icon beside the role', (
      tester,
    ) async {
      await pumpPage(tester, 'vetter');

      expect(
        find.descendant(
          of: find.byKey(const Key('vtc_community_role')),
          matching: find.byKey(const Key('vtc_community_vetting_desk')),
        ),
        findsOneWidget,
      );
      expect(find.byTooltip('Vet applicants'), findsOneWidget);
      expect(find.text('Vet applicants'), findsNothing);
      await close(tester);
    });

    testWidgets('offers no vetting desk once the card is withdrawn', (
      tester,
    ) async {
      fixture.network.revoked.add(3);

      await pumpPage(tester, 'vetter');

      expect(find.byKey(const Key('vtc_community_vetting_desk')), findsNothing);
      await close(tester);
    });

    testWidgets('offers the vetting desk as last checked until the check', (
      tester,
    ) async {
      final desk = find.byKey(const Key('vtc_community_vetting_desk'));
      await tester.runAsync(() => fixture.service.canVet(fakeVtcDid));
      fixture.network.revoked.add(3);

      await showPage(tester, 'vetter');
      // The last answer reads from this phone; the check needs the network.
      await tester.pump();
      // Only the last answer offers it: the card is withdrawn by now.
      expect(desk, findsOneWidget);

      for (var i = 0; i < 100 && desk.evaluate().isNotEmpty; i++) {
        await settle(tester);
      }
      expect(desk, findsNothing);
      await close(tester);
    });

    testWidgets('offers the vetting desk to a vetter shown as a member', (
      tester,
    ) async {
      // The newest role card may be the membership's, not the vetter's.
      await pumpPage(tester, 'member');

      expect(
        find.byKey(const Key('vtc_community_vetting_desk')),
        findsOneWidget,
      );
      await close(tester);
    });

    testWidgets('says so when the vetter card cannot be checked', (
      tester,
    ) async {
      fixture.network.isStatusListDown = true;

      await showPage(tester, 'member');
      await waitFor(
        tester,
        find.byKey(const Key('vtc_community_vetting_check_failed')),
      );

      expect(
        find.byKey(const Key('vtc_community_vetting_check_failed')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('vtc_community_vetting_desk')), findsNothing);
      await close(tester);
    });

    testWidgets('checks the vetter card before the role is read', (
      tester,
    ) async {
      fixture.network.isStatusListDown = true;

      await showPage(tester, null);
      await waitFor(
        tester,
        find.byKey(const Key('vtc_community_vetting_check_failed')),
      );

      expect(
        find.byKey(const Key('vtc_community_vetting_check_failed')),
        findsOneWidget,
      );
      await close(tester);
    });

    testWidgets('offers no vetting desk to a member who is no vetter', (
      tester,
    ) async {
      fixture.network.vta.answerTo[VtaTask.credentialsQuery] = (_) => {
        'credentials': <Object>[],
      };

      await pumpPage(tester, 'member');

      expect(find.byKey(const Key('vtc_community_vetting_desk')), findsNothing);
      await close(tester);
    });
  });
}
