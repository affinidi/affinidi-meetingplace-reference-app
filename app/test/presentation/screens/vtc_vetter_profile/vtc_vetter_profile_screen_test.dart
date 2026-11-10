import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_vetter_profile/vtc_vetter_profile_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

import '../../../fakes/fake_vetter_desk.dart';
import '../../../fakes/fake_vtc_network.dart';

void main() {
  late FakeVetterDesk fixture;

  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/vtc_vetter_profile_screen_test.log'),
    );
  });

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    fixture = FakeVetterDesk();
    await fixture.setUp();
  });

  /// Lets the fake network answer, then the spinners give way.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
      await settle(tester);
    }
  }

  /// Opens the profile from a page of its own, as the desk does.
  Future<void> open(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [vtcServiceProvider.overrideWithValue(fixture.service)],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              key: const Key('open'),
              onPressed: () => VtcVetterProfileScreen.show(
                context,
                communityDid: fakeVtcDid,
                communityName: 'Football club',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open')));
    await settle(tester);
  }

  Finder publishButton() => find.byKey(const Key('vtc_vetter_profile_publish'));

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
  }

  testWidgets('starts unlisted, in the device language, with no method', (
    tester,
  ) async {
    await open(tester);
    await waitFor(tester, publishButton());

    final listed = tester.widget<Switch>(
      find.byKey(const Key('vtc_vetter_profile_listed')),
    );
    expect(listed.value, isFalse);
    expect(find.text('en'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.descendant(
              of: publishButton(),
              matching: find.byType(ElevatedButton),
            ),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('publishes what the member chose, and closes', (tester) async {
    await open(tester);
    await waitFor(tester, publishButton());

    await tester.enterText(
      find.byKey(const Key('vtc_vetter_profile_name')),
      'Bob',
    );
    await tester.enterText(
      find.byKey(const Key('vtc_vetter_profile_country')),
      'de',
    );
    await tapVisible(
      tester,
      find.byKey(const Key('vtc_vetter_profile_listed')),
    );
    await tapVisible(
      tester,
      find.byKey(const Key('vtc_vetter_profile_method_inPerson')),
    );
    await tapVisible(
      tester,
      find.byKey(const Key('vtc_vetter_profile_document_passport')),
    );
    await tapVisible(tester, publishButton());
    await waitFor(tester, find.byKey(const Key('open')).hitTestable());
    // The page beneath takes taps as soon as the pop starts; let it end.
    await tester.pumpAndSettle();

    expect(fixture.network.vetterProfiles.single['payload'], {
      'listed': true,
      'displayName': 'Bob',
      'languages': ['en'],
      'location': {'country': 'DE'},
      'methods': ['inPerson'],
      'acceptsDocumentation': ['passport'],
      'events': <Object>[],
    });
    expect(find.byType(VtcVetterProfileScreen), findsNothing);
  });

  testWidgets('starts from the profile the community stored', (tester) async {
    // Real I/O: the fake network answers outside the test's fake clock.
    await tester.runAsync(
      () => fixture.service.publishVetterProfile(
        fakeVtcDid,
        const VetterProfile(
          displayName: 'Bob',
          languages: ['de', 'en'],
          methods: [VettingMethod.video],
        ),
      ),
    );

    await open(tester);
    await waitFor(tester, publishButton());

    expect(find.byKey(const Key('vtc_vetter_profile_stored')), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('de, en'), findsOneWidget);
    expect(
      tester
          .widget<FilterChip>(
            find.byKey(const Key('vtc_vetter_profile_method_video')),
          )
          .selected,
      isTrue,
    );
  });

  testWidgets('says what the community would refuse, and sends nothing', (
    tester,
  ) async {
    await open(tester);
    await waitFor(tester, publishButton());

    await tester.enterText(
      find.byKey(const Key('vtc_vetter_profile_languages')),
      'english',
    );
    await tapVisible(
      tester,
      find.byKey(const Key('vtc_vetter_profile_method_video')),
    );
    await tapVisible(tester, publishButton());
    await waitFor(tester, find.byKey(const Key('vtc_vetter_profile_failure')));

    expect(find.byKey(const Key('vtc_vetter_profile_failure')), findsOneWidget);
    expect(fixture.network.vetterProfiles, isEmpty);
  });

  testWidgets('offers nothing to a member who may not vet', (tester) async {
    fixture.network.revoked.add(3);

    await open(tester);
    await waitFor(
      tester,
      find.byKey(const Key('vtc_vetter_profile_not_vetter')),
    );

    expect(publishButton(), findsNothing);
    // Looking for a vetter card in the inbox borrowed keys, forgotten once
    // idle.
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.pump(const Duration(minutes: 10));
  });
}
