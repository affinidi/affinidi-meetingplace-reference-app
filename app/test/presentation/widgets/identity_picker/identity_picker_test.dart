import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/identity_picker/identity_picker.dart';

import '../../../fakes/fake_cache_manager.dart';
import '../../../fakes/fake_identities.dart';

void main() {
  testWidgets('does not delete an identity swiped down', (tester) async {
    final deleted = <Identity>[];
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: IdentityPicker(
            key: const ValueKey('identities'),
            identities: [
              FakeIdentities.secondaryIdentity,
              FakeIdentities.primaryIdentity,
            ],
            onSelectedIdentity: (_) {},
            onDeleteIdentity: deleted.add,
            // Small cards carry no action menu, which needs a pie canvas.
            displayMode: true,
            // Even when the deck lets a card go down, it is not deleted.
            swipeDirection: const AllowedSwipeDirection.only(
              left: true,
              right: true,
              down: true,
            ),
            cacheManager: FakeCacheManager(),
          ),
        ),
      ),
    );

    await tester.timedDrag(
      find.byType(IdentityPicker),
      const Offset(0, 400),
      const Duration(milliseconds: 300),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(deleted, isEmpty);
  });
}
