import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_colors.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/common/app_card.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/identity_picker/identity_card.dart';

import '../../../fakes/fake_cache_manager.dart';
import '../../../fakes/fake_identities.dart';

void main() {
  Future<void> pumpCard(WidgetTester tester, Identity identity) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: IdentityCard(
              identity: identity,
              // Small cards carry no action menu, which needs a pie canvas.
              identityCardSize: IdentityCardSize.small,
              cacheManager: FakeCacheManager(),
            ),
          ),
        ),
      );

  testWidgets('carries the identity colour as the corner wash', (tester) async {
    await pumpCard(tester, FakeIdentities.primaryIdentity);

    final card = tester.widget<AppCard>(find.byType(AppCard));
    expect(card.accent, AppTheme.dark.colorScheme.primary);
  });

  testWidgets('opens with the kind of identity as an eyebrow', (tester) async {
    await pumpCard(tester, FakeIdentities.primaryIdentity);

    expect(find.text('YOUR PRIMARY IDENTITY'), findsOneWidget);
    expect(find.text('Primary Identity'), findsOneWidget);
  });

  testWidgets('mutes what the identity does not share', (tester) async {
    await pumpCard(tester, FakeIdentities.secondaryIdentity);

    final notShared = tester.widget<Text>(find.text('Not shared').first);
    expect(notShared.style?.color, McColors.dark.textTertiary);
  });

  testWidgets('puts the VTA details beside the name', (tester) async {
    final identity = FakeIdentities.primaryIdentity.copyWith(
      vtaContextId: 'mpx-1',
      vtaProfileId: '01PROFILE',
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: IdentityCard(
              identity: identity,
              identityCardSize: IdentityCardSize.small,
              cacheManager: FakeCacheManager(),
            ),
          ),
        ),
      ),
    );

    final shield = tester.getRect(find.byKey(const Key('vta_details_toggle')));
    final name = tester.getRect(find.text('Primary Identity'));
    expect(shield.center.dy, moreOrLessEquals(name.center.dy, epsilon: 1));
    expect(
      shield.left,
      greaterThanOrEqualTo(name.right),
      reason: 'beside the name',
    );
  });

  testWidgets('offers no VTA details for an identity off the VTA', (
    tester,
  ) async {
    await pumpCard(tester, FakeIdentities.primaryIdentity);

    expect(find.byKey(const Key('vta_details_toggle')), findsNothing);
  });
}
