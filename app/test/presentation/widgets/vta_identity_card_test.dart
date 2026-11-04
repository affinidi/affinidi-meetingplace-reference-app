import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/cache_manager_provider.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/vta_identity_card.dart';

import '../../fakes/fake_cache_manager.dart';

const _did = 'did:webvh:QmP:vta.example:ada';

const _card = ContactCard(
  id: 'id-1',
  did: _did,
  type: 'individual',
  displayName: 'Ada L',
  firstName: 'Ada',
  lastName: 'Lovelace',
  email: 'ada@example.com',
  mobile: '+44 20',
);

Future<void> _pump(WidgetTester tester, VtaIdentityCard card) =>
    tester.pumpWidget(
      ProviderScope(
        overrides: [
          cacheManagerProvider.overrideWith((ref) => FakeCacheManager()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: card),
        ),
      ),
    );

void main() {
  group('VtaIdentityCard', () {
    testWidgets('shows the details its profile holds', (tester) async {
      await _pump(tester, const VtaIdentityCard(did: _did, card: _card));

      expect(find.text('Ada L'), findsOneWidget);
      expect(find.text('vta.example/ada'), findsOneWidget);
      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('ada@example.com'), findsOneWidget);
      expect(find.text('+44 20'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows the DID as metadata at the foot', (tester) async {
      await _pump(tester, const VtaIdentityCard(did: _did, card: _card));

      final did = tester.widget<Text>(find.text(_did));
      final context = tester.element(find.text(_did));
      expect(
        did.style?.fontSize,
        Theme.of(context).textTheme.labelSmall?.fontSize,
      );
      expect(did.style?.fontFamily, 'monospace');
      expect(find.byIcon(Icons.fingerprint), findsOneWidget);
      expect(
        tester.getTopLeft(find.text(_did)).dy,
        greaterThan(tester.getTopLeft(find.text('+44 20')).dy),
      );
    });

    testWidgets('centres the picture over the header edge', (tester) async {
      await _pump(tester, const VtaIdentityCard(did: _did, card: _card));

      final avatar = tester.getRect(find.byType(CircleAvatar));
      final card = tester.getRect(find.byType(VtaIdentityCard));
      final host = tester.getRect(find.text('vta.example/ada'));
      final fullName = tester.getRect(find.text('Ada Lovelace'));
      expect(avatar.center.dx, moreOrLessEquals(card.center.dx, epsilon: 1));
      expect(avatar.top, greaterThan(host.bottom));
      expect(avatar.bottom, lessThan(fullName.top));
    });

    testWidgets('spans the header across a short name', (tester) async {
      await _pump(
        tester,
        VtaIdentityCard(
          did: 'did:key:z6Mk',
          card: _card.copyWith(displayName: 'A'),
        ),
      );

      final header = tester.getRect(
        find
            .descendant(
              of: find.byType(VtaIdentityCard),
              matching: find.byType(DecoratedBox),
            )
            .at(1),
      );
      final card = tester.getRect(find.byType(VtaIdentityCard));
      // The card's margin and border sit around the header.
      expect(header.width, moreOrLessEquals(card.width - 18, epsilon: 1));
    });

    testWidgets('leaves out the details the profile lacks', (tester) async {
      await _pump(
        tester,
        VtaIdentityCard(
          did: _did,
          card: _card.copyWith(email: null, mobile: ' '),
        ),
      );

      expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsNothing);
      expect(find.byIcon(Icons.phone_outlined), findsNothing);
    });

    testWidgets('shows the picture in place of the icon', (tester) async {
      final picture = base64Encode(
        img.encodeJpg(img.Image(width: 8, height: 8)),
      );

      await _pump(
        tester,
        VtaIdentityCard(
          did: _did,
          card: _card.copyWith(profilePic: picture),
        ),
      );

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.backgroundImage, isNotNull);
      expect(find.byIcon(Icons.person), findsNothing);
    });

    testWidgets('shows an identity this phone does not hold by its DID', (
      tester,
    ) async {
      await _pump(tester, const VtaIdentityCard(did: _did));

      expect(find.text(_did), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsNothing);
    });
  });
}
