import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_custom_colors.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/identity_picker/identity_card.dart';
import 'package:pie_menu/pie_menu.dart';

import '../../../fakes/fake_cache_manager.dart';
import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_vta.dart';

final _onVta = FakeIdentities.primaryIdentity.copyWith(
  vtaContextId: 'mpx-1',
  vtaProfileId: '01PROFILE',
);

void main() {
  late FakeVta vta;

  Future<void> pump(
    WidgetTester tester,
    Identity identity, {
    IdentityCardSize size = IdentityCardSize.normal,
  }) async {
    vta = FakeVta()
      ..answers[VtaTask.localProfileGet] = {
        'profile': {'profileId': '01PROFILE', 'entries': <Object>[]},
      };
    final vtc = await tester.runAsync(vta.linkedService);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [vtcServiceProvider.overrideWithValue(vtc!)],
        child: MaterialApp(
          theme: ThemeData(extensions: const [AppCustomColors()]),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PieCanvas(
              child: Center(
                child: SizedBox(
                  height: 430,
                  child: IdentityCard(
                    identity: identity,
                    identityCardSize: size,
                    cacheManager: FakeCacheManager(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('IdentityCard', () {
    testWidgets('shows where an identity on the VTA lives, collapsed', (
      tester,
    ) async {
      await pump(tester, _onVta);

      expect(find.text('VTA details'), findsOneWidget);
      expect(find.text('mpx-1'), findsNothing);
    });

    testWidgets('leaves out VTA details for an identity not on it', (
      tester,
    ) async {
      await pump(tester, FakeIdentities.primaryIdentity);

      expect(find.text('VTA details'), findsNothing);
    });

    testWidgets('leaves out VTA details on a small card', (tester) async {
      await pump(tester, _onVta, size: IdentityCardSize.small);

      expect(find.text('VTA details'), findsNothing);
    });

    testWidgets('keeps the action button clear of the opened details', (
      tester,
    ) async {
      await pump(tester, _onVta);

      await tester.tap(find.byKey(const Key('vta_details_toggle')));
      // A frame first, so the section listens before the VTA answers.
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.text('mpx-1'), findsOneWidget);
      final card = tester.getRect(find.byType(IdentityCard));
      // The star of the action button; its ripple is drawn in the same place.
      final button = tester.getRect(
        find
            .image(
              const AssetImage(
                'assets/images/meeting-place-splash-white-1024.png',
              ),
            )
            .first,
      );
      expect(card.contains(button.center), isTrue);
      final scroll = tester.getRect(
        find
            .descendant(
              of: find.byType(IdentityCard),
              matching: find.byType(SingleChildScrollView),
            )
            .first,
      );
      expect(scroll.bottom, lessThanOrEqualTo(button.top));
    });
  });
}
