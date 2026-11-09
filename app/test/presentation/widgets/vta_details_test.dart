import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_icons.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/vta_details.dart';

import '../../fakes/fake_vta.dart';

void main() {
  late FakeVta vta;
  late VtcService vtc;

  final thumbnail = 'A' * 1000;
  Map<String, dynamic> document() => {
    'profileId': '01PROFILE',
    'version': 2,
    'entries': [
      {
        'slot': 'avatar',
        'inline': {
          'type': 'x:photo.thumbnail',
          'valueType': 'string',
          'value': thumbnail,
        },
      },
    ],
  };

  Iterable<Object?> profileReads() => vta.received
      .map((request) => request['type'])
      .where((type) => type == VtaTask.localProfileGet);

  setUp(() async {
    vta = FakeVta()..answers[VtaTask.localProfileGet] = {'profile': document()};
    vtc = await vta.linkedService();
  });

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      overrides: [vtcServiceProvider.overrideWithValue(vtc)],
      child: MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Center(
            child: VtaDetailsButton(contextId: 'mpx-1', profileId: '01PROFILE'),
          ),
        ),
      ),
    ),
  );

  // The fake VTA answers over a real HTTP stack, outside the fake clock.
  // A frame first, so the sheet listens before the VTA answers.
  Future<void> answered(WidgetTester tester) async {
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('vta_details_toggle')));
    await answered(tester);
  }

  group('VtaDetailsButton', () {
    testWidgets('shows the shield, and reads nothing, until tapped', (
      tester,
    ) async {
      await pump(tester);

      expect(find.byIcon(McIcons.shield), findsOneWidget);
      expect(find.byTooltip('VTA details'), findsOneWidget);
      expect(find.text('mpx-1'), findsNothing);
      expect(profileReads(), isEmpty);
    });

    testWidgets('opens a sheet of the context, the profile and its JSON', (
      tester,
    ) async {
      await pump(tester);
      await open(tester);

      expect(find.byKey(const Key('vta_details_sheet')), findsOneWidget);
      expect(find.text('VTA details'), findsOneWidget);
      expect(find.text('mpx-1'), findsOneWidget);
      expect(find.text('01PROFILE'), findsOneWidget);
      final json = tester
          .widget<SelectableText>(find.byKey(const Key('vta_details_profile')))
          .data!;
      expect(json, contains('"version": 2'));
      expect(json, contains('"x:photo.thumbnail"'));
      expect(json, contains('AAAA… (1000 characters)'));
      expect(json, isNot(contains(thumbnail)));
      expect(profileReads(), hasLength(1));
    });

    testWidgets('marks the sheet in the secondary colour', (tester) async {
      await pump(tester);
      await open(tester);

      final badge = tester.widget<CircleAvatar>(
        find.descendant(
          of: find.byKey(const Key('vta_details_sheet')),
          matching: find.byType(CircleAvatar),
        ),
      );
      expect(badge.backgroundColor, AppTheme.dark.colorScheme.secondary);
    });

    testWidgets('sets the profile JSON in a panel of its own', (tester) async {
      await pump(tester);
      await open(tester);

      expect(
        find.descendant(
          of: find.byKey(const Key('vta_details_profile_panel')),
          matching: find.byKey(const Key('vta_details_profile')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('closes the sheet', (tester) async {
      await pump(tester);
      await open(tester);

      await tester.tap(find.byKey(const Key('vta_details_close')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('vta_details_sheet')), findsNothing);
    });

    testWidgets('copies the whole profile', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pump(tester);
      await open(tester);

      await tester.tap(find.byKey(const Key('vta_details_copy_profile')));
      await tester.pumpAndSettle();

      expect(copied, contains(thumbnail));
      expect(find.text('Copied to clipboard'), findsOneWidget);
    });

    testWidgets('says when the profile cannot be read, and retries', (
      tester,
    ) async {
      vta.isDown = true;
      await pump(tester);
      await open(tester);

      expect(
        find.text("Couldn't read this profile from your VTA."),
        findsOneWidget,
      );
      expect(find.text('mpx-1'), findsOneWidget);

      vta.isDown = false;
      await tester.tap(find.text('Retry'));
      await answered(tester);

      expect(find.byKey(const Key('vta_details_profile')), findsOneWidget);
    });
  });
}
